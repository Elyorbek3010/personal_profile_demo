# 🏛️ UNIVER SuperApp - Tizim Arxitekturasi va Loyiha Texnik Topshirig'i (Spetsifikatsiyasi)

> **Hujjat Versiyasi:** 1.0.0  
> **Holati:** Faol Arxitektura Loyihasi  
> **Mo'ljallangan Auditoriya:** Asosiy Dasturchilar, Loyiha Ishtirokchilari va Universitet Mutasaddilari  
> **Inglizcha Asl Nusxa:** [PROJECT_SPECIFICATION.md](file:///d:/personal_profile/PROJECT_SPECIFICATION.md)

---

## 1. 📌 Umumiy Xulosa va Muammoning Qo'yilishi

### Universitetdagi Haqiqiy Muammo
Hozirgi vaqtda universitetimizda o'quv jarayonlari va talabalar bilan aloqa juda tarqoq holatda olib borilmoqda:
1. **Tarqoq Xabarlar va Guruhlar:** Mas'ul xodimlar va dekanat muhim e'lonlar, o'zgarishlar va dars jadvallarini tuzilmagan **Gmail chat guruhlari** va emaillar orqali tarqatishadi.
2. **Tartibsiz Havolalar (Links):** Har bir mas'ul xodim turli platformalar, shakllar va portallarga o'z havolalarini alohida yuboradi. Natijada talabalar kerakli manbalarni topish uchun email va chatlarni titkilashga majbur bo'lishmoqda.
3. **Noqulay Dars Jadvali Formati:** Dars jadvallari kataklari birlashtirilgan (merged cells), ko'p sahifali murakkab **Excel fayllar (`.xlsx` / `.xls`)** ko'rinishida yuboriladi. Bu talabalarga telefon yoki noutbukda o'z darslarini tezda ko'rish uchun jiddiy noqulaylik tug'diradi.
4. **Yopiq Ma'lumotlar:** Talabalar hisob ma'lumotlari, baholar va jadvallar faqat mas'ul xodimlarda saqlanadi va talabalar uchun to'g'ridan-to'g'ri integratsiya qilingan ochiq API mavjud emas.

### UNIVER SuperApp Berayotgan Yechim
**UNIVER SuperApp** — bu barcha tarqoqlikni bartaraf etuvchi, veb va mobil qurilmalarga moslashgan **Yagona Universitet Akademik Xabi (Platformasi)** hisoblanadi. U o'z ichiga quyidagilarni jamlaydi:
- **Markazlashtirilgan Havolalar va Portallar Katalogi:** Barcha rasmiy universitet tizimlari, xodimlar havolalari va dekanat portallari bitta qulay sahifada.
- **Mas'ul Xodimlar Boshqaruvidagi Aqlli Dars Jadvali:** Xodimlar tomonidan bir marta yuklangan master Excel jadvali tizim tomonidan tahlil qilinadi va har bir talabaga faqat uning guruhiga mos ravishda avtomatik ko'rsatiladi.
- **Shaxsiylashtirilgan Talaba Paneli:** Har bir kun uchun darslar kartochkalari, davomat ko'rsatkichlari va rasmiy yangiliklar.
- **Kelgusi Akademik Bo'limlar:** Baholar monitoringi, davomat bo'yicha 85% ogohlantirish burchaklari va darslik materiallari kutubxonasi.

---

## 2. 👥 Foydalanuvchi Rollari va Ruxsatlar Matritsasi

Tizimda tartibsizlik bo'lmasligi uchun ma'lumotlarni **boshqaruvchilar (Xodimlar)** va **iste'molchilar (Talabalar)** rollari qat'iy ajratilgan:

| Funksiya / Modul | 👨‍🏫 Universitet Xodimlari & Adminlar | 🎓 Talabalar |
| :--- | :---: | :---: |
| **Jadval / Excel Yuklash** | ✅ **To'liq Nazorat** (Master `.xlsx` yuklaydi va yangilaydi) | ❌ **Yuklash huquqi yo'q** (Faqat ko'rish) |
| **Dars Jadvalini Ko'rish** | ✅ Barcha guruhlar va fakultetlarni ko'ra oladi | ✅ Avtomatik ravishda **faqat o'z guruhining** jadvalini ko'radi |
| **Universitet & Xodim Havolalari** | ✅ Havolalarni qo'shadi, toifalarga ajratadi va yangilaydi | ✅ Barcha faol havolalarga 1-bosishda ulanish |
| **Baholar va Davomat Ma'lumotlari** | ✅ Akademik baho va ko'rsatkichlarni kiritadi | ✅ Faqat o'zining baho va davomat statistikasini ko'radi |
| **Rasmiy E'lonlar** | ✅ Tasdiqlangan rasmiy xabarlarni chop etadi | ✅ Yangiliklar tasmasini real vaqtda o'qiydi |
| **Kirish Ma'lumotlari** | Xodim logini / Admin panel orqali | Talaba ID (masalan, `U2110045`) + Email |

---

## 3. 🔄 Tizim Arxitekturasi va Ma'lumotlar Oqimi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       1. UNIVERSITET XODIMINING HARAKATI                    │
│  - Asosiy dars jadvalini (.xlsx) yuklaydi                                   │
│  - Rasmiy xodimlar havolalari va e'lonlarini joylashtiradi                  │
│  - Baho va davomat ma'lumotlarini boshqaradi                                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 2. DJANGO REST BACKEND VA AI TAHLIL QILUVCHI                │
│                                                                             │
│  ┌───────────────────────┐   ┌────────────────────────┐                     │
│  │   Excel Ingestion     │   │   AI Tahlil Dvigateli  │                     │
│  │   (Openpyxl / Pandas) │──►│  (Strukturani Ajratish)│                     │
│  └───────────────────────┘   └───────────┬────────────┘                     │
│                                          │                                  │
│                                          ▼                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Aloqador Ma'lumotlar Bazasi (Guruhlar, Fanlar, Xonalar, Havolalar)    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                          ▲                                  │
│                                          │ (Adapter / Xizmat Qatlami)       │
│                                          ▼                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ REST API Endpoints (/api/auth/, /api/schedule/, /api/links/)          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         3. TALABA FRONTEND TAJRIBASI                        │
│  - Talaba o'z Student ID raqami bilan kiradi (masalan: U2110045)            │
│  - Tizim uning guruhini taniydi (masalan: 304-guruh, Dasturiy Injiniring)    │
│  - Talabaga taqdim etiladi:                                                 │
│    ├── 📅 Guruhning Rasmiy Jadvali (Bugun va Hafta bo'yicha)                │
│    ├── 🔗 Barcha Xodim va Universitet Havolalari Yagona Xabi                │
│    └── 📢 Rasmiy Yangiliklar (Gmail qidirishga chek qo'yildi)               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 🧩 Asosiy Texnik Qarorlar va Muammolar Yechimi

### 4.1. Ma'lumotlarga Kirish Muammosi: Test (Mock / Seed) Ma'lumotlar Strategiyasi
* **Vaziyat:** Dasturchilar hozircha universitetning ichki ma'lumotlar bazasiga to'g'ridan-to'g'ri ishlab chiqarish ulanishlariga ega emas.
* **Yechim:** Biz **Standart Shartnomaga Asoslangan Mock / Seed Ma'lumotlar Arxitekturasini** qo'llaymiz:
  - Real hayotga mos test skriptlari (`python manage.py seed_data`) orqali talaba profillari yaratiladi (masalan: Talaba ID: `U2110045`, Guruh: `304`).
  - API ko'rinishlari va baza o'rtasida **Adapter (Xizmat Qatlami)** o'rnatiladi.
  - **Kelajakda Frontendni Qayta Yozishga Hojat Qolmaydi:** Frontend har doim bitta standart endpointga murojaat qiladi (`GET /api/schedule/my-schedule/`, `GET /api/links/`). Keyinchalik universitet rasmiy tizim ulanishini (masalan, HEMIS / LDAP) taqdim etganda, faqat backenddagi adapter yangilanadi. Frontend bundan zarracha o'zgarmaydi.

### 4.2. Excel Jadvali Muammosi: Aqlli / AI Tahlil Dvigateli
* **Vaziyat:** Universitet Excel jadvallari har semestr o'zgarishi, birlashgan kataklar va o'nlab guruhlarga bo'lingan murakkab matritsalardan iborat bo'lishi mumkin. Oddiy qat'iy kodlangan skriptlar birinchi o'zgarishdayoq ishdan chiqadi.
* **Yechim:**
  - Xodim asosiy `.xlsx` faylni tizim orqali yuklaydi.
  - Tizim kataklarni tartibga soladi va AI tahlilchisi yordamida har bir darsni standart ob'ektlarga o'giradi:
    `Guruh` ➔ `Hafta Kuni` ➔ `Dars Vaqti` ➔ `Fan Nomi` ➔ `O'qituvchi` ➔ `Xona` ➔ `Dars Turi`.

### 4.3. Autentifikatsiya (Kirish) Strategiyasi
* **Tayyor Demo Hisoblar:** Ishlab chiqish va loyihani namoyish etishda 1-bosish bilan tizimga kirish imkoniyati.
* **Mustaqil Ro'yxatdan O'tish:** Jamoa a'zolari va hamkorlarga yangi hisob va Student ID ochib test qilish imkoni.
* **JWT Tokenlar:** Xavfsiz SimpleJWT mexanizmi orqali sessiyalarni boshqarish.

---

## 5. 🗺️ Bosqichma-bosqich Rivojlanish Xaritasi (Roadmap)

Sifatni kafolatlash uchun har bir bosqich navbati bilan amalga oshiriladi va sinovdan o'tkaziladi:

### 📍 1-Bosqich: Autentifikatsiya va Asosiy Jadval (HOZIRGI DIQQAT MARKAZI)
1. **Backend Talaba Modeli:**
   - Django `User` modelini `StudentProfile` (`student_id`, `group_name`, `faculty`) bilan kengaytirish.
   - Boshlang'ich migratsiyalar va demo seed ma'lumotlarni yaratish.
2. **Frontend Kirish Sahifasini Backendga Ulash:**
   - [`frontend/src/components/AuthPage.jsx`](file:///d:/personal_profile/frontend/src/components/AuthPage.jsx) ni Django SimpleJWT API ga ulash (`/api/auth/login/` va `/api/auth/register/`).
   - Tokenlarni saqlash va tekshirish.
3. **Xodimlar Jadvalini Qabul Qilish va Guruh Ko'rinishi:**
   - Xodimlar uchun `POST /api/schedule/upload/` endpointini qurish.
   - Talabaga o'z guruhining jadvalini beruvchi `GET /api/schedule/my/` ni yo'lga qo'yish.

### 📍 2-Bosqich: Markazlashtirilgan Universitet va Xodim Havolalari Xabi
1. **Havolalar Ma'lumot Modeli:**
   - Toifalar: Dekanat, LMS / Moodle, Kutubxona, Kafedra Telegram Kanallari, Mas'ul Xodimlar Kontaktlari.
2. **Interaktiv Havolalar Komponenti:**
   - Qidiruv tizimiga ega, 1-bosishda barcha kerakli sayt va manbalarni ochib beruvchi qulay interfeys.

### 📍 3-Bosqich: Baholar va Davomat Tahlili (Keyingi Bosqich)
1. **Xodimlar Tomonidan Baholarni Kiritish:**
   - Semestr natijalarini kiritish bo'limi.
2. **Talaba Statistikasi:**
   - GPA hisoblagichi va 85% dan past davomat bo'yicha ogohlantirish indikatorlari.

### 📍 4-Bosqich: KD Video Darslar va Resurslar (Kelajakda)
- Onlayn video darsliklar va slayd/resurslarni yuklab olish imkoniyati.

---

## 6. 🛠️ Texnologiyalar Steki va Loyiha Strukturasi

```
personal_profile_demo/
├── backend/                        # Django 5 + Django REST Framework
│   ├── api/                        # Asosiy API ilovasi
│   │   ├── models.py               # StudentProfile, Group, Schedule, Links
│   │   ├── serializers.py          # Ma'lumotlarni tekshirish va JSON qilish
│   │   ├── views.py                # REST kontrollerlari
│   │   └── urls.py                 # API marshrutlari
│   ├── config/                     # Django loyiha sozlamalari
│   ├── requirements.txt            # Python kutubxonalari
│   └── Dockerfile                  # Python 3.12 konteyneri
├── frontend/                       # React 19 + Vite 8
│   ├── src/
│   │   ├── components/             # Qayta ishlatiluvchi UI (AuthPage, Navbar, Sidebar)
│   │   ├── pages/                  # Sahifalar (Timetable, Links Hub)
│   │   └── App.jsx                 # Asosiy ilova komponenti
│   ├── package.json                # Node kutubxonalari
│   └── Dockerfile                  # Node 20 konteyneri
├── docker-compose.yml              # Konteynerlarni birga ishga tushiruvchi sozlama
├── README.md                       # Qisqa yo'riqnoma
├── CHANGELOG.md                    # Amalga oshirilgan ishlar tarixi
├── PROJECT_SPECIFICATION.md        # Asosiy texnik spetsifikatsiya (Inglizcha)
└── PROJECT_SPECIFICATION_UZ.md     # Ushbu hujjat (O'zbek tilida)
```

---

## 7. 🚀 Sinov va Tekshirish Qoidalari

Har bir yangi funksiya quyidagi sinovlardan o'tishi shart:
1. **Integratsiya Sinovi:** Django testlari orqali har bir API to'g'ri javob berayotgani (`200 OK`).
2. **Frontend-Backend Bog'lanishi:** React interfeysidagi harakatlar Django bazasiga to'g'ri yozilishi va o'qilishi.
3. **Docker Mosligi:** Tizim `docker compose up` buyrug'i orqali xatolarsiz ishga tushishi.
