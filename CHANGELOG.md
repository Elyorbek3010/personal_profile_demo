# 📝 UNIVER SuperApp - Project Changelog & Progress Tracker

Ushbu hujjat jamoamiz a'zolari (kollegalar) uchun loyihada amalga oshirilgan barcha o'zgarishlar, hozirgi holat va keyingi topshiriqlar xaritasidir.

---

## 📌 Hozirgacha Amalga Oshirilgan Ishlar (Completed Features)

### 1. 🔐 Email & Parol Autentifikatsiyasi (`src/components/AuthPage.jsx`)
- Kirish (Login) va Ro'yxatdan O'tish (Register) shakllari **faqat Email hamda Parol** orqali ishlashi yo'lga qo'yildi.
- Parolni ko'rsatish/yashirish (Eye icon) va parolni tasdiqlash (`confirmPassword`).
- **Django REST Framework (DRF) JWT Auth Token** holati saqlanmoqda (`localStorage` ichida `access_token`, `refresh_token` hamda `user_info`).
- 1-click **"Demo ma'lumotlar"** tugmasi orqali test qilish imkoniyati.

### 2. 📅 Smart Dars Jadvali & Excel AI Parser (`src/pages/Timetable.jsx`)
- Universitet taqdim etgan dars jadvali Excel (`.xlsx` / `.xls`) fayllarini brauzerning o'zida tahlil qiluvchi algoritm (`src/utils/excelParser.js`).
- **Haftalik kunlar (Dushanba - Shanba)** bo'yicha filter va darslar kartochkalari.
- Dars vaqti, turi (Ma'ruza, Amaliyot, Laboratoriya), xona raqami (`304-xona`), o'qituvchi ismi hamda **Davomat majburiyligi** nishoni.
- **AI Qidiruv**: Fan nomi, xona raqami yoki o'qituvchi ismi bo'yicha real-time qidiruv va filter chiplari.

### 3. 📱 Mobil Moslashuvchanlik & Pastki Menyu (`src/components/MobileBottomNav.jsx`)
- Telefonlar uchun barmog'ingiz bilan teginishga qulay bo'lgan **Pastki Navigatsiya Bari** (`< lg:hidden`).
- Barcha kartochkalar, kirish sahifasi va haftalik kunlar scroll o'qi bo'yicha javob beruvchi (responsive) CSS sozlamalari.

### 4. 🚪 Chiqish (Logout) Imkoniyati
- Yuqori menyu (Navbar) hamda Yon panelda (Sidebar) qizil **"Chiqish" (Logout)** tugmasi o'rnatildi. Tugma bosilganda `localStorage` tozalanib, qayta Kirish sahifasiga yo'naltiradi.

### 5. 🌿 Git & Branch Sozlamalari
- `main` hamda `feature/frontend` tarmoqlari sinxronlashtirildi va GitHub repository ga push qilindi:
  `https://github.com/Elyorbek3010/personal_profile_demo.git`

---

## 🗂️ Asosiy Fayllar Xaritasi (Key Files Overview)

| Fayl yo'li | Vaziifasi |
| :--- | :--- |
| `src/App.jsx` | Asosiy ilova kontenti, auth holati va menyu navigatsiyasi |
| `src/components/AuthPage.jsx` | Email va Parol bilan Kirish va Ro'yxatdan o'tish |
| `src/pages/Timetable.jsx` | Smart Dars Jadvali va Excel parser UI |
| `src/utils/excelParser.js` | SheetJS (`xlsx`) orqali Excel jadvalini JSON ga o'giruvchi funksiya |
| `src/data/mockSchedule.js` | Test dars jadvali ma'lumotlari |
| `src/components/Navbar.jsx` | Top header, qidiruv va Logout tugmasi |
| `src/components/Sidebar.jsx` | Desktop yon menyusi va Logout tugmasi |
| `src/components/MobileBottomNav.jsx` | Mobil pastki menyu |
| `src/index.css` | Tailwind CSS v4 hamda Glassmorphism utilities |

---

## 🎯 Navbatdagi Vafifalar (Remaining Tasks for Colleagues)

1. **📊 Baholar va Davomat Dashboard (`GradesAttendance.jsx`)**:
   - GPA ko'rsatkichi (3.84 / 4.0).
   - 85% davomat monitoringi va ogohlantirish burchaklari.
   - Recharts grafiklari orqali semestrlar tahlili.

2. **🎥 KD Video Darsliklar Hubi (`KDLessons.jsx`)**:
   - Video darslar pleeri, slaydlar va resurslar ro'yxati.

3. **⚙️ Admin / Dekanat Data Import Hub**:
   - Universitet dekanati xodimlari uchun bitta joydan fakultet Excel jadvallarini yuklash va boshqarish bo'limi.

---

## 💡 Ishni Davom Ettirish uchun Ko'rsatma
Sherigingiz loyihani ko'chirib olgach, quyidagi buyruqlar bilan ishni davom ettirishi mumkin:
```bash
git clone https://github.com/Elyorbek3010/personal_profile_demo.git
cd personal_profile_demo
npm install
npm run dev
```
