import React from 'react';
import { 
  CalendarDays, 
  TrendingUp, 
  Video, 
  User, 
  Smartphone,
  ExternalLink,
  BookOpen,
  LogOut
} from 'lucide-react';

export default function Sidebar({ activeTab, setActiveTab, onLogout, mobileMenuOpen, onCloseMobileMenu }) {
  const menuItems = [
    {
      id: 'timetable',
      label: 'Dars Jadvali (Excel AI)',
      icon: CalendarDays,
      badge: 'Smart Parser'
    },
    {
      id: 'grades',
      label: "Baholar va Davomat",
      icon: TrendingUp,
      badge: 'GPA Monitor'
    },
    {
      id: 'kd_courses',
      label: 'KD Video Darsliklar',
      icon: Video,
      badge: 'Video Hub'
    },
    {
      id: 'profile',
      label: 'Talaba Profili & Auth',
      icon: User,
      badge: 'DRF JWT'
    }
  ];

  return (
    <>
      {/* Mobile overlay */}
      {mobileMenuOpen && (
        <div 
          onClick={onCloseMobileMenu}
          className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm z-40 lg:hidden"
        />
      )}

      {/* Sidebar container */}
      <aside className={`
        fixed lg:sticky top-0 lg:top-[65px] left-0 z-50 lg:z-30
        w-72 h-[calc(100vh)] lg:h-[calc(100vh-65px)]
        glass-panel border-r border-slate-800/80 p-4
        flex flex-col justify-between text-left
        transition-transform duration-300 ease-in-out
        ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        {/* Navigation list */}
        <div className="space-y-5">
          <div>
            <p className="text-[11px] uppercase tracking-wider text-slate-400 font-bold px-3 mb-2">
              Asosiy Menyu
            </p>
            <nav className="space-y-1">
              {menuItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    onClick={() => {
                      setActiveTab(item.id);
                      if (onCloseMobileMenu) onCloseMobileMenu();
                    }}
                    className={`
                      w-full flex items-center justify-between px-3.5 py-3 rounded-xl font-medium text-xs sm:text-sm transition-all
                      ${isActive 
                        ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-600/20 font-semibold' 
                        : 'text-slate-300 hover:text-white hover:bg-slate-800/60'}
                    `}
                  >
                    <div className="flex items-center gap-3">
                      <Icon size={18} className={isActive ? 'text-white' : 'text-indigo-400'} />
                      <span>{item.label}</span>
                    </div>
                    {item.badge && (
                      <span className={`text-[10px] px-2 py-0.5 rounded-md font-semibold ${
                        isActive 
                          ? 'bg-white/20 text-white' 
                          : 'bg-slate-800 text-slate-400 border border-slate-700/60'
                      }`}>
                        {item.badge}
                      </span>
                    )}
                  </button>
                );
              })}
            </nav>
          </div>

          {/* Quick University Links Widget */}
          <div className="p-3.5 rounded-2xl bg-gradient-to-b from-indigo-950/40 to-slate-900/80 border border-indigo-500/20 space-y-2">
            <div className="flex items-center gap-2 text-indigo-300 font-semibold text-xs">
              <BookOpen size={15} />
              <span>Universitet Havolalari</span>
            </div>
            <div className="space-y-1.5 text-xs text-slate-300">
              <a href="https://hemis.uz" target="_blank" rel="noreferrer" className="flex items-center justify-between p-2 rounded-lg bg-slate-900/60 hover:bg-slate-800/80 hover:text-white transition group">
                <span>HEMIS Portali (Baholar)</span>
                <ExternalLink size={12} className="text-slate-500 group-hover:text-indigo-400" />
              </a>
              <a href="#" onClick={(e) => { e.preventDefault(); setActiveTab('kd_courses'); }} className="flex items-center justify-between p-2 rounded-lg bg-slate-900/60 hover:bg-slate-800/80 hover:text-white transition group">
                <span>KD Video Platforma</span>
                <ExternalLink size={12} className="text-slate-500 group-hover:text-indigo-400" />
              </a>
            </div>
          </div>
        </div>

        {/* Bottom Logout Button */}
        <div className="space-y-3 pt-3 border-t border-slate-800/80">
          <button
            onClick={() => {
              if (onLogout) onLogout();
              if (onCloseMobileMenu) onCloseMobileMenu();
            }}
            className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 transition text-xs font-semibold"
          >
            <LogOut size={16} />
            <span>Tizimdan Chiqish (Logout)</span>
          </button>
        </div>
      </aside>
    </>
  );
}
