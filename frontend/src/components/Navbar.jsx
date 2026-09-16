import React from 'react';
import { 
  GraduationCap, 
  Bell, 
  LogOut,
  Menu,
  X,
  User
} from 'lucide-react';

export default function Navbar({ activeTab, setActiveTab, isAuthenticated, user, onLogout, onToggleMobileMenu, mobileMenuOpen }) {
  return (
    <header className="sticky top-0 z-40 w-full glass-panel border-b border-slate-800/80 px-4 lg:px-8 py-3 flex items-center justify-between">
      {/* Left: Mobile Menu & Logo */}
      <div className="flex items-center gap-4">
        <button 
          onClick={onToggleMobileMenu}
          className="lg:hidden p-2 rounded-xl text-slate-300 hover:text-white hover:bg-slate-800 transition"
          aria-label="Toggle Navigation Menu"
        >
          {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
        </button>

        <div 
          onClick={() => setActiveTab('timetable')} 
          className="flex items-center gap-3 cursor-pointer group"
        >
          <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center text-white shadow-lg shadow-indigo-500/25 group-hover:scale-105 transition transform">
            <GraduationCap size={24} />
          </div>
          <div className="text-left">
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-lg text-white tracking-tight">UNIVER</span>
              <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 font-semibold border border-indigo-500/30">SuperApp</span>
            </div>
            <p className="text-[11px] text-slate-400 font-medium hidden sm:block">Japan Digital University</p>
          </div>
        </div>
      </div>

      {/* Right: Notifications, User profile & Logout */}
      <div className="flex items-center gap-2 sm:gap-3">
        <button 
          className="relative p-2 rounded-xl text-slate-300 hover:text-white hover:bg-slate-800/80 transition hidden sm:block"
          title="Bildirishnomalar"
        >
          <Bell size={19} />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-indigo-500 ring-2 ring-slate-900"></span>
        </button>

        {isAuthenticated && (
          <div className="flex items-center gap-2">
            {/* User Profile Button */}
            <button
              onClick={() => setActiveTab('profile')}
              title="Profilga o'tish"
              className={`flex items-center gap-2 px-2.5 py-1.5 rounded-xl border transition cursor-pointer ${
                activeTab === 'profile'
                  ? 'bg-indigo-600/20 border-indigo-500/50 text-white'
                  : 'bg-slate-800/60 hover:bg-slate-800 border-slate-700/60 text-slate-200'
              }`}
            >
              <div className="w-7 h-7 rounded-lg bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center font-bold text-white text-xs">
                {user.email ? user.email.substring(0, 2).toUpperCase() : 'EA'}
              </div>
              <span className="text-xs font-semibold hidden sm:inline truncate max-w-[120px]">
                {user.name || 'Elyorbek Adhamov'}
              </span>
            </button>

            {/* Direct Logout Button */}
            <button
              onClick={onLogout}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 transition text-xs font-semibold cursor-pointer"
              title="Tizimdan Chiqish (Logout)"
            >
              <LogOut size={14} />
              <span className="hidden sm:inline">Chiqish</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
