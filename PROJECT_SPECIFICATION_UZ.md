# 🏛️ UNIVER SuperApp - Tizim Arxitekturasi va Loyiha Texnik Topshirig'i (Spetsifikatsiyasi)

> **Hujjat Versiyasi:** 1.1.0 (JDU / TOU real jarayonlari asosida yangilandi)  
> **Holati:** Faol Arxitektura Loyihasi  
> **Mo'ljallangan Auditoriya:** Asosiy Dasturchilar, Loyiha Ishtirokchilari va Universitet Mutasaddilari  
> **Inglizcha Asl Nusxa:** [PROJECT_SPECIFICATION.md](file:///d:/personal_profile/PROJECT_SPECIFICATION.md)

---

## 1. 📌 Umumiy Xulosa va Muammoning Qo'yilishi

### Universitetdagi Haqiqiy Vaziyat (JDU va Tokyo Online University Hamkorligi)
Universitetimizda (Japan Digital University / Tokyo Online University) o'quv jarayonlari va talabalar bilan aloqa bir nechta Google Workspace xizmatlari orqali olib boriladi:
1. **Google Chat (Spaces) dagi Tarqoqlik:**
   - Mas'ul xodimlar va dekanat xabarlarni alohida-alohida Google Chat xonalarida tarqatishadi:
     - `学生センター学生用（Talabalar...）` (Markaziy Talabalar Markazi Xonasi)
     - `23Eグループ（4期生）` (Muayyan guruh xonasi)
     - `日本語教育部学生用` (Yapon Tili Ta'limi Bo'limi)
     - `東京通信大学 4期生` (TOU Akademik Xonasi)
     - `コーパスD` (D Korpus Xonasi)
2. **Tartibsiz Havolalar va Tizimlar:** Turli mas'ul xodimlar Google Chat xonalarida turli shakllar, saytlar va portallarga havolalar yuborishadi. Talabalar kerakli manbani topish uchun xabarlar tarixini varaqlab chiqishga majbur bo'lishmoqda.
3. **Jonli Google Sheets Dars Jadvali (`時間割/ Dars jadvali`):**
   - Mas'ul xodim (masalan, Masato Sonobe) jadvalni yuklab olinadigan static Excel fayl emas, balki **jonli Google Sheet (`時間割/ Dars jadvali (2026/09～)`)** havolasi orqali ulashadi.
   - Xodimlar jadvalni vaqt o'tishi bilan to'ldirib borishadi (*"bosqichma-bosqich kiritib boriladi"*).
   - **Talabalar Uchun Noqulaylik:** Google Sheet juda keng jadval bo'lib, pastida bir nechta sahifalar (`2026年9月`, `WLU`, `JAPANESE`, `IT`, `PARTNER`, `Employability/Co-work`), 10 dan ortiq xonalar ustunlari (`203`, `204`, `206`, `207`, `208`, `302`, `303`, `304`, `305`, `306`) hamda 6 ta dars juftligi (`Para 1-6`) mavjud. Telefon orqali ochganda talaba o'z darsini topish uchun ekranni tinimsiz yaqinlashtirishi, o'ngga-chapga surishi talab etiladi.
4. **Universitet Email Tizimi:** Universitet barcha talabalarga rasmiy korporativ email hisoblarini taqdim etgan.

### UNIVER SuperApp Berayotgan Yechim
**UNIVER SuperApp** — bu tarqoqlikni to'liq bartaraf etuvchi, veb va mobil qurilmalarga moslashgan **Yagona Talaba Xabi** hisoblanadi. U quyidagilarni taqdim etadi:
- **Jonli Google Sheets Jadvali Sinxronizatsiyasi:** Xodimlarning Google Drive dagi jadvalini to'g'ridan-to'g'ri o'qiydi (xodimlar hech qanday yangi tizimga fayl yuklashi shart emas).
- **Guruh Bo'yicha Filtrlangan Mobil Jadval:** Tizimga kirgan talabaning guruhi (`23E` / `IT`) bo'yicha darslarni ajratib olib, qulay mobil kunlik kartochkalarda taqdim etadi.
- **Google Chat Xonalari va Havolalar Katalogi:** Barcha rasmiy xonalar (`学生センター`, `23Eグループ`, `日本語教育部`, `コーパスD`), HEMIS va KD video tizimlariga 1-bosishda ulanish.
- **Talaba Profili:** Talaba ID (`23E-014`), Guruh, Kurs (`4期生`), Yo'nalish va shaxsiy ma'lumotlarni boshqarish.

---

## 2. 👥 Foydalanuvchi Rollari va Ruxsatlar Matritsasi

| Funksiya / Modul | 👨‍🏫 Universitet Xodimlari & Adminlar | 🎓 Talabalar |
| :--- | :---: | :---: |
| **Dars Jadvalini Boshqarish** | ✅ Jonli Google Sheet (`時間割`) ni odatdagidek yuritadi | ❌ **Yuklash majburiyati yo'q** (Faqat ko'rish) |
| **Dars Jadvalini Ko'rish** | ✅ Barcha xonalar, guruhlar va sahifalarni ko'ra oladi | ✅ Avtomatik ravishda **faqat o'z guruhining** jadvalini ko'radi |
| **Google Chat Xonalari & Havolalar** | ✅ Havolalar va xabarlarni tegishli xonalarga joylaydi | ✅ Yagona xabdan barcha xonalarga 1-bosishda o'tadi |
| **Kirish (Autentifikatsiya)** | Xodim korporativ hisobi orqali | **Rasmiy Universitet Emaili** + Parol |
| **Talaba ID va Profil** | Rasmiy ro'yxatni nazorat qiladi | O'z **Talaba ID** sini (`23E-014`) Profilida kiritadi |

