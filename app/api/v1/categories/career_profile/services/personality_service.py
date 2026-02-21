import httpx
from pydantic import BaseModel
from typing import Optional
from app.core.config import settings

PERSONALITY_ABOUT_PROMPT = """
Kamu adalah penulis konten karier. Tugasmu adalah memformat ulang deskripsi kode RIASEC
menjadi narasi personal yang hangat dan mudah dipahami remaja/mahasiswa.

KODE RIASEC: {riasec_code}
JUDUL KODE: {riasec_title}
DESKRIPSI ASLI DARI DATABASE:
"{riasec_description}"

NAMA TIPE HURUF:
{letters_block}

TUGAS:
Tulis tepat 3 kalimat narasi dengan template wajib:

Kalimat 1: "Kode {riasec_code} menunjukkan bahwa kekuatan utamamu adalah tipe {first_letter_name}."
Kalimat 2: "{sentence_2_template}"
Kalimat 3: "Sinergi ini membuatmu cenderung menjadi [rangkuman karakter dari deskripsi — 1 kalimat singkat, padat, positif]."

ATURAN:
- Kalimat 1 dan 2 WAJIB menggunakan template persis (sudah disediakan di atas, jangan ubah)
- Kalimat 3 bebas tapi harus diturunkan dari deskripsi asli
- Maksimum 30 kata untuk kalimat 3
- Bahasa Indonesia yang hangat dan memotivasi
- Gunakan kata "kamu" (bukan "Anda")

ATURAN OUTPUT:
- Kembalikan HANYA teks 3 kalimat, tidak ada label, tidak ada JSON
- Pisahkan tiap kalimat dengan newline
"""

RIASEC_LETTER_NAMES = {
    "R": "Realistic",
    "I": "Investigative",
    "A": "Artistic",
    "S": "Social",
    "E": "Enterprising",
    "C": "Conventional"
}

class PersonalityService:
    @staticmethod
    async def get_personality_about_text(
        riasec_code: str,
        riasec_title: str,
        riasec_description: str,
        redis_client
    ) -> str:
        """
        Ambil narasi 'Tentang Kode' dari Redis atau generate via Gemini.
        Di-cache per kode RIASEC — tidak personal, sama untuk semua user.
        """
        cache_key = f"personality_about:{riasec_code}"

        # Cek Redis cache dulu
        if redis_client:
            try:
                cached = await redis_client.get(cache_key)
                if cached:
                    return cached.decode("utf-8")
            except Exception:
                pass  # Redis down — lanjut ke Gemini

        # Build prompt
        letters = list(riasec_code)
        letter_names = [RIASEC_LETTER_NAMES.get(l, l) for l in letters]

        # Handle kode < 3 huruf (single atau dual) untuk kalimat template
        if len(letters) == 1:
            # Single: hanya ada 1 tipe, kalimat 2 dan 3 menyesuaikan
            second_letter_name = letter_names[0]
            third_letter_name  = None   # tidak digunakan
            sentence_2_template = f"Caramu bekerja sepenuhnya didominasi oleh orientasi {letter_names[0]}."
        elif len(letters) == 2:
            second_letter_name = letter_names[1]
            third_letter_name  = None
            sentence_2_template = f"Caramu bekerja juga dipengaruhi oleh pola pikir {letter_names[1]}."
        else:
            second_letter_name = letter_names[1]
            third_letter_name  = letter_names[2]
            sentence_2_template = (f"Caramu bekerja juga dipengaruhi oleh pola pikir {letter_names[1]} "
                                   f"dan gaya {letter_names[2]}.")

        prompt = PERSONALITY_ABOUT_PROMPT.format(
            riasec_code=riasec_code,
            riasec_title=riasec_title,
            riasec_description=riasec_description or riasec_title,
            letters_block="\n".join([f"- {l}: {RIASEC_LETTER_NAMES.get(l, l)}" for l in letters]),
            first_letter_name=letter_names[0],
            sentence_2_template=sentence_2_template
        )

        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.post(
                url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": settings.OPENROUTER_MODEL,
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 200,
                    "temperature": 0.5
                }
            )

        if response.status_code != 200:
            return "Kekuatan utamamu tergambar dari kode ini. Memiliki potensi besar jika dikembangkan dengan baik."

        resp_json = response.json()
        if "choices" in resp_json and len(resp_json["choices"]) > 0:
            text = resp_json["choices"][0]["message"]["content"].strip()
            
            # Simpan ke Redis TTL 7 hari
            if redis_client:
                try:
                    await redis_client.setex(cache_key, 7 * 24 * 3600, text)
                except Exception:
                    pass
            
            return text
        
        return "Kekuatan utamamu tergambar dari kode ini. Memiliki potensi besar jika dikembangkan dengan baik."
