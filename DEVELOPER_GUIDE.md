# 🚀 Kenali Diri Developer Guide

Welcome to the development guide for **Kenali Diri Career Profile API**. This document will walk you through setting up the project from scratch to running end-to-end tests.

---

## 🛠 Prerequisites

Before you begin, ensure you have the following installed on your machine:
*   [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
*   [Python 3.11+](https://www.python.org/downloads/) (Optional: only needed for local linting or non-docker scripts)
*   [Git](https://git-scm.com/)

---

## 📥 1. Project Initialization

### Clone the Repository
```bash
git clone https://github.com/REXTRA-ID/kenali-diri
cd kenali-diri
```

### Environment Configuration
Copy the default environment variables and update them if necessary (especially `OPENROUTER_API_KEY` for AI features).
```bash
cp .env.example .env
```

---

## 🐳 2. Running with Docker (Recommended)

The easiest way to run the entire stack (API, PostgreSQL, Redis) is using Docker Compose.

### Build and Start Services
```bash
# Build images and start containers in detached mode
docker compose up -d --build
```

### Check Logs
```bash
docker compose logs -f api
```

---

## 🗄 3. Database Setup

Once the containers are running, you need to apply migrations and seed the data.

### Apply Migrations (Alembic)
This will create all table structures in PostgreSQL.
```bash
docker compose exec api alembic upgrade head
```

### Seed Database
Run the master seeder to populate RIASEC codes, categories, and sample digital professions.
```bash
docker compose exec api python -m scripts.seed_all
```

---

## 🔬 4. Running End-to-End (E2E) Tests

We use a comprehensive E2E script to validate the entire career profiling flow:
1.  **Session Creation** (`/start`)
2.  **RIASEC Submission** (`/riasec/submit`)
3.  **Candidate Retrieval** (`/riasec/candidates`)
4.  **Ikigai AI Analysis** (`/ikigai/submit`)
5.  **Final Results Verification**

### Execute Test Script
```bash
docker compose exec api python scripts/e2e_real_test.py
```

---

## 🏗 Project Architecture

*   **`app/api/v1`**: Contains all endpoints organized by domain (RIASEC, Ikigai, Session).
*   **`app/db`**: Database configuration, Base models, and session management.
*   **`app/shared`**: Shared utilities like AI clients and scoring formulas.
*   **`scripts/`**: Automation scripts for seeding and testing.

---

## 🛑 Common Troubleshooting

**1. Database Connection Refused**
If the API starts before the database is ready, it might fail. Simply restart the API container:
```bash
docker compose restart api
```

**2. ModuleNotFoundError inside Docker**
If you added new libraries to `requirements.txt`, ensure you rebuild the image:
```bash
docker compose up -d --build
```

**3. AI Evaluation Fails**
Check your `OPENROUTER_API_KEY` in the `.env` file. Ensure the key has enough credits and access to the configured model (default: `google/gemini-2.0-flash-001`).

---

Happy Coding! 👩‍💻👨‍💻