---

## 3. 🔄 Tizim Arxitekturasi va Ma'lumotlar Oqimi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    1. UNIVERSITET XODIMINING ISH JARAYONI                   │
│  - Mas'ul xodim (Masato Sonobe) Google Drive'dagi jonli Google Sheet'ni      │
│    to'ldirib boradi: "時間割/ Dars jadvali (2026/09～)"                      │
│  - Yangiliklar va havolalarni Google Chat xonalariga joylaydi:              │
│    "学生センター学生用", "23Eグループ", "日本語教育部"                       │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 2. UNIVER SUPERAPP JONLI KO'PRIK VA BACKEND                 │
│                                                                             │
│  ┌─────────────────────────┐   ┌─────────────────────────────────────────┐  │
│  │ Google Sheets Jonli Sync│──►│ Google Sheets API / CSV Oqim Tahlilchisi│  │
│  │ (Sheet ID & GID Tablar) │   │ O'qiydi: IT, JAPANESE, WLU, 2026年9月   │  │
│  └─────────────────────────┘   └────────────────────┬────────────────────┘  │
│                                                     │                       │
│                                                     ▼                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Ma'lumotlarni Ajratish: Hafta Kuni (Sesh/Chor/Pay), Paralar (1-6),    │  │
│  │ Xonalar (203+), Dars turlari (Suhbat, Ma'ruza, Imtihon)               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                     ▲                       │
│                                                     │                       │
│  ┌──────────────────────────────────────────────────┴────────────────────┐  │
│  │ REST API Endpoints (/api/auth/login/, /api/schedule/, /api/profile/)  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        3. TALABA SHAXSIY TAJRIBASI                          │
│                                                                             │
│  1. Talaba rasmiy universitet emaili orqali tizimga kiradi                  │
│  2. Profilidan ma'lumotlar olinadi: Guruh = "23E", Yo'nalish = "IT"         │
│  3. Ilova ekranda chiqaradi:                                                │
│     ├── 📅 Shaxsiy Kunlik Dars Jadvali (Faqat 23E guruhi / 203-xona darslari)│
│     ├── 🚀 1-Bosishda Xonalarga O'tish (学生センター, 23Eグループ, etc.)    │
│     └── 👤 Talaba Profili (Talaba ID: 23E-014, 4期生, Avatar, Guruh)        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 🧩 Asosiy Texnik Qarorlar va Yechimlar

### 4.1. Dars Jadvali Ko'prigi: Jonli Google Sheets Integratsiyasi
* **Haqiqiy Holat:** Dars jadvali yuklab olinadigan fayl emas, balki Google Drive'da yuritiladigan **jonli Google Sheet** jadvalidir.
* **Texnik Yechim:**
  - Talabalar yoki xodimlardan fayl yuklashni talab qilish o'rniga, UNIVER SuperApp to'g'ridan-to'g'ri ochiq ko'rish havolasiga ulanadi:
    `https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/gviz/tq?tqx=out:json&sheet={SHEET_NAME}`
  - **Xodimlar uchun 0% Qo'shimcha Ish:** Xodimlar Google Drive'dagi jadvalni odatdagidek o'zgartiraveradi, UNIVER SuperApp esa o'zgarishlarni real vaqtda avtomatik aks ettiradi.
  - **Ko'p Sahifali Jadval:** Yo'nalishlar bo'yicha ajratilgan tablar alohida tahlil qilinadi: `IT`, `JAPANESE`, `WLU`, `PARTNER`.

### 4.2. Guruhni Jadvalga Moslashtirish Algoritmi
* **Google Sheet Strukturasi:**
  - **Qatorlar:** Sana, Hafta Kuni (`(火) Sesh.`, `(水) Chor.`, `(木) Pay.`), Para (1–6), Vaqt oralig'i (`9:00 ~ 10:15`...).
  - **Ustunlar:** Xonalar/Guruhlar (`203`, `204`, `206`, `207`, `208`, `302`, `303`, `304`, `305`, `306`).
  - **Kataklar:** Dars nomlari, suhbat darslari (`面接（日本語）`), og'zaki nutq darslari (`会話クラス 14:00~15:00`), tushuntirish yig'ilishlari (`日本語説明会`).
* **Tahlilchi Vazifasi:** Katak koordinatalarini aniqlaydi va ularni talabaning guruhi (`23E`) hamda xonasiga moslashtirib ko'rsatadi.

### 4.3. Kirish va Profil Matritsasi
* **Kirish Sahifasi (`AuthPage.jsx`):**
  - **Rasmiy Universitet Emaili** va **Parol** orqali kirish (Django REST Framework SimpleJWT yordamida).
* **Profil Sahifasi (`Profile.jsx`):**
  - **`studentId`** (Talaba ID, masalan: `23E-014`), **`group`** (`23E`), **`course`** (`4`), **`direction`** (`IT`), hamda shaxsiy profil rasmi (avatar).
  - Profil ichidagi `group` ma'lumoti dars jadvali filtrini avtomatik boshqaradi.

---

## 5. 🗺️ Bosqichma-bosqich Rivojlanish Xaritasi (Roadmap)

### 📍 1-Bosqich: Autentifikatsiya va Jonli Dars Jadvali (HOZIRGI DIQQAT MARKAZI)
1. **Universitet Emaili Bilan Kirish:**
   - Django SimpleJWT orqali korporativ email bilan kirish (`/api/auth/login/`).
2. **Talaba Profilini Boyitish:**
   - [`frontend/src/pages/Profile.jsx`](file:///d:/personal_profile/frontend/src/pages/Profile.jsx) ga `studentId` maydonini qo'shish.
3. **Jonli Google Sheet Jadval Tahlilchisi:**
   - `時間割/ Dars jadvali` Google Sheet jadvalidan ma'lumotlarni avtomatik o'qish.
   - Guruh (`23E`) va xonalar bo'yicha ajratilgan chiroyli mobil dars kartochkalarini chiqarish.

### 📍 2-Bosqich: Google Chat Xonalari va Havolalar Markazi
1. **Google Chat Spaces Vidjeti:**
   - Rasmiy xonalarga 1-bosishda o'tish imkoni:
     - `学生センター学生用`
     - `23Eグループ`
     - `日本語教育部学生用`
     - `東京通信大学`
     - `コーパスD`
2. **Tashqi Tizimlar Havolalari:**
   - HEMIS va KD video platformalariga tezkor o'tish tugmalari.

### 📍 3-Bosqich: Baholar va Davomat (Keyingi Bosqich)
- Rasmiy baholar va davomat bo'yicha 85% ogohlantirish indikatorlari.

### 📍 4-Bosqich: Video Darsliklar va Resurslar (Kelajakda)
- Onlayn video darslar va dars slaydlarini yuklab olish bo'limi.

---

## 6. 🛠️ Loyiha Strukturasi

```
personal_profile_demo/
├── backend/                        # Django 5 + Django REST Framework
│   ├── api/                        # Asosiy API ilovasi (JWT, Google Sheets Ingestion, Modellar)
│   ├── config/                     # Django sozlamalari
│   └── requirements.txt            # Python kutubxonalari
├── frontend/                       # React 19 + Vite 8
│   ├── src/
│   │   ├── components/             # AuthPage, Navbar, Sidebar, MobileBottomNav
│   │   ├── pages/                  # Timetable, Profile
│   │   └── utils/                  # Google Sheet Parser & formatters
│   └── package.json                # React kutubxonalari
├── docker-compose.yml              # Konteynerlarni birga ishga tushiruvchi sozlama
├── README.md                       # Qisqa yo'riqnoma
├── CHANGELOG.md                    # O'zgarishlar jurnali
├── PROJECT_SPECIFICATION.md        # Inglizcha Spetsifikatsiya
└── PROJECT_SPECIFICATION_UZ.md     # O'zbekcha Spetsifikatsiya (Ushbu hujjat)
```
