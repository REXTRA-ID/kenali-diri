# app/api/v1/dependencies/token.py
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.db.models.token import TokenWallet, TokenLedger
from app.db.models.user import User
from datetime import datetime
import uuid

TOKEN_COST_RECOMMENDATION = 3

def check_and_deduct_token(
    user: User,
    db: Session,
    amount: int = TOKEN_COST_RECOMMENDATION,
    description: str = "Pemakaian Tes Profil Karier"
) -> TokenWallet:
    """
    Cek saldo token dan kurangi jika mencukupi.
    Update token_wallet dan tambah baris baru di token_ledger.
    
    Gunakan with_for_update() untuk hindari race condition
    saat user memulai tes dari beberapa device sekaligus.
    
    Raises:
        HTTP 402: Token tidak mencukupi
        HTTP 404: Wallet tidak ditemukan
    """
    wallet = db.query(TokenWallet).filter(
        TokenWallet.user_id == user.id
    ).with_for_update().first()

    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Token wallet user tidak ditemukan"
        )

    if wallet.balance < amount:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail=(
                f"Token tidak mencukupi. "
                f"Saldo: {wallet.balance} token, dibutuhkan: {amount} token."
            )
        )

    balance_before = wallet.balance
    balance_after = wallet.balance - amount

    # Update saldo di token_wallet
    wallet.balance = balance_after
    wallet.updated_at = datetime.utcnow()

    # Catat transaksi di token_ledger
    ledger_entry = TokenLedger(
        id=uuid.uuid4(),
        occurred_at=datetime.utcnow(),
        wallet_id=wallet.id,
        direction="OUT",
        amount=amount,
        balance_before=balance_before,
        balance_after=balance_after,
        source_type="CAREER_PROFILE_TEST",
        description=description,
        created_at=datetime.utcnow()
    )
    db.add(ledger_entry)
    # CATATAN: commit dilakukan bersama insert sesi tes di session_service
    # agar atomic — kalau insert sesi gagal, potongan token juga di-rollback

    return wallet

# === CATATAN FIT_CHECK — PERLU DIROMBAK KE DEPAN ===
# FIT_CHECK saat ini bebas akses tanpa pengecekan token/kuota.
# Jika ke depan ada pembatasan (misal: 3x per bulan, atau berbayar token):
#
# File yang perlu dimodifikasi:
# - app/db/models/token.py → tambah model FitCheckQuota atau kolom kuota
# - app/api/v1/dependencies/token.py → file ini, tambah fungsi check_fit_check_quota()
# - app/api/v1/categories/career_profile/routers/session.py → tambah dependency di endpoint fit-check/start
# - app/api/v1/categories/career_profile/services/session_service.py → catat penggunaan kuota
