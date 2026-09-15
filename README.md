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

---

## 📁 Loyiha Strukturasi (Project Structure)

```
personal_profile_demo/
├── backend/                        # Django REST Framework Backend
│   ├── api/                        # Auth & API App (JWT, Register, Profile, Health)
│   ├── config/                     # Django Project Config (settings, urls)
│   ├── manage.py                   # Django CLI
│   └── requirements.txt            # Python dependencies
├── src/                            # React Frontend
│   ├── components/
│   │   ├── AuthPage.jsx            # Email & Parol login/register sahifasi
│   │   ├── Navbar.jsx              # Yuqori menyu va Logout tugmasi
│   │   ├── Sidebar.jsx             # Chap tomondagi asosiy navigatsiya
│   │   └── MobileBottomNav.jsx     # Mobil telefonlar uchun pastki menyu
│   ├── pages/
│   │   └── Timetable.jsx           # Smart Dars Jadvali & Excel AI Parser
│   ├── data/
│   │   └── mockSchedule.js         # Test dars jadvali ma'lumotlari
│   ├── utils/
│   │   └── excelParser.js          # Excel (.xlsx) fayllarni o'quvchi algoritm
│   ├── App.jsx                     # Asosiy ilova komponenti
│   └── index.css                   # Tailwind CSS v4 va maxsus stillar
```

---

## 🌿 Git Branches

- `main`: Asosiy barqaror tarmoq (Base Branch).
- `feature/frontend`: Frontend bo'yicha ishlab chiqilayotgan faol tarmoq (Active Feature Branch).
- `feature/backend`: Backend bo'yicha ishlab chiqilayotgan faol tarmoq (Active Backend Branch).

