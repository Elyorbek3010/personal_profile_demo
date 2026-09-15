# 🎓 UNIVER SuperApp - Talabalar uchun Yagona Platforma

Univer SuperApp — Universitet talabalari uchun dars jadvallarini Excel fayllaridan avtomatik o'qib beruvchi, baholar va davomat ko'rsatkichlarini monitoring qiluvchi hamda KD video darsliklariga tezkor ulanuvchi yagona platforma.

---

## 🚀 Texnologiyalar Steki (Tech Stack)

- **Frontend Framework**: React 19 + Vite 8
- **Backend Framework**: Django 5 + Django REST Framework (SimpleJWT & CORS)
- **Styling**: Tailwind CSS v4 (Glassmorphism design system & Dark Mode)
- **Icons**: Lucide React
- **Excel Parser**: SheetJS (`xlsx`)
- **Analytics & Graphs**: Recharts
- **Auth Standarti**: Email & Password (JWT authentication)
- **Mobile Support**: PWA Ready & Mobile Responsive Bottom Navigation Bar

---

## 🛠️ Ishga Tushirish Yo'riqnomasi (Setup Guide)

### 1. Frontend Serverini Ishga Tushirish:
```bash
git checkout feature/frontend
cd frontend
npm install
npm run dev
```
Brauzerda `http://localhost:5173` manzilida ochiladi.

### 2. Backend Serverini Ishga Tushirish:
```bash
git checkout feature/backend
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/Mac:
# source venv/bin/activate

pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```
Backend API Server: `http://localhost:8000/api/`

### 3. Docker Compose orqali barchasini birga ishga tushirish:
```bash
docker compose up --build
```

---

## 📁 Loyiha Strukturasi (Project Structure)

```
personal_profile_demo/
├── backend/                        # Django REST Framework Backend
│   ├── api/                        # Auth & API App (JWT, Register, Profile, Health)
│   ├── config/                     # Django Project Config (settings, urls)
│   ├── Dockerfile                  # Backend Dockerfile
│   ├── manage.py                   # Django CLI
│   └── requirements.txt            # Python dependencies
├── frontend/                       # React 19 + Vite Frontend
│   ├── src/                        # React komonentlar va sahifalar
│   │   ├── components/             # UI Komponentlar (AuthPage, Navbar, Sidebar, etc.)
│   │   ├── pages/                  # Sahifalar (Timetable, etc.)
│   │   ├── utils/                  # Utility alogritmlar (excelParser)
│   │   └── App.jsx                 # Asosiy ilova komponenti
│   ├── index.html                  # HTML template
│   ├── Dockerfile                  # Frontend Dockerfile
│   └── package.json                # NPM dependency manifest
├── docker-compose.yml              # Frontend & Backend Docker orchestrator
```

---

## 🌿 Git Branches

- `main`: Asosiy barqaror tarmoq (Base Branch).
- `feature/frontend`: Frontend bo'yicha ishlab chiqilayotgan faol tarmoq (Active Feature Branch).
- `feature/backend`: Backend bo'yicha ishlab chiqilayotgan faol tarmoq (Active Backend Branch).

