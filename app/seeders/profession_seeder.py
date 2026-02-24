"""
app/seeders/profession_seeder.py
--------------------------------
Seeder untuk tabel professions dan relasi dasarnya (aliases).
Menggunakan pola "insert jika belum ada" (idempotent / safe to re-run) via pengecekan slug.

Cara menjalankan (dari root project):
    python -m app.seeders.profession_seeder

Pastikan profession_main_category_seeder dan profession_sub_category_seeder 
telah dijalankan lebih dulu.
"""

import asyncio
from datetime import datetime, timezone
from sqlalchemy import select, text
from app.database.config import AsyncSessionLocal
from app.models.profession import Profession
from app.models.profession_main_category import ProfessionMainCategory
from app.models.profession_sub_category import ProfessionSubCategory
from app.models.profession_alias import ProfessionAlias

# Format: slug, name, main_code, sub_code, riasec_code (nullable), about_description, aliases (list)
PROFESSIONS = [
    # ── ENGINEERING ──
    {
        "slug": "backend-engineer",
        "name": "Backend Engineer",
        "main_code": "ENGINEERING",
        "sub_code": "BACKEND",
        "riasec_code": "RI",
        "about_description": "Membangun dan memelihara sisi server aplikasi (API, database, dan logika bisnis).",
        "aliases": ["Backend Developer", "Server-Side Developer", "API Engineer"],
    },
    {
        "slug": "frontend-engineer",
        "name": "Frontend Engineer",
        "main_code": "ENGINEERING",
        "sub_code": "FRONTEND",
        "riasec_code": "RI",
        "about_description": "Membangun antarmuka yang berinteraksi langsung dengan pengguna menggunakan teknologi web.",
        "aliases": ["Frontend Developer", "Web Developer", "UI Engineer"],
    },
    {
        "slug": "mobile-engineer",
        "name": "Mobile Engineer",
        "main_code": "ENGINEERING",
        "sub_code": "MOBILE",
        "riasec_code": "RI",
        "about_description": "Mengembangkan aplikasi untuk perangkat seluler seperti iOS dan Android.",
        "aliases": ["Android Developer", "iOS Developer", "Mobile App Developer"],
    },
    {
        "slug": "devops-engineer",
        "name": "DevOps Engineer",
        "main_code": "ENGINEERING",
        "sub_code": "DEVOPS",
        "riasec_code": "RC",
        "about_description": "Menjembatani pengembangan perangkat lunak dengan operasi IT untuk integrasi dan rilis berkelanjutan.",
        "aliases": ["Site Reliability Engineer (SRE)", "Platform Engineer", "Release Engineer"],
    },
    {
        "slug": "qa-engineer",
        "name": "QA Engineer",
        "main_code": "ENGINEERING",
        "sub_code": "QUALITY_ASSURANCE",
        "riasec_code": "CI",
        "about_description": "Menguji perangkat lunak untuk memastikan produk bebas dari bug dan memenuhi standar kualitas.",
        "aliases": ["Software Tester", "Quality Assurance Engineer", "Test Engineer"],
    },

    # ── DATA ──
    {
        "slug": "data-analyst",
        "name": "Data Analyst",
        "main_code": "DATA",
        "sub_code": "ANALYTICS",
        "riasec_code": "IC",
        "about_description": "Membersihkan, menganalisis, dan memvisualisasikan data untuk menemukan insight bisnis yang dapat ditindaklanjuti.",
        "aliases": ["Business Intelligence Analyst", "Analytics Specialist"],
    },
    {
        "slug": "data-engineer",
        "name": "Data Engineer",
        "main_code": "DATA",
        "sub_code": "INFRASTRUCTURE",
        "riasec_code": "IR",
        "about_description": "Membangun sistem, arsitektur, dan pipeline untuk mengelola pengumpulan dan penyimpanan volume data besar.",
        "aliases": ["Big Data Engineer", "Data Pipeline Engineer"],
    },
    {
        "slug": "data-scientist",
        "name": "Data Scientist",
        "main_code": "DATA",
        "sub_code": "SCIENCE",
        "riasec_code": "IA",
        "about_description": "Menggunakan metode statistik dan machine learning untuk menganalisis data kompleks dan memprediksi masa depan.",
        "aliases": ["Predictive Modeler", "Data Science Specialist"],
    },
    {
        "slug": "ai-engineer",
        "name": "AI Engineer",
        "main_code": "DATA",
        "sub_code": "AI",
        "riasec_code": "IR",
        "about_description": "Fokus pada pengembangan model kecerdasan buatan, termasuk machine learning dan neural networks.",
        "aliases": ["Machine Learning Engineer", "Deep Learning Engineer", "AI Researcher"],
    },
    
    # ── PRODUCT ──
    {
        "slug": "product-manager",
        "name": "Product Manager",
        "main_code": "PRODUCT",
        "sub_code": "MANAGEMENT",
        "riasec_code": "ES",
        "about_description": "Mengelola seluruh siklus hidup produk, mulai dari penemuan kebutuhan pengguna hingga peluncuran fitur.",
        "aliases": ["PM", "Digital Product Manager"],
    },
    {
        "slug": "product-owner",
        "name": "Product Owner",
        "main_code": "PRODUCT",
        "sub_code": "MANAGEMENT",
        "riasec_code": "ES",
        "about_description": "Merumuskan dan memprioritaskan product backlog, berfungsi sebagai perwakilan pelanggan untuk tim pengembang agile.",
        "aliases": ["Agile Product Owner", "Scrum Product Owner"],
    },
    {
        "slug": "growth-hacker",
        "name": "Growth Hacker",
        "main_code": "PRODUCT",
        "sub_code": "GROWTH",
        "riasec_code": "EI",
        "about_description": "Melakukan eksperimen terukur di berbagai saluran pemasaran dan pengembangan produk untuk mendorong akuisisi pengguna dengan cepat.",
        "aliases": ["Growth Manager", "Growth Specialist", "Performance Marketer"],
    },

    # ── DESIGN ──
    {
        "slug": "ux-researcher",
        "name": "UX Researcher",
        "main_code": "DESIGN",
        "sub_code": "RESEARCH",
        "riasec_code": "SI",
        "about_description": "Mempelajari perilaku target pengguna melalui metode riset untuk memandu strategi desain produk.",
        "aliases": ["User Researcher", "Design Researcher", "Usability Researcher"],
    },
    {
        "slug": "ui-designer",
        "name": "UI Designer",
        "main_code": "DESIGN",
        "sub_code": "UI_UX",
        "riasec_code": "AR",
        "about_description": "Merancang semua elemen visual dan interaktif dari antarmuka pengguna pada produk digital.",
        "aliases": ["User Interface Designer", "Visual Interface Designer"],
    },
    {
        "slug": "ux-designer",
        "name": "UX Designer",
        "main_code": "DESIGN",
        "sub_code": "UI_UX",
        "riasec_code": "AS",
        "about_description": "Mendesain alur dan pengalaman pengguna secara menyeluruh untuk membuat produk yang intuitif dan mudah digunakan.",
        "aliases": ["User Experience Designer", "Experience Designer", "Interaction Designer"],
    },
    {
        "slug": "product-designer",
        "name": "Product Designer",
        "main_code": "DESIGN",
        "sub_code": "UI_UX",
        "riasec_code": "AE",
        "about_description": "Mengerjakan end-to-end desain produk digital, mencakup baik aspek experience (UX) maupun visual (UI).",
        "aliases": ["Full-stack Designer", "Digital Product Designer"],
    },
    {
        "slug": "ux-writer",
        "name": "UX Writer",
        "main_code": "DESIGN",
        "sub_code": "CONTENT",
        "riasec_code": "AS",
        "about_description": "Menulis teks / salinan pendek yang memandu pengguna dalam menggunakan produk digital dan membantu mereka menyelesaikan tugas asisten.",
        "aliases": ["Content Designer", "Product Copywriter", "UI Writer"],
    },
]

