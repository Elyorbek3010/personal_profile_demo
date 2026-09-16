import React, { useState, useEffect, useCallback } from 'react';
import AuthPage from './components/AuthPage';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import MobileBottomNav from './components/MobileBottomNav';
import Timetable from './pages/Timetable';
import Profile from './pages/Profile';
import { LogOut, CalendarDays, TrendingUp, Video, User, ShieldCheck } from 'lucide-react';

const VALID_TABS = ['timetable', 'grades', 'kd_courses', 'profile'];
const DEFAULT_TAB = 'timetable';

/** URL hash dan tab id ni olish (#timetable -> timetable) */
function getTabFromHash() {
  const hash = window.location.hash.replace('#', '');
  return VALID_TABS.includes(hash) ? hash : DEFAULT_TAB;
}

export default function App() {
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState(getTabFromHash);
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

  // --- Browser History Navigation ---
  // Ilk yuklashda hash bo'lmasa yoki noto'g'ri bo'lsa, URL ni to'g'rilab qo'yish
  useEffect(() => {
    const currentHash = window.location.hash.replace('#', '');
    if (!VALID_TABS.includes(currentHash)) {
      window.history.replaceState({ tab: DEFAULT_TAB }, '', `#${DEFAULT_TAB}`);
    } else if (!window.history.state?.tab) {
      // Mavjud hash to'g'ri, lekin state yo'q — replaceState bilan state qo'shish
      window.history.replaceState({ tab: currentHash }, '', `#${currentHash}`);
    }
  }, []);

  // popstate hodisasini tinglash (Back/Forward tugmalari)
  useEffect(() => {
    const handlePopState = (event) => {
      const tab = event.state?.tab || getTabFromHash();
      setActiveTab(tab);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // Tab o'zgartirganda history ga push qilish (Back/Forward uchun)
  const navigateTab = useCallback((tabId) => {
    if (!VALID_TABS.includes(tabId)) return;
    const currentHash = window.location.hash.replace('#', '');
    if (currentHash !== tabId) {
      window.history.pushState({ tab: tabId }, '', `#${tabId}`);
    }
    setActiveTab(tabId);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_info');
    setUser(null);
    // Logout qilganda history ni tozalash
    window.history.replaceState(null, '', window.location.pathname);
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
        setActiveTab={navigateTab}
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
          setActiveTab={navigateTab}
          onLogout={handleLogout}
          mobileMenuOpen={mobileMenuOpen}
          onCloseMobileMenu={() => setMobileMenuOpen(false)}
        />

        {/* Main Application Area */}
        <main className="flex-1 p-3 sm:p-6 lg:p-8 max-w-7xl mx-auto space-y-6 pb-20 lg:pb-8 w-full overflow-x-hidden">
          
          {/* Render Active View */}
          {activeTab === 'timetable' && <Timetable />}
          {activeTab === 'profile' && <Profile />}

          {/* Fallback Placeholder for upcoming modules */}
          {activeTab !== 'timetable' && activeTab !== 'profile' && (
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
                onClick={() => navigateTab('timetable')}
                className="px-5 py-2.5 rounded-xl gradient-bg text-white text-xs font-semibold shadow-lg hover:opacity-95 transition"
              >
                Dars Jadvaliga O'tish
              </button>
            </div>
          )}

        </main>
      </div>

      {/* Touch-Friendly Mobile Bottom Navigation Bar */}
      <MobileBottomNav activeTab={activeTab} setActiveTab={navigateTab} />
    </div>
  );
}
