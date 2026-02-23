import uuid
import random
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.db.models.user import User
from app.api.v1.categories.career_profile.models.session import CareerProfileTestSession
from app.api.v1.categories.career_profile.models.riasec import RIASECQuestionSet
from app.db.models.kenalidiri_history import KenaliDiriHistory
from app.api.v1.dependencies.token import check_and_deduct_token

# ID kategori "Tes Profil Karier" di tabel kenalidiri_categories
# category_code = CAREER_PROFILE, id = 3 (sesuai seed data)
# PERBAIKAN: nilai sebelumnya salah (1), seharusnya 3
CAREER_PROFILE_CATEGORY_ID = 3


class SessionService:
    def __init__(self, db: Session):
        self.db = db

    def start_session(
        self,
        user: User,
        persona_type: str,
        test_goal: str,
        uses_ikigai: bool,
        target_profession_id: int | None
    ) -> dict:
        """
        Setup lengkap sesi tes baru dalam satu transaksi:
        1. Potong token (hanya RECOMMENDATION)
        2. INSERT careerprofile_test_sessions
        3. INSERT kenalidiri_history (dengan category_id = 3)
        4. Generate & INSERT riasec_question_sets
        5. Return session_token + question_ids ke Flutter

        Seluruh langkah di atas atomik — jika salah satu gagal,
        semua di-rollback termasuk potongan token.
        """
        try:
            # === STEP 1: Token check (hanya RECOMMENDATION) ===
            if test_goal == "RECOMMENDATION":
                check_and_deduct_token(
                    user=user,
                    db=self.db,
                    amount=3,
                    description="Pemakaian Tes Profil Karier — Rekomendasi Profesi"
                )

            # === STEP 2: INSERT careerprofile_test_sessions ===
            session_token = str(uuid.uuid4())

            new_session = CareerProfileTestSession(
                user_id=user.id,
                session_token=session_token,
                persona_type=persona_type,
                test_goal=test_goal,
                target_profession_id=target_profession_id,
                uses_ikigai=uses_ikigai,
                status="riasec_ongoing",
                algorithm_version="1.0",
                question_set_version="1.0"
            )
            self.db.add(new_session)
            self.db.flush()  # Dapatkan ID tanpa commit dulu

            # === STEP 3: INSERT kenalidiri_history ===
            # Menggunakan CAREER_PROFILE_CATEGORY_ID = 3 (bukan 1)
            history_entry = KenaliDiriHistory(
                user_id=user.id,
                test_category_id=CAREER_PROFILE_CATEGORY_ID,
                detail_session_id=new_session.id,
                status="ongoing"
            )
            self.db.add(history_entry)

            # === STEP 4: Generate urutan soal & INSERT riasec_question_sets ===
            question_ids = self._generate_question_ids(session_token)

            question_set = RIASECQuestionSet(
                test_session_id=new_session.id,
                question_ids=question_ids,
            )
            self.db.add(question_set)

            # === STEP 5: Commit semua sekaligus (atomik) ===
            self.db.commit()

            return {
                "session_token": session_token,
                "test_goal": test_goal,
                "status": "riasec_ongoing",
                "question_ids": question_ids,
                "total_questions": len(question_ids),
                "message": (
                    "Sesi tes berhasil dibuat. "
                    "Tampilkan 72 soal ke user sesuai urutan question_ids yang diterima. "
                    "Flutter yang handle pembagian per halaman."
                )
            }

        except HTTPException:
            self.db.rollback()
            raise
        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Gagal membuat sesi tes: {str(e)}"
            )

    def _generate_question_ids(self, session_token: str) -> list[int]:
        """
        Generate urutan 72 ID soal (12 soal per tipe RIASEC), diacak urutannya.

        Seed dari session_token agar urutan tetap konsisten kalau user refresh.
        Dengan seed yang sama, urutan selalu identik.

        Struktur riasec_questions (72 soal total):
        - ID 1-12   → tipe R (Realistic)
        - ID 13-24  → tipe I (Investigative)
        - ID 25-36  → tipe A (Artistic)
        - ID 37-48  → tipe S (Social)
        - ID 49-60  → tipe E (Enterprising)
        - ID 61-72  → tipe C (Conventional)

        Semua 72 soal diambil, lalu diacak urutannya (tidak dikelompokkan per tipe).
        Flutter yang handle pembagian per halaman dari 72 soal ini.
        """
        random.seed(session_token)

        type_ranges = {
            "R": list(range(1, 13)),
            "I": list(range(13, 25)),
            "A": list(range(25, 37)),
            "S": list(range(37, 49)),
            "E": list(range(49, 61)),
            "C": list(range(61, 73)),
        }

        # Ambil SEMUA 72 soal (12 per tipe)
        all_questions = []
        for riasec_type, pool in type_ranges.items():
            all_questions.extend(pool)

        # Acak urutan tampil (bukan dikelompokkan per tipe)
        random.shuffle(all_questions)
        return all_questions

    def get_session_by_token(self, session_token: str) -> CareerProfileTestSession:
        session = self.db.query(CareerProfileTestSession).filter(
            CareerProfileTestSession.session_token == session_token
        ).first()
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session token tidak valid atau tidak ditemukan"
            )
        return session