async def seed_profession() -> None:
    async with AsyncSessionLocal() as session:
        # Cache untuk main_category ids
        main_cache: dict[str, int] = {}
        for main_code in ("ENGINEERING", "DATA", "PRODUCT", "DESIGN"):
            result = await session.execute(
                select(ProfessionMainCategory).where(ProfessionMainCategory.code == main_code)
            )
            main = result.scalar_one_or_none()
            if main is None:
                raise RuntimeError(f"Main category '{main_code}' tidak ditemukan. Jalankan main category seeder dulu.")
            main_cache[main_code] = main.id

        # Cache untuk sub_category ids
        sub_cache: dict[str, int] = {}
        for prof in PROFESSIONS:
            sub_code = prof["sub_code"]
            main_code = prof["main_code"]
            cache_key = f"{main_code}_{sub_code}"
            
            if cache_key not in sub_cache:
                result = await session.execute(
                    select(ProfessionSubCategory).where(
                        ProfessionSubCategory.main_category_id == main_cache[main_code],
                        ProfessionSubCategory.code == sub_code
                    )
                )
                sub = result.scalar_one_or_none()
                if sub is None:
                    raise RuntimeError(f"Sub category '{sub_code}' tidak ditemukan untuk '{main_code}'. Jalankan sub category seeder dulu.")
                sub_cache[cache_key] = sub.id

        # Cache untuk riasec_codes mapping dari tabel di postgres
        riasec_cache: dict[str, int] = {}
        try:
            # Menggunakan raw query karena model RIASECCode tidak terdaftar di base Base saat ini
            # Asumsi tabel riasec_codes dengan kolom riasec_code dan id sudah ada
            result = await session.execute(text("SELECT id, riasec_code FROM riasec_codes"))
            for row in result:
                riasec_cache[row[1]] = row[0]
            if not riasec_cache:
                print("⚠️ Tabel riasec_codes kosong atau tidak ditemukan data. Field riasec_code_id akan diset NULL.")
        except Exception as e:
            print(f"⚠️ Peringatan: Gagal memuat riasec_codes ({e}). Field riasec_code_id akan diset NULL.")
            await session.rollback() # Reset transaksi

        for data in PROFESSIONS:
            # 1. Pastikan belum ada (via slug)
            existing = await session.execute(
                select(Profession).where(Profession.slug == data["slug"])
            )
            if existing.scalar_one_or_none() is not None:
                print(f"[SKIP] {data['slug']} — sudah ada")
                continue

            # 2. Persiapkan FKs
            main_id = main_cache[data["main_code"]]
            sub_id = sub_cache[f"{data['main_code']}_{data['sub_code']}"]
            riasec_val = riasec_cache.get(data["riasec_code"]) if data.get("riasec_code") else None
            
            now = datetime.now(timezone.utc)
            
            # Khusus untuk requirement: riasec_description wajib jika_ada riasec_code_id
            riasec_desc = None
            if riasec_val:
                riasec_desc = f"Memerlukan profil kepribadian {data['riasec_code']} untuk berkembang dengan baik."

            # 3. Buat instance profession
            new_prof = Profession(
                slug=data["slug"],
                name=data["name"],
                main_category_id=main_id,
                sub_category_id=sub_id,
                riasec_code_id=riasec_val,
                about_description=data["about_description"],
                riasec_description=riasec_desc,
                created_at=now,
                updated_at=now
            )
            session.add(new_prof)
            await session.flush()  # dapatkan id untuk aliases, dll
            
            # 4. Buat aliases
            for alias_name in data.get("aliases", []):
                new_alias = ProfessionAlias(
                    profession_id=new_prof.id,
                    alias_name=alias_name,
                    created_at=now,
                    updated_at=now
                )
                session.add(new_alias)

            print(f"[INSERT] {data['slug']}")

        await session.commit()
        print("✅ Seeder profession selesai.")

if __name__ == "__main__":
    asyncio.run(seed_profession())
