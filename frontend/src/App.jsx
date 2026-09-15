import React, { useState, useEffect } from 'react';
import AuthPage from './components/AuthPage';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import MobileBottomNav from './components/MobileBottomNav';
import Timetable from './pages/Timetable';
import { LogOut, CalendarDays, TrendingUp, Video, User, ShieldCheck } from 'lucide-react';

export default function App() {
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState('timetable');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Check saved authentication state on app load
  useEffect(() => {
    const savedUser = localStorage.getItem('user_info');
    if (savedUser) {
      try {
        setUser(JSON.parse(savedUser));
      } catch (err) {
        console.error("User parse error:", err);
      }
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_info');
    setUser(null);
  };

  // Render Authentication Page if not logged in
  if (!user) {
    return <AuthPage onLoginSuccess={(userData) => setUser(userData)} />;
  }

  return (
    <div className="min-h-screen bg-[#070b14] text-slate-100 flex flex-col font-sans relative">
      {/* Top Navbar with Logout button */}
      <Navbar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        isAuthenticated={!!user}
        user={user}
        onLogout={handleLogout}
        onOpenAuth={() => {}}
        mobileMenuOpen={mobileMenuOpen}
        onToggleMobileMenu={() => setMobileMenuOpen(!mobileMenuOpen)}
      />

      <div className="flex-1 flex w-full max-w-full overflow-hidden">
        {/* Sidebar Navigation with Logout button */}
        <Sidebar
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          onLogout={handleLogout}
          mobileMenuOpen={mobileMenuOpen}
          onCloseMobileMenu={() => setMobileMenuOpen(false)}
        />

        {/* Main Application Area */}
        <main className="flex-1 p-3 sm:p-6 lg:p-8 max-w-7xl mx-auto space-y-6 pb-20 lg:pb-8 w-full overflow-x-hidden">
          
          {/* Render Active View */}
          {activeTab === 'timetable' && <Timetable />}

          {/* Fallback Placeholder for upcoming modules */}
          {activeTab !== 'timetable' && (
            <div className="glass-panel p-6 sm:p-12 rounded-3xl border border-slate-800 text-center space-y-4">
              <div className="w-14 h-14 rounded-2xl gradient-bg flex items-center justify-center mx-auto text-white shadow-xl shadow-indigo-600/30">
                <CalendarDays size={28} />
              </div>
              <h2 className="text-xl sm:text-2xl font-bold text-white capitalize">{activeTab} Moduli</h2>
              <p className="text-xs sm:text-sm text-slate-400 max-w-md mx-auto">
                Ushbu modul bo'yicha imkoniyatlarni keyingi qadamlarda birgalikda ishlab chiqamiz. 
                "Dars Jadvali (Excel AI)" modulini sinab ko'rish uchun menyudan o'ting.
              </p>
              <button 
                onClick={() => setActiveTab('timetable')}
                className="px-5 py-2.5 rounded-xl gradient-bg text-white text-xs font-semibold shadow-lg hover:opacity-95 transition"
              >
                Dars Jadvaliga O'tish
              </button>
            </div>
          )}

        </main>
      </div>

      {/* Touch-Friendly Mobile Bottom Navigation Bar */}
      <MobileBottomNav activeTab={activeTab} setActiveTab={setActiveTab} />
    </div>
  );
}
