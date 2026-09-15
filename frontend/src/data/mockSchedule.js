export const INITIAL_SCHEDULE = {
  faculty: "Kompuyter Muhandisligi va Axborot Texnologiyalari",
  group: "KI-21-04",
  semester: "5-Semestr (2026)",
  days: [
    {
      day: "Dushanba",
      short: "Du",
      date: "15-Sentabr",
      classes: [
        {
          id: 101,
          time: "09:00 - 10:20",
          subject: "Algoritmlar va Ma'lumotlar Strukturasi",
          type: "Ma'ruza",
          teacher: "Prof. Alisher Rahimov",
          room: "304-xona",
          building: "A-Bino (3-qavat)",
          status: "completed",
          attendanceRequired: true
        },
        {
          id: 102,
          time: "10:30 - 11:50",
          subject: "Algoritmlar va Ma'lumotlar Strukturasi",
          type: "Amaliyot",
          teacher: "Assis. Nodira Qosimova",
          room: "Lab-12",
          building: "B-Bino (1-qavat)",
          status: "ongoing",
          attendanceRequired: true
        },
        {
          id: 103,
          time: "12:30 - 13:50",
          subject: "Veb Dasturlash (React & Node.js)",
          type: "Ma'ruza",
          teacher: "Dr. Jasur Yusupov",
          room: "402-xona",
          building: "A-Bino (4-qavat)",
          status: "upcoming",
          attendanceRequired: true
        }
      ]
    },
    {
      day: "Seshanba",
      short: "Se",
      date: "16-Sentabr",
      classes: [
        {
          id: 201,
          time: "09:00 - 10:20",
          subject: "Ma'lumotlar Bazasi Tizimlari (PostgreSQL)",
          type: "Ma'ruza",
          teacher: "Prof. Bobur Malikov",
          room: "210-xona",
          building: "A-Bino (2-qavat)",
          status: "upcoming",
          attendanceRequired: true
        },
        {
          id: 202,
          time: "10:30 - 11:50",
          subject: "Ma'lumotlar Bazasi Tizimlari (PostgreSQL)",
          type: "Laboratoriya",
          teacher: "Assis. Sardor Saidov",
          room: "Lab-08",
          building: "B-Bino",
          status: "upcoming",
          attendanceRequired: true
        },
        {
          id: 203,
          time: "12:30 - 13:50",
          subject: "Operatsion Tizimlar (Linux/Unix)",
          type: "Amaliyot",
          teacher: "Dr. Malika Ahmedova",
          room: "105-xona",
          building: "C-Bino",
          status: "upcoming",
          attendanceRequired: true
        }
      ]
    },
    {
      day: "Chorshanba",
      short: "Cho",
      date: "17-Sentabr",
      classes: [
        {
          id: 301,
          time: "09:00 - 10:20",
          subject: "Sun'iy Intelekt va Mashinaviy O'rgatish",
          type: "Ma'ruza",
          teacher: "Prof. Otabek Karimov",
          room: "Amfiteatr-1",
          building: "Bosh Bino",
          status: "upcoming",
          attendanceRequired: true
        },
        {
          id: 302,
          time: "10:30 - 11:50",
          subject: "Kiberxavfsizlik Asoslari",
          type: "Ma'ruza",
          teacher: "Dr. Farrukh Azimov",
          room: "308-xona",
          building: "A-Bino",
          status: "upcoming",
          attendanceRequired: true
        }
      ]
    },
    {
      day: "Payshanba",
      short: "Pay",
      date: "18-Sentabr",
      classes: [
        {
          id: 401,
          time: "09:00 - 10:20",
          subject: "Kompuyter Tarmoqlari (Cisco CCNA)",
          type: "Laboratoriya",
          teacher: "Assis. Timur Valiyev",
          room: "NetLab-02",
          building: "C-Bino",
          status: "upcoming",
          attendanceRequired: true
        },
        {
          id: 402,
          time: "10:30 - 11:50",
          subject: "Veb Dasturlash (React & DRF)",
          type: "Amaliyot",
          teacher: "Dr. Jasur Yusupov",
          room: "Lab-15",
          building: "B-Bino",
          status: "upcoming",
          attendanceRequired: true
        }
      ]
    },
    {
      day: "Juma",
      short: "Ju",
      date: "19-Sentabr",
      classes: [
        {
          id: 501,
          time: "09:00 - 10:20",
          subject: "Mobil Ilovalar Dasturlash (React Native)",
          type: "Ma'ruza",
          teacher: "Dr. Sherzod Umarov",
          room: "301-xona",
          building: "A-Bino",
          status: "upcoming",
          attendanceRequired: true
        },
        {
          id: 502,
          time: "10:30 - 11:50",
          subject: "Mobil Ilovalar Dasturlash",
          type: "Laboratoriya",
          teacher: "Assis. Kamol Isoqov",
          room: "MobileLab-01",
          building: "B-Bino",
          status: "upcoming",
          attendanceRequired: true
        }
      ]
    },
    {
      day: "Shanba",
      short: "Sha",
      date: "20-Sentabr",
      classes: [
        {
          id: 601,
          time: "10:00 - 11:30",
          subject: "Mustaqil Ta'lim va Konsultatsiya",
          type: "Konsultatsiya",
          teacher: "Barcha O'qituvchilar",
          room: "Kutubxona / Zoom",
          building: "Onlayn / Bosh Bino",
          status: "upcoming",
          attendanceRequired: false
        }
      ]
    }
  ]
};
