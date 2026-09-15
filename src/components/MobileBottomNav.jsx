import React from 'react';
import { CalendarDays, TrendingUp, Video, User } from 'lucide-react';

export default function MobileBottomNav({ activeTab, setActiveTab }) {
  const items = [
    { id: 'timetable', label: 'Jadval', icon: CalendarDays },
    { id: 'grades', label: 'Baholar', icon: TrendingUp },
    { id: 'kd_courses', label: 'KD Video', icon: Video },
    { id: 'profile', label: 'Profil', icon: User }
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 lg:hidden glass-panel border-t border-slate-800/80 px-2 py-2 flex items-center justify-around">
      {items.map((item) => {
        const Icon = item.icon;
        const isActive = activeTab === item.id;
        return (
          <button
            key={item.id}
            onClick={() => setActiveTab(item.id)}
            className={`flex flex-col items-center justify-center flex-1 py-1.5 px-1 rounded-xl transition-all ${
              isActive 
                ? 'text-indigo-400 font-bold bg-indigo-500/10 border border-indigo-500/20' 
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            <Icon size={19} className={isActive ? 'text-indigo-400 animate-bounce' : 'text-slate-400'} />
            <span className="text-[10px] mt-1 tracking-tight">{item.label}</span>
          </button>
        );
      })}
    </nav>
  );
}
