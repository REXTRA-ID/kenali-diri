import json
import httpx
from app.core.config import settings

RECOMMENDATION_NARRATIVE_PROMPT = """
Kamu adalah konselor karier berbasis data. Tugasmu adalah menulis narasi personal
berdasarkan jawaban pengguna dalam Tes Ikigai.

PROFIL RIASEC PENGGUNA: {user_riasec_code}

JAWABAN PENGGUNA PER DIMENSI IKIGAI:
---
Dimensi 1 — What You Love (Apa yang Kamu Sukai):
"{love_text}"

Dimensi 2 — What You Are Good At (Apa yang Kamu Kuasai):
"{good_at_text}"

Dimensi 3 — What The World Needs (Apa yang Dibutuhkan Dunia):
"{world_needs_text}"

Dimensi 4 — What You Can Be Paid For (Apa yang Bisa Dibayar):
"{paid_for_text}"
---

DUA PROFESI YANG DIREKOMENDASIKAN:
{professions_block}

TUGAS:
Hasilkan 6 teks narasi:
1. Ringkasan Dimensi 1 (ikigai_profile_summary.what_you_love)
2. Ringkasan Dimensi 2 (ikigai_profile_summary.what_you_are_good_at)
3. Ringkasan Dimensi 3 (ikigai_profile_summary.what_the_world_needs)
4. Ringkasan Dimensi 4 (ikigai_profile_summary.what_you_can_be_paid_for)
5. Alasan kecocokan Profesi ID {profession_1_id} (match_reasoning)
6. Alasan kecocokan Profesi ID {profession_2_id} (match_reasoning)

ATURAN PENULISAN:

UNTUK RINGKASAN DIMENSI (teks 1-4):
- 2-3 kalimat efektif per dimensi (60-90 kata)
- Bersifat GENERAL — tidak menyebut nama profesi apapun
- Tulis sebagai refleksi diri pengguna: gunakan kata "Kamu..."
- Fokus pada: apa yang membuat antusias, pola aktivitas yang disukai, orientasi kontribusi
- Abstraksi dari jawaban pengguna — bukan parafrase langsung
- Bahasa Indonesia yang natural dan empatik

UNTUK ALASAN KECOCOKAN PROFESI (teks 5-6):
- Tepat 2 kalimat (template wajib):
  Kalimat 1: "Profesi ini cocok karena [hubungan minat/kekuatan dengan aktivitas inti profesi]."
  Kalimat 2: "[Implikasi praktis — bagaimana pengalaman/pola kerja pengguna berkembang dalam profesi ini]."

ATURAN OUTPUT:
- WAJIB mengembalikan JSON valid.
- JANGAN sertakan markdown block `json ...` atau backticks.
- Struktur JSON wajib sama persis dengan format di bawah.

FORMAT JSON OUTPUT:
{{
  "ikigai_profile_summary": {{
    "what_you_love": "Teks ringkasan dimensi 1",
    "what_you_are_good_at": "Teks ringkasan dimensi 2",
    "what_the_world_needs": "Teks ringkasan dimensi 3",
    "what_you_can_be_paid_for": "Teks ringkasan dimensi 4"
  }},
  "match_reasoning": {{
    "{profession_1_id}": "Teks kecocokan profesi 1",
    "{profession_2_id}": "Teks kecocokan profesi 2"
  }}
}}
"""

def build_recommendation_narrative_prompt(
    ikigai_responses: dict,
    top_2_professions: list,
    profession_details: list,
    user_riasec_code: str
) -> str:
    # Build profesi block
    professions_block = ""
    profession_1_id = str(top_2_professions[0]['profession_id']) if top_2_professions else "N/A"
    profession_2_id = str(top_2_professions[1]['profession_id']) if len(top_2_professions) > 1 else "N/A"

    for prof in top_2_professions:
        pid = prof['profession_id']
        match_pct = prof.get('total_score', 0)
        
        detail = next((p for p in profession_details if p['profession_id'] == pid), {})
        about = detail.get('about_description', '-')
        activities = ", ".join(detail.get('activities', []))
        skills = ", ".join(detail.get('hard_skills_required', []))

        professions_block += f"""
Profesi ID {pid}: {detail.get('name', 'Unknown')} (Kecocokan: {match_pct:.1f}%)
Kode RIASEC: {detail.get('riasec_code', '-')}
Deskripsi singkat: {about}
Aktivitas utama: {activities}
Skill utama: {skills}
"""

    return RECOMMENDATION_NARRATIVE_PROMPT.format(
        user_riasec_code=user_riasec_code,
        love_text=ikigai_responses.get("what_you_love", ""),
        good_at_text=ikigai_responses.get("what_you_are_good_at", ""),
        world_needs_text=ikigai_responses.get("what_the_world_needs", ""),
        paid_for_text=ikigai_responses.get("what_you_can_be_paid_for", ""),
        professions_block=professions_block.strip(),
        profession_1_id=profession_1_id,
        profession_2_id=profession_2_id
    )

class RecommendationNarrativeService:
    async def generate_recommendations_narrative(
        self,
        ikigai_responses: dict,      # reasoning_text dari 4 dimensi
        top_2_professions: list,     # data dari ikigai_total_scores
        profession_details: list,    # nama + deskripsi + aktivitas tiap profesi
        user_riasec_code: str
    ) -> dict:
        """
        1 Gemini call untuk generate semua 6 narasi sekaligus.
        Return: dict siap masuk ke recommendations_data JSONB.
        """
        prompt = build_recommendation_narrative_prompt(
            ikigai_responses=ikigai_responses,
            top_2_professions=top_2_professions,
            profession_details=profession_details,
            user_riasec_code=user_riasec_code
        )

        async with httpx.AsyncClient(timeout=45.0) as client:
            response = await client.post(
                url=f"{settings.OPENROUTER_BASE_URL}/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": settings.OPENROUTER_MODEL,
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 1500,
                    "temperature": 0.6
                }
            )

        if response.status_code != 200:
            return self._get_fallback_narrative(top_2_professions)

        raw_text = response.json()["choices"][0]["message"]["content"].strip()

        # Strip markdown fences jika ada
        if raw_text.startswith("```"):
            raw_text = raw_text.split("```")[1]
            if raw_text.startswith("json"):
                raw_text = raw_text[4:]
            raw_text = raw_text.rsplit("```", 1)[0].strip()

        try:
            return json.loads(raw_text)
        except json.JSONDecodeError:
            return self._get_fallback_narrative(top_2_professions)

    def _get_fallback_narrative(self, top_2_professions: list) -> dict:
        fallback = {
            "ikigai_profile_summary": {
                "what_you_love": "Kamu memiliki passion kuat pada mengeksplorasi minat dari aktivitas yang digemari secara bebas.",
                "what_you_are_good_at": "Kamu menguasai berbagai keterampilan yang mendukung pencapaian pekerjaan berbasis analitis maupun praktis.",
                "what_the_world_needs": "Sosok dengan impian mengubah lingkungan menjadi positif sangat dibutuhkan oleh berbagai komunitas global.",
                "what_you_can_be_paid_for": "Dedikasimu dalam memberikan yang terbaik bisa diapresiasi dengan sangat bernilai dalam industri yang relevan."
            },
            "match_reasoning": {}
        }
        for prof in top_2_professions:
            pid = str(prof["profession_id"])
            fallback["match_reasoning"][pid] = (
                "Profesi ini cocok karena melibatkan keahlian teknis yang sinkron dengan minat Anda. "
                "Anda akan menemukan pengalaman berkembang yang cepat di lingkungan kerja kolaboratif ini."
            )
        return fallback
