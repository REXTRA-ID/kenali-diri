from fastapi import APIRouter, Depends, Request, HTTPException, status
from sqlalchemy.orm import Session
from typing import Union

from app.db.session import get_db
from app.core.rate_limit import limiter
from app.api.v1.dependencies.auth import require_active_membership
from app.api.v1.categories.career_profile.services.ikigai_service import IkigaiService
from app.api.v1.categories.career_profile.schemas.ikigai import (
    StartIkigaiRequest,
    IkigaiContentResponse,
    SubmitDimensionRequest,
    DimensionSubmitResponse,
    IkigaiCompletionResponse
)
from app.db.models.user import User

router = APIRouter(
    prefix="/career-profile/ikigai",
    tags=["Career Profile - Ikigai"]
)


@router.post("/start", response_model=IkigaiContentResponse)
@limiter.limit("10/hour")
async def start_ikigai_session(
    request: Request,
    body: StartIkigaiRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Memulai fase Ikigai.
    - Validasi sesi harus 'riasec_completed'
    - Ubah status sesi ke 'ikigai_ongoing'
    - Generate narasi dimensi untuk kandidat top menggunakan Gemini
    - Cache konten di Redis selama 2 jam
    """
    service = IkigaiService(db)
    return await service.start_ikigai_session(
        user=current_user,
        session_token=body.session_token
    )


@router.get("/content/{session_token}", response_model=IkigaiContentResponse)
@limiter.limit("30/minute")
async def get_ikigai_content(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Mengambil konten soal Ikigai (opsi profesi beserta narasi dimensinya).
    - Ambil dari cache Redis jika masih valid
    - Jika expired, regenerate ulang selama kondisi sesi masih ikigai_ongoing
    - Tidak mengubah status sesi.
    """
    service = IkigaiService(db)
    return await service.get_ikigai_content(
        user=current_user,
        session_token=session_token
    )


@router.post("/submit-dimension", response_model=Union[DimensionSubmitResponse, IkigaiCompletionResponse])
@limiter.limit("40/hour")
async def submit_dimension(
    request: Request,
    body: SubmitDimensionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Submit jawaban untuk satu dimensi Ikigai.
    Endpoint ini dipanggil hingga 4 kali (satu per dimensi).

    Jika ini adalah dimensi terakhir (ke-4):
      - Trigger AI scoring batch (4 Gemini call paralel)
      - INSERT ikigai_dimension_scores
      - INSERT ikigai_total_scores
      - UPDATE status sesi -> completed
      - Return IkigaiCompletionResponse dengan top 2 profesi + breakdown skor

    Jika bukan dimensi terakhir:
      - Hanya UPDATE kolom dimensi di ikigai_responses
      - Return DimensionSubmitResponse dengan info progres
    """
    body.validate_consistency()
    service = IkigaiService(db)
    return await service.submit_dimension(
        user=current_user,
        session_token=body.session_token,
        dimension_name=body.dimension_name,
        selected_profession_id=body.selected_profession_id,
        selection_type=body.selection_type,
        reasoning_text=body.reasoning_text
    )


@router.get("/result/{session_token}", response_model=IkigaiCompletionResponse)
@limiter.limit("30/minute")
async def get_ikigai_result(
    request: Request,
    session_token: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_active_membership)
):
    """
    Ambil hasil final Ikigai yang sudah tersimpan.
    Digunakan Flutter untuk reload halaman hasil tanpa re-scoring.
    Hanya bisa diakses jika sesi sudah completed.
    """
    service = IkigaiService(db)
    return await service.get_ikigai_result(session_token=session_token, user=current_user)
