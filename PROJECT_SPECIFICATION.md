# 🏛️ UNIVER SuperApp - System Architecture & Project Specification

> **Document Version:** 1.1.0 (Updated with Real-World JDU / TOU Workflow)  
> **Status:** Active Architectural Blueprint  
> **Target Audience:** Core Developers, Contributors, and Academic Stakeholders  
> **Uzbek Translation / O'zbekcha Nusxasi:** [PROJECT_SPECIFICATION_UZ.md](file:///d:/personal_profile/PROJECT_SPECIFICATION_UZ.md)

---

## 1. 📌 Executive Summary & Problem Statement

### The Real-World University Context (JDU & Tokyo Online University Partnership)
At our university (Japan Digital University / Tokyo Online University), academic operations and student communications are conducted across multiple cloud platforms and Google Workspace environments:
1. **Multi-Space Fragmentation in Google Chat:**
   - Staff and deans distribute updates across separate Google Chat Spaces:
     - `学生センター学生用（Talabalar...）` (Central Student Center Space)
     - `23Eグループ（4期生）` (Group-specific space)
     - `日本語教育部学生用` (Japanese Language Department)
     - `東京通信大学 4期生` (TOU Academic Space)
     - `コーパスD` (Campus D Space)
2. **Disorganized Links & Platforms:** Different responsible staff members send individual links to separate platforms, forms, and portals, forcing students to manually search through Google Chat message histories.
3. **Live Google Sheets Timetable (`時間割/ Dars jadvali`):**
   - The official schedule is shared by staff (e.g., Masato Sonobe) as a **live Google Sheet** (`時間割/ Dars jadvali (2026/09～)`).
   - Staff updates this sheet progressively (*"bosqichma-bosqich kiritib boriladi"*).
   - **The Student Problem:** The Google Sheet is a massive multi-tab table (`2026年9月`, `WLU`, `JAPANESE`, `IT`, `PARTNER`, `Employability/Co-work`) with up to 10 room columns (`203`, `204`, `206`, `207`, `208`, `302`, `303`, `304`, `305`, `306`) and 6 class periods (`Para 1-6`). On mobile phones, students must endlessly pinch, zoom, and horizontally scroll to find their group's classes.
4. **Credential System:** The university issues official student email accounts to all students.

### The UNIVER SuperApp Solution
**UNIVER SuperApp** is a single, centralized web and mobile-ready platform that serves as a **Unified Student Experience Hub**. It delivers:
- **Live Google Sheets Schedule Sync:** Directly reads the official live Google Sheet without requiring staff to re-upload files or alter their workflow.
- **Group-Filtered Mobile Timetable:** Automatically maps the logged-in student's Group (e.g., `23E` / `IT`) to their exact classes, presenting a clean, modern daily schedule card.
- **Spaces & University Links Directory:** 1-click access to all official Google Chat Spaces, HEMIS, KD video courses, and university resources.
- **Student Profile Management:** Tracks Student ID (e.g., `2311195`), Group, Course (`4期生`), Direction, and personal credentials.

---

## 2. 👥 User Roles & Permissions Matrix

| Feature / Module | 👨‍🏫 University Staff & Administration | 🎓 Students |
| :--- | :---: | :---: |
| **Timetable Management** | ✅ Maintains live Google Sheet (`時間割`) in Google Drive | ❌ **View-only** (Zero upload burden) |
| **Schedule View** | ✅ Can inspect all rooms, directions & groups | ✅ Automatically sees **their group's** classes |
| **Google Chat Spaces & Links** | ✅ Posts links in Student Center / Chat spaces | ✅ 1-click access to all spaces from one hub |
| **Login Authentication** | Staff university account | **Official University Email** + Password |
| **Student ID & Profile** | Manages official student roster | Enters **Student ID** (e.g. `2311195`) in Profile |

---

## 3. 🔄 System Architecture & Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          1. UNIVERSITY STAFF WORKFLOW                       │
│  - Staff (Masato Sonobe) updates live Google Sheet:                         │
│    "時間割/ Dars jadvali (2026/09～)" in Google Drive                      │
│  - Staff posts updates & links into Google Chat:                            │
│    "学生センター学生用", "23Eグループ", "日本語教育部"                       │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     2. UNIVER SUPERAPP LIVE BRIDGE & BACKEND                │
│                                                                             │
│  ┌─────────────────────────┐   ┌─────────────────────────────────────────┐  │
│  │ Google Sheets Live Sync │──►│ Google Sheets API / CSV Stream Parser   │  │
│  │ (Sheet ID & GID Tabs)   │   │ Reads: IT, JAPANESE, WLU, 2026年9月     │  │
│  └─────────────────────────┘   └────────────────────┬────────────────────┘  │
│                                                     │                       │
│                                                     ▼                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Normalization Engine: Days (Sesh/Chor/Pay), Paras (1-6), Rooms (203+) │  │
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
│                       3. STUDENT PERSONALIZED EXPERIENCE                    │
│                                                                             │
│  1. Student logs in via Official University Email                           │
│  2. Profile identifies: Group = "23E", Direction = "IT", ID = "2311195"     │
│  3. App renders:                                                            │
│     ├── 📅 Personalized Daily Timetable (Filtered for Group 23E / Room 203) │
│     ├── 🚀 1-Click Spaces Hub (Jump to 学生センター, 23Eグループ, etc.)       │
│     └── 👤 Student Profile (Talaba ID, Course 4期生, Avatar, Info)          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 🧩 Core Technical Solutions & Decisions

