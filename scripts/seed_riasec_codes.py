import os
import sys
import re
from sqlalchemy import text
from sqlalchemy.orm import Session

# Menambahkan root project ke sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.db.session import SessionLocal

def seed_riasec_codes_from_sql():
    db: Session = SessionLocal()
    file_path = "data/riasec_codes_seed.sql"
    
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} tidak ditemukan!")
        return

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            sql_content = f.read()

        # Membersihkan komentar SQL agar tidak mengganggu parsing
        sql_content = re.sub(r'--.*?\n', '', sql_content)
        
        # Memisahkan berdasarkan titik koma (;) untuk mendapatkan tiap query INSERT
        # Filter(None) digunakan untuk membuang string kosong hasil split
        queries = [q.strip() for q in sql_content.split(';') if q.strip()]

        print(f"Ditemukan {len(queries)} perintah SQL. Memulai eksekusi...")

        success_count = 0
        for query in queries:
            try:
                # Menggunakan text() untuk membungkus string SQL mentah
                db.execute(text(query))
                success_count += 1
            except Exception as e:
                print(f"Gagal mengeksekusi satu baris: {str(e)[:100]}...")
                # Skip jika ada error (misal karena record sudah ada/duplicate)
                continue

        db.commit()
        print(f"\n--- SEEDING SELESAI ---")
        print(f"Berhasil mengeksekusi {success_count} dari {len(queries)} query.")
        print(f"Catatan: Jika ada yang gagal, kemungkinan karena data sudah ada (Duplicate).")

    except Exception as e:
        print(f"Terjadi error fatal: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_riasec_codes_from_sql()