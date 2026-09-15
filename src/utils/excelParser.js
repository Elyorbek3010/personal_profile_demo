import * as XLSX from 'xlsx';

/**
 * Parses an Excel (.xlsx / .xls) schedule file into standardized timetable JSON.
 * @param {ArrayBuffer} buffer - File buffer from file input
 * @returns {Object} Parsed schedule format matching INITIAL_SCHEDULE
 */
export function parseExcelSchedule(buffer) {
  try {
    const workbook = XLSX.read(buffer, { type: 'array' });
    const firstSheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[firstSheetName];
    const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

    if (!jsonData || jsonData.length === 0) {
      throw new Error("Excel fayl bo'sh yoki o'qib bo'lmadi.");
    }

    const days = [
      { day: "Dushanba", short: "Du", date: "Bugun", classes: [] },
      { day: "Seshanba", short: "Se", date: "Ertaga", classes: [] },
      { day: "Chorshanba", short: "Cho", date: "Tushdan so'ng", classes: [] },
      { day: "Payshanba", short: "Pay", date: "Payshanba", classes: [] },
      { day: "Juma", short: "Ju", date: "Juma", classes: [] },
      { day: "Shanba", short: "Sha", date: "Shanba", classes: [] }
    ];

    let currentDayIdx = 0;
    let classCounter = 1000;

    jsonData.forEach((row, idx) => {
      if (!row || row.length === 0) return;
      const textLine = row.map(cell => String(cell || '')).join(' ');

      if (/dushanba|mon/i.test(textLine)) currentDayIdx = 0;
      else if (/seshanba|tue/i.test(textLine)) currentDayIdx = 1;
      else if (/chorshanba|wed/i.test(textLine)) currentDayIdx = 2;
      else if (/payshanba|thu/i.test(textLine)) currentDayIdx = 3;
      else if (/juma|fri/i.test(textLine)) currentDayIdx = 4;
      else if (/shanba|sat/i.test(textLine)) currentDayIdx = 5;

      const hasTime = row.some(cell => /\d{1,2}[:.-]\d{2}/.test(String(cell)));
      if (row.length >= 2 && (hasTime || idx > 2)) {
        const timeCell = row.find(c => /\d{1,2}[:.-]\d{2}/.test(String(c))) || "09:00 - 10:20";
        const subjectCell = row.find(c => typeof c === 'string' && c.length > 5 && !/\d{1,2}[:.-]\d{2}/.test(c)) || row[1] || "Dars Mashg'uloti";
        const roomCell = row.find(c => /xona|lab|hall|\d{3}/i.test(String(c))) || "301-xona";
        const teacherCell = row.find(c => /prof|dr|assis|oqituvchi/i.test(String(c))) || "Universitet O'qituvchisi";

        classCounter++;
        days[currentDayIdx].classes.push({
          id: classCounter,
          time: String(timeCell),
          subject: String(subjectCell).trim(),
          type: subjectCell.toLowerCase().includes("lab") ? "Laboratoriya" : subjectCell.toLowerCase().includes("amal") ? "Amaliyot" : "Ma'ruza",
          teacher: String(teacherCell),
          room: String(roomCell),
          building: "Yuklangan Excel Binosi",
          status: "upcoming",
          attendanceRequired: true
        });
      }
    });

    return {
      faculty: "Excel Faylidan O'qilgan Dars Jadvali",
      group: "Barcha Guruhlar",
      semester: "2026 O'quv Yili",
      days: days.filter(d => d.classes.length > 0)
    };
  } catch (err) {
    console.error("Excel parse error:", err);
    throw err;
  }
}