### 4.1. The Timetable Bridge: Direct Google Sheets Live Ingestion
* **Real-World Discovery:** The schedule is a **live Google Sheet** shared with students as "View only" (`Saved to Drive`).
* **Technical Solution:**
  - Instead of requiring students or staff to upload files, UNIVER SuperApp connects directly to the public/view Google Sheet endpoint:
    `https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/gviz/tq?tqx=out:json&sheet={SHEET_NAME}`
  - **Zero Staff Friction:** Staff changes nothing about their routine. They edit cells in Google Drive, and UNIVER SuperApp reflects updates in real-time.
  - **Multi-Tab Handling:** Ingests directions individually: `IT`, `JAPANESE`, `WLU`, `PARTNER`.

### 4.2. Group-to-Schedule Mapping Algorithm
* **The Sheet Structure:**
  - **Rows:** Date, Day of Week (`(火) Sesh.`, `(水) Chor.`, `(木) Pay.`), Period (`Para 1` to `6`), Time Range (`9:00 ~ 10:15`...).
  - **Columns:** Rooms/Groups (`203`, `204`, `206`, `207`, `208`, `302`, `303`, `304`, `305`, `306`).
  - **Cells:** Lecture titles, interview sessions (`面接（日本語）`), conversation classes (`会話クラス 14:00~15:00`), orientation meetings (`日本語説明会`).
* **The Parser Action:** Extracts cell coordinates `(Day, Para, Room)` and maps them to the student's assigned group and room.

### 4.3. Authentication vs. Profile Separation
* **Login (`AuthPage.jsx` & `/api/auth/google/`):**
  - Uses **Official University Google Account (Google Workspace SSO)** (no registration friction).
  - Validates university domain (@jdu.uz exclusively) cryptographically with Google OAuth 2.0.
  - Automatically provisions Django `User` and `StudentProfile`, returning Django REST Framework SimpleJWT tokens (`access` & `refresh`).
  - Supports quick developer demo accounts for offline and testing agility.
  - Alternative email/password login is retained for backward compatibility.
* **Profile (`Profile.jsx`):**
  - Manages **`studentId`** (Talaba ID, e.g. `2311195`), **`group`** (`23E`), **`course`** (`4期生` / `4`), **`direction`** (`IT`), and personal avatar.
  - Displays verified university account status (`Tasdiqlangan Universitet Hisobi`).
  - The `group` field in the profile automatically drives the timetable filter.

---

## 5. 🗺️ Phased Implementation Roadmap

### 📍 Phase 1: Auth & Live Timetable (COMPLETED AUTH)
1. **Login & Auth Flow:**
   - University Google Workspace SSO via DRF SimpleJWT (`/api/auth/google/`).
   - Domain whitelisting (strictly `@jdu.uz`) and automatic student profile initialization.
2. **Student Profile Enhancement:**
   - Added `StudentProfile` Django model with `student_id`, `group`, `course`, `direction`, and avatar.
   - Enhanced [`frontend/src/pages/Profile.jsx`](file:///d:/personal_profile/frontend/src/pages/Profile.jsx) with `studentId` and verification badges.
3. **Live Google Sheet Timetable Parser:**
   - Ingest live spreadsheet data (`時間割/ Dars jadvali`).
   - Render clean daily class cards filtered by Group (`23E`) and Room.

### 📍 Phase 2: Google Chat Spaces & University Links Hub
1. **Spaces Directory Widget:**
   - Direct 1-click links to active Google Chat Spaces:
     - `学生センター学生用`
     - `23Eグループ`
     - `日本語教育部学生用`
     - `東京通信大学`
     - `コーパスD`
2. **External Portals:**
   - Direct integration links for HEMIS and KD video platforms.

### 📍 Phase 3: Grades & Attendance (Deferred)
- Official grade tracking and 85% attendance warning threshold.

### 📍 Phase 4: Video Lessons & Learning Materials (Future)
- Course video playback and lecture slides.

---

## 6. 🛠️ Tech Stack & Structure

```
personal_profile_demo/
├── backend/                        # Django 5 + Django REST Framework
│   ├── api/                        # Core API (JWT, Live Google Sheets Ingestion, Models)
│   ├── config/                     # Django Settings & Routing
│   └── requirements.txt            # Python dependencies
├── frontend/                       # React 19 + Vite 8
│   ├── src/
│   │   ├── components/             # AuthPage, Navbar, Sidebar, MobileBottomNav
│   │   ├── pages/                  # Timetable, Profile
│   │   └── utils/                  # Live Sheet Parser & formatters
│   └── package.json                # React dependencies
├── docker-compose.yml              # Container orchestration
├── README.md                       # Setup guide
├── CHANGELOG.md                    # Progress history
├── PROJECT_SPECIFICATION.md        # English Specification (This file)
└── PROJECT_SPECIFICATION_UZ.md     # Uzbek Specification
```
