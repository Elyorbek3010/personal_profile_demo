import React, { useState } from 'react';
import { 
  CalendarDays, 
  Upload, 
  FileSpreadsheet, 
  Search, 
  Clock, 
  MapPin, 
  UserCheck, 
  Sparkles, 
  CheckCircle2, 
  AlertCircle,
  RefreshCw,
  BookOpen
} from 'lucide-react';
import { INITIAL_SCHEDULE } from '../data/mockSchedule';
import { parseExcelSchedule } from '../utils/excelParser';

export default function Timetable() {
  const [scheduleData, setScheduleData] = useState(INITIAL_SCHEDULE);
  const [activeDayIdx, setActiveDayIdx] = useState(0); // 0 = Dushanba
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState('ALL');
  const [isParsing, setIsParsing] = useState(false);
  const [uploadNotice, setUploadNotice] = useState(null);

  // Handle Excel File Upload & Live Parsing
  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setIsParsing(true);
    setUploadNotice(null);

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const buffer = evt.target.result;
        const parsed = parseExcelSchedule(buffer);
        setScheduleData(parsed);
        setUploadNotice({
          type: 'success',
          message: `Excel fayl muvaffaqiyatli tahlil qilindi! "${file.name}" jadvalga o'tkazildi.`
        });
      } catch (err) {
        setUploadNotice({
          type: 'error',
          message: "Excel faylni o'qishda xatolik yuz berdi. .xlsx faylini tanlang."
        });
      } finally {
        setIsParsing(false);
      }
    };
    reader.readAsArrayBuffer(file);
  };

  const handleResetSchedule = () => {
    setScheduleData(INITIAL_SCHEDULE);
    setUploadNotice({
      type: 'info',
      message: "Standard demo dars jadvali qayta tiklandi."
    });
  };

  const currentDay = scheduleData.days[activeDayIdx] || scheduleData.days[0];

  const filteredClasses = (currentDay?.classes || []).filter((item) => {
    const matchesSearch = 
      item.subject.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.teacher.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.room.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.time.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesType = filterType === 'ALL' || item.type === filterType;

    return matchesSearch && matchesType;
  });

  return (
    <div className="space-y-4 sm:space-y-6 text-left max-w-full overflow-hidden">
      
      {/* Header Banner & Excel Upload Toolbar */}
      <div className="glass-panel p-4 sm:p-6 lg:p-8 rounded-2xl sm:rounded-3xl border border-slate-800 space-y-4 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-indigo-600/10 rounded-full blur-[80px] pointer-events-none"></div>

        <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex flex-wrap items-center gap-2">
              <span className="px-2.5 py-0.5 rounded-full bg-indigo-500/10 border border-indigo-500/30 text-indigo-300 text-[11px] sm:text-xs font-semibold flex items-center gap-1.5">
                <FileSpreadsheet size={13} className="text-emerald-400" />
                <span>Smart Excel AI Parser</span>
              </span>
              <span className="text-[11px] sm:text-xs text-slate-400 font-medium">Guruh: {scheduleData.group}</span>
            </div>
            <h1 className="text-xl sm:text-2xl lg:text-3xl font-extrabold text-white">
              Dars Jadvali
            </h1>
            <p className="text-xs sm:text-sm text-slate-400">
              Excel fayllarini yuklab UI da darslar, xonalar va o'qituvchilarni qidiring.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex w-full lg:w-auto items-center gap-2 sm:gap-3">
            <label className="flex-1 lg:flex-initial cursor-pointer flex items-center justify-center gap-2 px-3.5 py-2.5 rounded-xl gradient-bg text-white text-xs font-semibold shadow-lg shadow-indigo-600/30 hover:opacity-95 transition text-center">
              <Upload size={15} />
              <span className="truncate">{isParsing ? "Tahlil qilinmoqda..." : "Excel Yuklash (.xlsx)"}</span>
              <input 
                type="file" 
                accept=".xlsx, .xls, .csv" 
                onChange={handleFileUpload} 
                className="hidden" 
              />
            </label>

            <button
              onClick={handleResetSchedule}
              className="px-3 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 border border-slate-700/80 transition text-xs font-medium flex items-center gap-1.5 shrink-0"
              title="Demo jadvalni tiklash"
            >
              <RefreshCw size={14} />
              <span className="hidden sm:inline">Tiklash</span>
            </button>
          </div>
        </div>

        {/* Upload Notification Banner */}
        {uploadNotice && (
          <div className={`p-3 rounded-xl text-xs flex items-center gap-2 ${
            uploadNotice.type === 'success' ? 'bg-emerald-500/10 border border-emerald-500/30 text-emerald-300' :
            uploadNotice.type === 'error' ? 'bg-rose-500/10 border border-rose-500/30 text-rose-300' :
            'bg-indigo-500/10 border border-indigo-500/30 text-indigo-300'
          }`}>
            {uploadNotice.type === 'success' ? <CheckCircle2 size={15} /> : <AlertCircle size={15} />}
            <span className="truncate">{uploadNotice.message}</span>
          </div>
        )}
      </div>

      {/* Controls Bar: AI Search & Filters */}
      <div className="space-y-3 sm:space-y-0 sm:grid sm:grid-cols-12 sm:gap-3 items-center">
        
        {/* Search Input */}
        <div className="sm:col-span-7 relative">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Fan, xona (masalan: 304) yoki o'qituvchini qidiring..."
            className="w-full bg-slate-900/90 text-white text-xs sm:text-sm pl-10 pr-9 py-2.5 sm:py-3 rounded-xl sm:rounded-2xl border border-slate-800 focus:border-indigo-500 outline-none transition placeholder:text-slate-500"
          />
          <div className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1 bg-indigo-500/20 text-indigo-300 px-1.5 py-0.5 rounded text-[10px] font-semibold border border-indigo-500/30">
            <Sparkles size={10} className="text-amber-400" />
          </div>
        </div>

        {/* Class Type Chips */}
        <div className="sm:col-span-5 flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          {[
            { id: 'ALL', label: 'Barchasi' },
            { id: "Ma'ruza", label: "Ma'ruza" },
            { id: 'Amaliyot', label: 'Amaliyot' },
            { id: 'Laboratoriya', label: 'Lab' }
          ].map((chip) => (
            <button
              key={chip.id}
              onClick={() => setFilterType(chip.id)}
              className={`px-3 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition flex-1 sm:flex-initial text-center ${
                filterType === chip.id
                  ? 'bg-indigo-600 text-white shadow-md'
                  : 'bg-slate-900 text-slate-400 hover:text-slate-200 border border-slate-800'
              }`}
            >
              {chip.label}
            </button>
          ))}
        </div>

      </div>

      {/* Weekday Selector Tabs (Horizontal Scrollable on Mobile) */}
      <div className="flex gap-2 overflow-x-auto pb-2 border-b border-slate-800/80 scrollbar-none">
        {scheduleData.days.map((dayItem, idx) => {
          const isActive = activeDayIdx === idx;
          return (
            <button
              key={idx}
              onClick={() => setActiveDayIdx(idx)}
              className={`flex-1 min-w-[95px] sm:min-w-[110px] p-2.5 sm:p-3 rounded-xl sm:rounded-2xl text-center transition-all shrink-0 ${
                isActive 
                  ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-600/20 font-bold scale-[1.02]' 
                  : 'glass-card text-slate-400 hover:text-slate-200'
              }`}
            >
              <div className="text-[10px] sm:text-xs font-bold uppercase tracking-wider">{dayItem.short}</div>
              <div className="text-xs sm:text-sm font-semibold text-slate-100 mt-0.5">{dayItem.day}</div>
              <div className="text-[10px] opacity-80 mt-0.5">{dayItem.classes.length} dars</div>
            </button>
          );
        })}
      </div>

      {/* Schedule Items List */}
      <div className="space-y-3 sm:space-y-4">
        {filteredClasses.length > 0 ? (
          filteredClasses.map((cls) => (
            <div 
              key={cls.id}
              className="glass-card p-4 sm:p-5 lg:p-6 rounded-2xl sm:rounded-3xl border border-slate-800/90 flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4 hover:border-indigo-500/40 transition"
            >
              {/* Left Info */}
              <div className="flex items-start sm:items-center gap-3 sm:gap-4">
                <div className="p-3 rounded-xl sm:rounded-2xl bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 shrink-0 text-center">
                  <Clock size={18} className="mx-auto mb-0.5 text-indigo-400" />
                  <span className="text-[11px] sm:text-xs font-bold block text-white whitespace-nowrap">{cls.time}</span>
                </div>

                <div className="space-y-1">
                  <div className="flex flex-wrap items-center gap-1.5">
                    <span className={`text-[10px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider ${
                      cls.type === "Ma'ruza" ? "bg-purple-500/20 text-purple-300 border border-purple-500/30" :
                      cls.type === "Amaliyot" ? "bg-indigo-500/20 text-indigo-300 border border-indigo-500/30" :
                      "bg-emerald-500/20 text-emerald-300 border border-emerald-500/30"
                    }`}>
                      {cls.type}
                    </span>

                    {cls.status === 'ongoing' && (
                      <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 font-bold border border-emerald-500/30 animate-pulse">
                        ● Hozirgi Dars
                      </span>
                    )}

                    {cls.attendanceRequired && (
                      <span className="text-[10px] text-amber-400 font-medium flex items-center gap-1">
                        <UserCheck size={11} />
                        <span>Davomat</span>
                      </span>
                    )}
                  </div>

                  <h3 className="text-sm sm:text-base font-bold text-white leading-tight">
                    {cls.subject}
                  </h3>

                  <p className="text-[11px] sm:text-xs text-slate-400">
                    O'qituvchi: <span className="text-slate-200 font-medium">{cls.teacher}</span>
                  </p>
                </div>
              </div>

              {/* Right Info: Room Badge */}
              <div className="flex items-center justify-between sm:justify-end gap-2 pt-2.5 sm:pt-0 border-t sm:border-t-0 border-slate-800/80">
                <div className="px-3 py-1.5 rounded-xl bg-slate-900/90 border border-slate-700/80 text-left sm:text-right w-full sm:w-auto">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-indigo-300">
                    <MapPin size={13} className="text-indigo-400" />
                    <span>{cls.room}</span>
                  </div>
                  <div className="text-[10px] text-slate-400">{cls.building}</div>
                </div>
              </div>

            </div>
          ))
        ) : (
          <div className="p-8 sm:p-12 text-center glass-panel rounded-2xl sm:rounded-3xl border border-slate-800 space-y-2">
            <BookOpen size={36} className="mx-auto text-slate-600" />
            <h4 className="text-sm sm:text-base font-bold text-slate-300">Darslar topilmadi</h4>
            <p className="text-xs text-slate-500">
              Qidiruv so'zini o'zgartiring yoki boshqa kunni tanlang.
            </p>
          </div>
        )}
      </div>

    </div>
  );
}
