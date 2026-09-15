# 🎓 UNIVER SuperApp - Talabalar uchun Yagona Platforma (Frontend MVP)

Univer SuperApp — Universitet talabalari uchun dars jadvallarini Excel fayllaridan avtomatik o'qib beruvchi, baholar va davomat ko'rsatkichlarini monitoring qiluvchi hamda KD video darsliklariga tezkor ulanuvchi yagona platforma.

---

## 🚀 Texnologiyalar Steki (Tech Stack)

- **Frontend Framework**: React 19 + Vite 8
- **Styling**: Tailwind CSS v4 (Glassmorphism design system & Dark Mode)
- **Icons**: Lucide React
- **Excel Parser**: SheetJS (`xlsx`)
- **Analytics & Graphs**: Recharts
- **Auth Standarti**: Email & Password (Django REST Framework JWT token state)
- **Mobile Support**: PWA Ready & Mobile Responsive Bottom Navigation Bar

---

## 🛠️ Sherigingiz (Colleague) uchun Ishga Tushirish Yo'riqnomasi

Loyihani kompyuteringizga ko'chirib olib, 1 minutda ishga tushirish uchun quyidagi 3 ta buyruqni bajaring:

### 1. Omborni ko'chirib olish (Clone):
```bash
git clone https://github.com/Elyorbek3010/personal_profile_demo.git
cd personal_profile_demo
git checkout feature/frontend
```

### 2. Kutubxonalarni o'rnatish (Install Dependencies):
```bash
npm install
```

### 3. Serverni ishga tushirish (Run Dev Server):
```bash
npm run dev
```

Brauzerda `http://localhost:5173` (yoki ko'rsatilgan port) manzilini oching!

---

## 📁 Loyiha Strukturasi (Project Structure)

```
personal_profile_demo/
├── src/
│   ├── components/
│   │   ├── AuthPage.jsx           # Email & Parol login/register sahifasi
│   │   ├── Navbar.jsx             # Yuqori menyu va Logout tugmasi
│   │   ├── Sidebar.jsx            # Chap tomondagi asosiy navigatsiya
│   │   └── MobileBottomNav.jsx    # Mobil telefonlar uchun pastki menyu
│   ├── pages/
│   │   └── Timetable.jsx          # Smart Dars Jadvali & Excel AI Parser
│   ├── data/
│   │   └── mockSchedule.js        # Test dars jadvali ma'lumotlari
│   ├── utils/
│   │   └── excelParser.js         # Excel (.xlsx) fayllarni o'quvchi algoritm
│   ├── App.jsx                    # Asosiy ilova komponenti
│   └── index.css                  # Tailwind CSS v4 va maxsus stillar
```

---

## 🌿 Git Branches

- `main`: Asosiy barqaror tarmoq (Base Branch).
- `feature/frontend`: Frontend bo'yicha ishlab chiqilayotgan faol tarmoq (Active Feature Branch).
