import React, { useState } from 'react';
import { 
  GraduationCap, 
  Search, 
  Bell, 
  User, 
  Sparkles, 
  Menu,
  X,
  LogOut
} from 'lucide-react';

export default function Navbar({ activeTab, setActiveTab, isAuthenticated, user, onLogout, onToggleMobileMenu, mobileMenuOpen }) {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <header className="sticky top-0 z-40 w-full glass-panel border-b border-slate-800/80 px-4 lg:px-8 py-3.5 flex items-center justify-between">
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
            <p className="text-[11px] text-slate-400 font-medium hidden sm:block">Barcha Talabalik Platformalari Bitta Joyda</p>
          </div>
        </div>
      </div>

      {/* Middle: AI Search bar */}
      <div className="hidden md:flex items-center flex-1 max-w-md mx-8 relative">
        <div className="relative w-full">
          <Search size={17} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Dars jadvali, xona 304, prof. Alisher yoki KD darsini qidiring..."
            className="w-full bg-slate-900/90 text-slate-200 text-xs sm:text-sm pl-10 pr-10 py-2.5 rounded-xl border border-slate-700/60 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-500"
          />
          <div className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1 bg-slate-800/80 px-1.5 py-0.5 rounded text-[10px] text-slate-400 border border-slate-700">
            <Sparkles size={10} className="text-amber-400" />
            <span>AI</span>
          </div>
        </div>
      </div>

      {/* Right: Notifications, User profile & Logout */}
      <div className="flex items-center gap-2 sm:gap-3">
        <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          <span>DRF JWT Active</span>
        </div>

        <button 
          className="relative p-2 rounded-xl text-slate-300 hover:text-white hover:bg-slate-800/80 transition hidden sm:block"
          title="Bildirishnomalar"
        >
          <Bell size={20} />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-indigo-500 ring-2 ring-slate-900"></span>
        </button>

        {isAuthenticated && (
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-2 bg-slate-800/60 pl-2 pr-3 py-1 rounded-xl border border-slate-700/60">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center font-bold text-white text-xs">
                {user.email ? user.email.substring(0, 2).toUpperCase() : 'US'}
              </div>
              <div className="text-left hidden sm:block">
                <p className="text-xs font-semibold text-slate-200 leading-tight truncate max-w-[110px]">{user.email.split('@')[0]}</p>
                <p className="text-[10px] text-indigo-300">KI-21-04 Guruh</p>
              </div>
            </div>

            {/* Direct Logout Button */}
            <button
              onClick={onLogout}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 transition text-xs font-semibold"
              title="Tizimdan Chiqish (Logout)"
            >
              <LogOut size={15} />
              <span className="hidden sm:inline">Chiqish</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
