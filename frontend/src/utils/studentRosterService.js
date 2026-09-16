/**
 * UNIVER SuperApp - Student Roster Service
 * 
 * Dynamic student and group resolution via AI.
 * NO HARDCODED ROSTERS OR DICTIONARIES.
 */

const STORAGE_ROSTER_SHEET_KEY = 'univer_roster_sheet_url';

/**
 * Lookup student details from AI cached data or active profile
 */
export function lookupStudentInRoster(studentId) {
  if (!studentId) return null;
  const cleanId = String(studentId).trim();

  // 1. Check AI cached schedule
  try {
    const aiCached = localStorage.getItem(`univer_ai_timetable_${cleanId}`);
    if (aiCached) {
      const parsed = JSON.parse(aiCached);
      if (parsed?.student) {
        return parsed.student;
      }
    }
  } catch (e) {
    console.error("AI cache lookup error:", e);
  }

  // 2. Check saved profile
  try {
    const profile = localStorage.getItem('student_profile');
    if (profile) {
      const p = JSON.parse(profile);
      if (p.studentId === cleanId) {
        return {
          id: cleanId,
          name: p.fullName || p.name,
          group: p.group || '23D',
          faculty: p.faculty || 'IT'
        };
      }
    }
  } catch (e) {
    console.error("Profile lookup error:", e);
  }

  return null;
}

export function getRosterSheetUrl() {
  return localStorage.getItem(STORAGE_ROSTER_SHEET_KEY) || '';
}

export function saveRosterSheetUrl(url) {
  if (url && url.trim()) {
    localStorage.setItem(STORAGE_ROSTER_SHEET_KEY, url.trim());
  }
}
