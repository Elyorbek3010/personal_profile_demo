# 🏛️ UNIVER SuperApp - System Architecture & Project Specification

> **Document Version:** 1.0.0  
> **Status:** Active Architectural Blueprint  
> **Target Audience:** Core Developers, Contributors, and Academic Stakeholders

---

## 1. 📌 Executive Summary & Problem Statement

### The Real-World University Problem
At our university, academic operations and student communication are currently heavily fragmented:
1. **Scattered Communications:** Staff and deans distribute essential announcements, updates, and schedule changes through unstructured **Gmail chat groups** and emails.
2. **Disorganized Links:** Different responsible staff members send individual links to separate platforms, forms, and portals, forcing students to manually dig through email threads to find essential tools.
3. **Inconvenient Schedule Formats:** Timetables are shared as complex, multi-tabbed **Excel files (`.xlsx` / `.xls`)** with merged cells, making it difficult and frustrating for students to quickly check their daily classes on their phones or laptops.
4. **Data Silos:** Student credentials, grades, and schedules are held exclusively by university staff, with no direct student API integration available initially.

### The UNIVER SuperApp Solution
**UNIVER SuperApp** is a single, centralized web and mobile-ready platform that serves as a **Unified Academic Hub**. It brings together:
- **Centralized Links & Portals Directory:** All official university tools, staff links, and department portals in one place.
- **Staff-Managed Smart Timetable:** Master schedules uploaded once by staff, parsed intelligently, and delivered automatically to students filtered by their group.
- **Personalized Student Dashboard:** Clean daily class cards, attendance indicators, and academic updates.
- **Future Academic Modules:** Grades tracking, attendance warnings, and lecture resource libraries.

---

## 2. 👥 User Roles & Permissions Matrix

To prevent data chaos, the system establishes a strict separation between **content managers** (Staff) and **content consumers** (Students).

| Feature / Module | 👨‍🏫 University Staff & Admins | 🎓 Students |
| :--- | :---: | :---: |
| **Schedule / Excel Upload** | ✅ **Full Control** (Uploads & updates master `.xlsx`) | ❌ **No Upload** (View-only for their group) |
| **Student Timetable View** | ✅ Can inspect all groups and faculties | ✅ Automatically sees **only their group's** classes |
| **University & Staff Links** | ✅ Adds, categorizes, and updates official links | ✅ 1-click access to all active links |
| **Grades & Attendance Data** | ✅ Enters / updates academic records | ✅ View-only personal academic analytics |
| **Announcements / Feed** | ✅ Publishes verified notices | ✅ Reads real-time notices |
| **Account Credentials** | Staff credentials / Admin portal | Student ID (e.g. `U2110045`) + Email |

---

## 3. 🔄 System Architecture & Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          1. UNIVERSITY STAFF ACTION                         │
│  - Uploads Master Timetable (.xlsx)                                         │
│  - Adds Official Staff Links & Announcements                                │
│  - Manages Grade Records                                                    │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     2. DJANGO REST BACKEND & AI PIPELINE                    │
│                                                                             │
│  ┌───────────────────────┐   ┌────────────────────────┐                     │
│  │   Excel Ingestion     │   │   AI Structure Engine  │                     │
│  │   (Openpyxl / Pandas) │──►│   (Layout Extraction)  │                     │
│  └───────────────────────┘   └───────────┬────────────┘                     │
│                                          │                                  │
│                                          ▼                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Relational Database (Groups, Subjects, Rooms, Times, Staff Links)     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                          ▲                                  │
│                                          │ (Adapter / Service Layer)        │
│                                          ▼                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ REST API Endpoints (/api/auth/, /api/schedule/, /api/links/)          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       3. STUDENT FRONTEND EXPERIENCE                        │
│  - Student logs in with Student ID (e.g. U2110045)                          │
│  - System identifies Group (e.g. Group 304 - Software Engineering)          │
│  - Delivers:                                                                │
│    ├── 📅 Group's Official Timetable (Today & Week View)                     │
│    ├── 🔗 1-Click Directory of All Staff & University Links                 │
│    └── 📢 Verified Announcements Feed (No Gmail Clutter)                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 🧩 Core Technical Solutions & Decisions

