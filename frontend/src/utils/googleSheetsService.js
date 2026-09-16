/**
 * UNIVER SuperApp - Google Sheets & Timetable Bridge
 * 
 * Re-exports from autonomous geminiTimetableService.
 * NO HARDCODED SUBJECTS OR MOCKS.
 */

export {
  fetchScheduleViaAI,
  fetchScheduleViaAI as fetchLiveGoogleSheetSchedule,
  getConfiguredSheetUrl,
  saveConfiguredSheetUrl,
  extractSpreadsheetId,
  WEEK_DAYS,
  DEFAULT_SHEET_URL
} from './geminiTimetableService';
