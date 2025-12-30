#!/usr/bin/env python3
"""
Users Seeder Script
"""
import sys
from pathlib import Path
import uuid

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.db.session import SessionLocal
from app.db.models.user import User

def seed_users():
    db = SessionLocal()
    try:
        user_id = "ef9cf8e8-46b1-4e91-89d0-40f6c824319e"
        
        # Check if exists
        existing = db.query(User).filter(User.id == user_id).first()
        if existing:
            print(f"⏭️  User {user_id} already exists.")
            return

        user = User(
            id=user_id,
            fullname="Test User",
            email="test@example.com",
            password="hashed_password",
            phone_number="08123456789",
            role="USER",
            is_verified=True
        )
        db.add(user)
        db.commit()
        print(f"✅ User {user_id} created.")
    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding users: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_users()