### 4.1. The Data Access Dilemma: Mock / Seed Data Strategy
* **Context:** Developers do not currently possess production credentials or live database access to the university's internal systems.
* **Solution:** We implement a **Contract-First Mock & Seed Data Architecture**:
  - Realistic seed fixtures (`python manage.py seed_data`) provide sample student profiles (e.g., Student ID `U2110045`, Group `304`).
  - An **Adapter / Service Layer** sits between the API views and the data storage.
  - **Zero Frontend Refactoring Later:** The frontend always calls standardized endpoints (`GET /api/schedule/my-schedule/`, `GET /api/links/`). When the university provides real APIs (e.g., HEMIS / LDAP / Active Directory), only the Django service adapter is updated.

### 4.2. The Excel Layout Challenge: Smart / AI Parser
* **Context:** University Excel schedules change layout frequently, contain merged header cells, and span dozens of columns. Hardcoded scripts break whenever formats change.
* **Solution:**
  - Staff uploads the master `.xlsx` file via the backend interface.
  - The parsing pipeline normalizes cell merges and passes table schemas to an AI extractor.
  - The extractor maps rows to standard database entities:
    `Group` ➔ `Day of Week` ➔ `Time Slot` ➔ `Course` ➔ `Teacher` ➔ `Room` ➔ `Type`.

### 4.3. Authentication Strategy (Hybrid Model)
* **Pre-seeded Accounts:** Immediate 1-click test login for development and evaluation.
* **Student Self-Registration:** Allows colleagues and testers to create accounts with custom Student IDs.
* **JWT Tokens:** `rest_framework_simplejwt` with short-lived access tokens and secure refresh rotation.

---

## 5. 🗺️ Phased Implementation Roadmap

To ensure high quality, each milestone is built and verified iteratively before advancing.

### 📍 Phase 1: Authentication & Core Schedule (CURRENT FOCUS)
1. **Backend Student Profile Model:**
   - Extend Django `User` with `StudentProfile` (`student_id`, `group_name`, `faculty`).
   - Create initial database migrations and seed script.
2. **Connect Frontend Auth:**
   - Link [`frontend/src/components/AuthPage.jsx`](file:///d:/personal_profile/frontend/src/components/AuthPage.jsx) to Django's SimpleJWT endpoints (`/api/auth/login/` and `/api/auth/register/`).
   - Store access and refresh tokens in state and `localStorage`.
3. **Staff Schedule Upload & Processing:**
   - Build backend endpoint `POST /api/schedule/upload/` for staff.
   - Implement group schedule storage and student retrieval (`GET /api/schedule/my/`).

### 📍 Phase 2: Centralized University & Staff Links Hub
1. **Links Data Model:**
   - Categories: Dean's Office, LMS / Moodle, Library, Department Telegram Channels, Staff Contacts.
2. **Interactive Directory Component:**
   - Modern, searchable card layout allowing 1-click access to all staff resources.

### 📍 Phase 3: Grades & Attendance Analytics (Deferred)
1. **Staff Grade Input:**
   - Data entry endpoint for semester evaluations.
2. **Student Dashboard:**
   - GPA calculation and 85% attendance warning badges.

### 📍 Phase 4: KD Video Player & Resource Hub (Future)
- Video course player and downloadable lecture materials.

---

## 6. 🛠️ Tech Stack & Directory Structure

```
personal_profile_demo/
├── backend/                        # Django 5 + Django REST Framework
│   ├── api/                        # Core API Application
│   │   ├── models.py               # StudentProfile, Group, Schedule, Links
│   │   ├── serializers.py          # Data serialization & validation
│   │   ├── views.py                # REST Controllers
│   │   └── urls.py                 # API Routing
│   ├── config/                     # Settings, ASGI/WSGI, Root URLs
│   ├── requirements.txt            # Python dependencies
│   └── Dockerfile                  # Python 3.12 container
├── frontend/                       # React 19 + Vite 8
│   ├── src/
│   │   ├── components/             # Reusable UI (AuthPage, Navbar, Sidebar)
│   │   ├── pages/                  # Views (Timetable, Links Hub)
│   │   └── App.jsx                 # Root layout & routing
│   ├── package.json                # Node dependencies
│   └── Dockerfile                  # Node 20 container
├── docker-compose.yml              # Multi-container orchestration
├── README.md                       # Quickstart instructions
├── CHANGELOG.md                    # Historical record of changes
└── PROJECT_SPECIFICATION.md        # This document
```

---

## 7. 🚀 Verification & Testing Protocol

As each feature is implemented, it must pass the following checks:
1. **Unit & Integration Check:** Verify backend responses using Django test runner / REST client (`status == 200 OK`).
2. **Cross-Service Testing:** Verify that actions triggered on the React frontend properly persist and read data from the Django backend.
3. **Docker Consistency:** Ensure services run reliably both locally and through `docker compose up`.
