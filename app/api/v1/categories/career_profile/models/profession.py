from sqlalchemy import Column, BigInteger, Integer, String, ForeignKey, CheckConstraint, Index
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import TIMESTAMP
from sqlalchemy.sql import func
from app.db.base import Base


class IkigaiCandidateProfession(Base):
    """
    Menyimpan daftar kandidat profesi yang digenerate saat RIASEC selesai.
    One-to-one dengan careerprofile_test_sessions.
    INSERT sekali, immutable — tidak pernah di-UPDATE setelah dibuat.

    Kandidat terbagi dua kategori:
      - display_order 1–5  : Kandidat Opsi   → tampil di UI Ikigai sebagai pilihan user
      - display_order 6–30 : Kandidat Pool   → ikut AI scoring tapi tidak tampil di UI

    candidates_data JSONB format:
    {
      "candidates": [
        {
          "profession_id": int,
          "display_order": int,       # 1–5 opsi, 6–30 pool
          "congruence_type": str,     # "exact_match" | "permutation_match" | ...
          "congruence_score": float,  # 0.0–1.0
          "tier": int                 # 1–4 (tier ekspansi RIASEC)
        },
        ...
      ]
    }
    """
    __tablename__ = "ikigai_candidate_professions"

    id = Column(BigInteger, primary_key=True, autoincrement=True)

    test_session_id = Column(
        BigInteger,
        ForeignKey("careerprofile_test_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True  # One-to-one dengan session
    )

    # JSONB utama — berisi array kandidat lengkap
    candidates_data = Column(JSONB, nullable=False)

    # Denormalisasi untuk analytics cepat (tanpa parse JSON setiap query)
    # Minimum 1 (bukan 5) — constraint 5 terlalu ketat saat data profesi masih sedikit.
    # Validasi "idealnya >= 5" dilakukan di service layer sebagai warning log, bukan hard fail.
    total_candidates = Column(Integer, nullable=False)

    # Strategi yang digunakan saat generate kandidat:
    # "4_tier_expansion" → ekspansi 4 tier dari kode RIASEC user
    # "split_path"       → profil split (kode ambigu / tidak dominan)
    generation_strategy = Column(String(50), nullable=True)

    # Batas maksimum kandidat yang boleh digenerate (default 30)
    max_candidates_limit = Column(Integer, default=30)

    generated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    __table_args__ = (
        Index("idx_ikigai_candidates_session", "test_session_id"),
        # Minimum 1 bukan 5: mencegah hard fail saat DB profesi belum lengkap.
        # Naikkan minimum ke 5 setelah data produksi sudah cukup terisi.
        CheckConstraint(
            "total_candidates BETWEEN 1 AND 30",
            name="chk_total_candidates_range"
        ),
    )

    def __repr__(self):
        return (
            f"<IkigaiCandidateProfession "
            f"session={self.test_session_id} "
            f"total={self.total_candidates} "
            f"strategy={self.generation_strategy}>"
        )