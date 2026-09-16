import React, { useState, useEffect } from 'react';
import { 
  CalendarDays, 
  Search, 
  Clock, 
  MapPin, 
  UserCheck, 
  CheckCircle2, 
  RefreshCw, 
  BookOpen, 
  GraduationCap, 
  Settings2, 
  X, 
  Link2,
  User,
  Building2
} from 'lucide-react';
import { 
  fetchScheduleViaAI, 
  getConfiguredSheetUrl, 
  saveConfiguredSheetUrl, 
  WEEK_DAYS 
} from '../utils/geminiTimetableService';

export default function Timetable() {
  // Current Student ID Resolution
  const [studentId, setStudentId] = useState(() => {
    try {
      const saved = localStorage.getItem('student_profile');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed.studentId && parsed.studentId !== '2311195') {
          return String(parsed.studentId).trim();
        }
      }
      const savedUser = localStorage.getItem('user_info');
      if (savedUser) {
        const parsedUser = JSON.parse(savedUser);
        if (parsedUser.studentId && parsedUser.studentId !== '2311195') {
          return String(parsedUser.studentId).trim();
        }
      }
    } catch (e) {
      console.error(e);
    }
    return '2311194'; // Exact ID for Elyorbek Adhamov
  });

  const [selectedGroup, setSelectedGroup] = useState(() => {
    try {
      const saved = localStorage.getItem('student_profile');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed.group) return parsed.group;
      }
      const savedUser = localStorage.getItem('user_info');
      if (savedUser) {
        const parsedUser = JSON.parse(savedUser);
        if (parsedUser.group) return parsedUser.group;
      }
    } catch (e) {}
    return '23D';
  });

  // Partner University Track state
  const [partnerUniversity, setPartnerUniversity] = useState(() => {
    try {
      const saved = localStorage.getItem('student_profile');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed.partnerUniversity) return parsed.partnerUniversity;
      }
    } catch (e) {}
    return 'Tokyo Online University (TOU)';
  });

  // Calculate today's day of week (0 = Monday, 5 = Saturday, default to 0 if Sunday)
  const getTodayIdx = () => {
    const day = new Date().getDay(); // 0 = Sunday, 1 = Monday...
    return (day >= 1 && day <= 6) ? day - 1 : 0;
  };

  const [activeDayIdx, setActiveDayIdx] = useState(getTodayIdx);
  const [scheduleData, setScheduleData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState('ALL');

  // Sheet Link Settings Modal state
  const [showSettingsModal, setShowSettingsModal] = useState(false);
  const [sheetUrlInput, setSheetUrlInput] = useState(getConfiguredSheetUrl);
  const [settingsNotice, setSettingsNotice] = useState(null);

  // Listen for profile changes (e.g. from Profile page or upon login)
  useEffect(() => {
    const handleProfileUpdate = () => {
      try {
        const saved = localStorage.getItem('student_profile');
        if (saved) {
          const parsed = JSON.parse(saved);
          if (parsed.studentId && parsed.studentId !== studentId) {
            setStudentId(parsed.studentId);
          }
          if (parsed.partnerUniversity && parsed.partnerUniversity !== partnerUniversity) {
            setPartnerUniversity(parsed.partnerUniversity);
          }
          if (parsed.group && parsed.group !== selectedGroup) {
            setSelectedGroup(parsed.group);
          }
        }
      } catch (e) {}
    };
    window.addEventListener('profile-updated', handleProfileUpdate);
    return () => window.removeEventListener('profile-updated', handleProfileUpdate);
  }, [studentId, partnerUniversity, selectedGroup]);

  // Load Schedule via autonomous Gemini AI parser
  const loadSchedule = async (forceRefresh = false, partnerOverride = null) => {
    setLoading(true);
    const targetPartner = partnerOverride || partnerUniversity;
    try {
      const data = await fetchScheduleViaAI(studentId, forceRefresh, targetPartner);
      setScheduleData(data);
      if (data?.student?.group) {
        setSelectedGroup(data.student.group);
      }
    } catch (err) {
      console.error("Timetable AI load error:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSchedule(false, partnerUniversity);
  }, [studentId, partnerUniversity]);

  // Handle direct Partner University change from Timetable header
  const handlePartnerUniversityChange = (newTrack) => {
    setPartnerUniversity(newTrack);
    try {
      const saved = localStorage.getItem('student_profile');
      let prof = saved ? JSON.parse(saved) : {};
      prof.partnerUniversity = newTrack;
      localStorage.setItem('student_profile', JSON.stringify(prof));
      window.dispatchEvent(new Event('profile-updated'));
    } catch (e) {}
  };

  // Handle Sheet URL update
  const handleSaveSheetUrl = (e) => {
    e.preventDefault();
    if (!sheetUrlInput.trim()) return;
    saveConfiguredSheetUrl(sheetUrlInput);
    setSettingsNotice("Google Sheet havolasi muvaffaqiyatli saqlandi!");
    loadSchedule(true, partnerUniversity);
    setTimeout(() => {
      setSettingsNotice(null);
      setShowSettingsModal(false);
    }, 1200);
  };

  const currentDay = scheduleData?.days?.[activeDayIdx] || scheduleData?.days?.[0];

  const filteredClasses = (currentDay?.classes || []).filter((item) => {
    const matchesSearch = 
      (item.subject || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (item.teacher || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (item.room || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (item.time || '').toLowerCase().includes(searchQuery.toLowerCase());

    const matchesType = filterType === 'ALL' || item.type === filterType;
    return matchesSearch && matchesType;
  });

  return (
    <div className="space-y-5 text-left max-w-full overflow-hidden">
      
      {/* Top Header Card */}
      <div className="glass-panel p-5 sm:p-7 rounded-3xl border border-slate-800 space-y-4 relative overflow-hidden shadow-xl">
        <div className="absolute top-0 right-0 w-80 h-80 bg-indigo-600/10 rounded-full blur-[100px] pointer-events-none"></div>

        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-1.5">
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 text-[11px] font-semibold border border-emerald-500/20">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                <span>Jonli Dars Jadvali</span>
              </span>
              <span className="text-xs text-slate-500">•</span>
              <span className="text-xs text-slate-400 font-medium">
                {scheduleData?.university || "Japan Digital University"}
              </span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              Haftalik Dars Jadvali
            </h1>
            <p className="text-xs sm:text-sm text-slate-400 mt-1">
              {scheduleData?.student?.name ? `${scheduleData.student.name} • ` : ''}
              {partnerUniversity.includes('Tokyo') ? (
                <span className="text-indigo-300">
                  Tokyo Online University (TOU) — darslar 100% onlayn, kampus offline darslari chetlatilgan
                </span>
              ) : partnerUniversity.includes('SANNO') ? (
                <span className="text-emerald-300">
                  SANNO University — SANNO-K / SANNO-F kampus hamkorlik darslari kiritilgan
                </span>
              ) : (
                <span className="text-indigo-300">
                  {partnerUniversity} darslari
                </span>
              )}
            </p>
          </div>

          {/* Group & Action Controls */}
          <div className="flex items-center gap-2.5 self-start sm:self-auto flex-wrap">
            {/* Group Badge */}
            <div className="flex items-center gap-2 px-3 py-2 rounded-2xl bg-slate-900/90 border border-slate-700/80 text-xs shadow-md">
              <GraduationCap size={15} className="text-indigo-400 shrink-0" />
              <span className="text-slate-400 font-medium">Guruh:</span>
              <span className="text-white font-bold tracking-wide">
                {scheduleData?.student?.group || selectedGroup}
              </span>
            </div>

            {/* Authentic Partner University Badge from Database */}
            {partnerUniversity && (
              <div className="flex items-center gap-1.5 px-3 py-2 rounded-2xl bg-indigo-500/10 border border-indigo-500/20 text-indigo-300 text-xs font-semibold shadow-md">
                <Building2 size={13} className="text-indigo-400 shrink-0" />
                <span>{partnerUniversity.includes('Tokyo') ? 'TOU (Onlayn)' : partnerUniversity}</span>
              </div>
            )}

            {/* Japanese Exemption Status */}
            {scheduleData?.student?.japaneseExempt && (
              <div className="hidden sm:flex items-center gap-1.5 px-3 py-2 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold shadow-md">
                <CheckCircle2 size={13} className="text-emerald-400 shrink-0" />
                <span>Yapon tili: Ozod</span>
              </div>
            )}

            {/* Student ID Badge */}
            <div className="hidden md:flex items-center gap-1.5 px-3 py-2 rounded-2xl bg-slate-900/90 border border-slate-700/80 text-xs shadow-md text-slate-300">
              <User size={13} className="text-slate-400 shrink-0" />
              <span className="font-mono text-indigo-300 font-semibold">{studentId}</span>
            </div>

            {/* Refresh Button */}
            <button
              onClick={() => loadSchedule(true)}
              disabled={loading}
              title="Jadvalni qayta yangilash"
              className="p-2.5 rounded-2xl bg-slate-800/80 hover:bg-slate-700 border border-slate-700 text-slate-300 hover:text-white transition cursor-pointer"
            >
              <RefreshCw size={15} className={loading ? "animate-spin text-indigo-400" : ""} />
            </button>

            {/* Sheet Link Settings Icon */}
            <button
              onClick={() => setShowSettingsModal(true)}
              title="Google Sheet havolasini sozlash"
              className="p-2.5 rounded-2xl bg-slate-800/80 hover:bg-slate-700 border border-slate-700 text-slate-400 hover:text-indigo-300 transition cursor-pointer"
            >
              <Settings2 size={15} />
            </button>
          </div>
        </div>

        {/* Day Selector Tabs (Monday - Saturday) */}
        <div className="pt-2 border-t border-slate-800/80">
          <div className="grid grid-cols-3 sm:grid-cols-6 gap-2">
            {WEEK_DAYS.map((wDay, idx) => {
              const dayClassesCount = scheduleData?.days?.[idx]?.classes?.length || 0;
              const isSelected = activeDayIdx === idx;
              return (
                <button
                  key={idx}
                  onClick={() => setActiveDayIdx(idx)}
                  className={`py-2.5 px-3 rounded-2xl text-left transition-all cursor-pointer flex flex-col justify-between relative ${
                    isSelected
                      ? 'gradient-bg text-white shadow-lg shadow-indigo-600/25 scale-[1.02]'
                      : 'bg-slate-900/60 hover:bg-slate-800/80 text-slate-400 hover:text-slate-200 border border-slate-800'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className={`text-xs font-bold ${isSelected ? 'text-white' : 'text-slate-200'}`}>
                      {wDay.day}
                    </span>
                    <span className={`text-[10px] font-mono ${isSelected ? 'text-indigo-200' : 'text-slate-500'}`}>
                      {wDay.jp}
                    </span>
                  </div>
                  <div className="mt-1 text-[11px] font-medium opacity-80">
                    {dayClassesCount} ta dars
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* Search & Quick Filter Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        {/* Search Bar */}
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Fan, xona yoki o'qituvchi bo'yicha qidirish..."
            className="w-full bg-slate-900/80 text-white text-xs sm:text-sm pl-10 pr-4 py-2.5 rounded-2xl border border-slate-800 focus:border-indigo-500 outline-none transition placeholder:text-slate-500"
          />
        </div>

        {/* Type Filter Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0 scrollbar-none text-xs">
          {['ALL', "Ma'ruza", 'Amaliyot'].map((type) => (
            <button
              key={type}
              onClick={() => setFilterType(type)}
              className={`px-3.5 py-1.5 rounded-xl font-medium transition cursor-pointer shrink-0 ${
                filterType === type
                  ? 'bg-indigo-600 text-white shadow'
                  : 'bg-slate-900/80 text-slate-400 hover:text-slate-200 border border-slate-800'
              }`}
            >
              {type === 'ALL' ? 'Barchasi' : type}
            </button>
          ))}
        </div>
      </div>

      {/* Daily Class Cards List */}
      <div className="space-y-3.5">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-sm font-bold text-white flex items-center gap-2">
            <CalendarDays size={16} className="text-indigo-400" />
            <span>{currentDay?.day || 'Bugun'} jadvali</span>
            <span className="text-xs text-slate-500 font-normal">({filteredClasses.length} ta dars)</span>
          </h2>
          <span className="text-xs text-indigo-300 font-medium">
            Guruh: {scheduleData?.student?.group || selectedGroup}
          </span>
        </div>

        {loading ? (
          <div className="glass-panel p-12 rounded-3xl border border-slate-800 text-center space-y-3">
            <div className="w-8 h-8 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
            <p className="text-xs text-slate-400">Jadval yuklanmoqda...</p>
          </div>
        ) : filteredClasses.length === 0 ? (
          <div className="glass-panel p-10 rounded-3xl border border-slate-800 text-center space-y-2">
            <BookOpen size={36} className="mx-auto text-slate-600" />
            <p className="text-sm font-semibold text-slate-300">Bu kunda darslar topilmadi</p>
            <p className="text-xs text-slate-500">
              {searchQuery 
                ? "Qidiruv shartlariga mos keluvchi dars yo'q." 
                : scheduleData?.student?.japaneseExempt 
                ? "Ushbu kunga asosiy dars rejalashtirilmagan (Yapon tili darslaridan ozod qilingansiz)." 
                : "Ushbu kunga dars rejalashtirilmagan yoki dam olish kuni."}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3.5">
            {filteredClasses.map((item) => (
              <div 
                key={item.id || `${item.time}-${item.subject}`}
                className="glass-panel p-4 sm:p-5 rounded-2xl sm:rounded-3xl border border-slate-800/90 hover:border-indigo-500/40 transition-all space-y-3 relative group hover:shadow-xl hover:shadow-indigo-500/5"
              >
                {/* Top Row: Time Badge & Type */}
                <div className="flex items-center justify-between gap-2">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-indigo-500/10 text-indigo-300 text-xs font-semibold border border-indigo-500/20">
                    <Clock size={13} className="text-indigo-400" />
                    <span>{item.para ? `${item.para}-para • ` : ''}{item.time}</span>
                  </span>

                  <span className={`px-2 py-0.5 rounded-lg text-[10px] font-bold uppercase tracking-wider ${
                    item.type?.includes("Ma'ruza")
                      ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20'
                      : item.type?.includes("Amaliyot")
                      ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                      : item.type?.includes("Til")
                      ? 'bg-purple-500/10 text-purple-400 border border-purple-500/20'
                      : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                  }`}>
                    {item.type || "Dars"}
                  </span>
                </div>

                {/* Subject Name */}
                <div>
                  <h3 className="text-sm sm:text-base font-bold text-white group-hover:text-indigo-300 transition leading-snug">
                    {item.subject}
                  </h3>
                </div>

                {/* Metadata Row: Room & Teacher */}
                <div className="pt-2 border-t border-slate-800/60 flex items-center justify-between text-xs text-slate-400">
                  <div className="flex items-center gap-1.5 font-medium text-slate-300">
                    <MapPin size={14} className="text-indigo-400 shrink-0" />
                    <span>{item.room || "JDU"}</span>
                  </div>

                  {item.teacher && (
                    <div className="flex items-center gap-1.5 text-slate-400 truncate max-w-[140px]">
                      <UserCheck size={14} className="text-slate-500 shrink-0" />
                      <span className="truncate">{item.teacher}</span>
                    </div>
                  )}
                </div>

                {/* Attendance Notice */}
                {item.attendanceRequired && (
                  <div className="flex items-center gap-1 text-[11px] text-amber-400/90 pt-1">
                    <CheckCircle2 size={12} className="shrink-0" />
                    <span>Davomat majburiy (85% talabi)</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Settings Modal (Change Google Sheet URL) */}
      {showSettingsModal && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="glass-panel p-6 sm:p-7 rounded-3xl border border-slate-800 max-w-lg w-full space-y-4 shadow-2xl relative">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-indigo-600/20 text-indigo-400 flex items-center justify-center font-bold">
                  <Link2 size={18} />
                </div>
                <div>
                  <h3 className="text-base font-bold text-white">Google Sheet Havolasini Sozlash</h3>
                  <p className="text-xs text-slate-400">Yangi semestr jadvali havolasini kiriting</p>
                </div>
              </div>
              <button 
                onClick={() => setShowSettingsModal(false)}
                className="p-1.5 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition"
              >
                <X size={18} />
              </button>
            </div>

            {settingsNotice && (
              <div className="p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs flex items-center gap-2">
                <CheckCircle2 size={15} />
                <span>{settingsNotice}</span>
              </div>
            )}

            <form onSubmit={handleSaveSheetUrl} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                  Jonli Google Sheet Havolasi (URL)
                </label>
                <input
                  type="url"
                  required
                  value={sheetUrlInput}
                  onChange={(e) => setSheetUrlInput(e.target.value)}
                  placeholder="https://docs.google.com/spreadsheets/d/..."
                  className="w-full bg-slate-900 text-white text-xs p-3 rounded-xl border border-slate-700 focus:border-indigo-500 outline-none"
                />
                <p className="text-[11px] text-slate-500 mt-1">
                  Google Sheet "Anyone with the link can view" holatida bo'lishi kerak.
                </p>
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowSettingsModal(false)}
                  className="px-4 py-2 rounded-xl bg-slate-800 text-slate-300 text-xs font-semibold hover:bg-slate-700 transition"
                >
                  Bekor qilish
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl gradient-bg text-white text-xs font-semibold shadow-lg shadow-indigo-600/30 hover:opacity-95 transition"
                >
                  Saqlash va Yangilash
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
