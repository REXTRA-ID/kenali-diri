import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

def check():
    url = os.environ.get("DATABASE_URL")
    if not url:
        print("No DATABASE_URL")
        return
    engine = create_engine(url)
    with engine.connect() as conn:
        res = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='career_recommendations'"))
        columns = [r[0] for r in res]
        print("Columns in career_recommendations:", columns)
        
        res = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='fit_check_results'"))
        columns = [r[0] for r in res]
        print("Columns in fit_check_results:", columns)

if __name__ == "__main__":
    check()
