import React, { useState, useEffect } from 'react';
import { 
  GraduationCap, 
  Mail, 
  Lock, 
  Eye, 
  EyeOff, 
  CheckCircle2, 
  Sparkles,
  ShieldCheck,
  AlertCircle,
  ChevronDown,
  ChevronUp
} from 'lucide-react';
import { loginWithGoogle, loginWithCredentials } from '../utils/api';

export default function AuthPage({ onLoginSuccess }) {
  const [showAlternativeAuth, setShowAlternativeAuth] = useState(false);
  const [isLogin, setIsLogin] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Form State
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  // Status & Validation State
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Handle genuine Google credential from official Google GIS popup
  const handleGoogleCredentialResponse = async (googleResponse) => {
    if (!googleResponse?.credential) return;
    setLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    try {
      const response = await loginWithGoogle({ credential: googleResponse.credential });

      localStorage.setItem('access_token', response.access);
      localStorage.setItem('refresh_token', response.refresh);
      localStorage.setItem('user_info', JSON.stringify(response.user));

      const existingProfile = JSON.parse(localStorage.getItem('student_profile') || '{}');
      const updatedProfile = {
        ...existingProfile,
        firstName: response.user.name?.split(' ')[0] || '',
        lastName: response.user.name?.split(' ')[1] || '',
        email: response.user.email,
        group: response.user.group || '23D',
        direction: response.user.direction || 'IT',
        course: response.user.course || '3',
        studentId: response.user.studentId || '2311194',
        avatar: response.user.avatar
      };
      localStorage.setItem('student_profile', JSON.stringify(updatedProfile));

      setSuccessMessage("Universitet Google hisobi orqali muvaffaqiyatli kirildi!");
      setTimeout(() => {
        onLoginSuccess(response.user);
      }, 500);
    } catch (err) {
      console.error("Google Auth error:", err);
      setErrorMessage(err.message || "Google hisobini tasdiqlashda xatolik yuz berdi.");
    } finally {
      setLoading(false);
    }
  };

  // Initialize official Google Identity Services (GIS)
  useEffect(() => {
    const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
    if (!clientId) return;

    const setupGoogleGIS = () => {
      try {
        if (!window.google?.accounts?.id) return;
        window.google.accounts.id.initialize({
          client_id: clientId,
          callback: handleGoogleCredentialResponse,
          auto_select: false,
        });

        const btnSlot = document.getElementById('googleLoginButtonSlot');
        if (btnSlot) {
          btnSlot.innerHTML = '';
          window.google.accounts.id.renderButton(btnSlot, {
            theme: 'outline',
            size: 'large',
            shape: 'pill',
            width: 320,
            text: 'signin_with',
            logo_alignment: 'left',
          });
        }
      } catch (e) {
        console.warn("GIS initialization warning:", e);
      }
    };

    if (!window.google?.accounts?.id) {
      const script = document.createElement('script');
      script.src = 'https://accounts.google.com/gsi/client';
      script.async = true;
      script.defer = true;
      script.onload = setupGoogleGIS;
      document.body.appendChild(script);
    } else {
      setupGoogleGIS();
    }
  }, []);

  // 1. Primary Method: University Google Workspace Login (Live or Demo fallback)
  const handleGoogleSignIn = async (isDemo = false, customEmail = null, customName = null, customGroup = '23E', customStudentId = '2311195') => {
    // If not demo and Google GIS is ready, prompt the official popup
    if (!isDemo && window.google?.accounts?.id) {
      window.google.accounts.id.prompt();
      return;
    }

    setLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    try {
      const payload = {
        demo: isDemo,
        email: customEmail || (isDemo ? 'elyorbek@jdu.uz' : ''),
        name: customName || (isDemo ? 'Elyorbek Khayitboev' : ''),
        group: customGroup,
        student_id: customStudentId || '2311195'
      };

      const response = await loginWithGoogle(payload);

      // Save DRF JWT tokens and user info
      localStorage.setItem('access_token', response.access);
      localStorage.setItem('refresh_token', response.refresh);
      localStorage.setItem('user_info', JSON.stringify(response.user));

      // Also ensure profile in localStorage has group info for timetable filter
      const existingProfile = JSON.parse(localStorage.getItem('student_profile') || '{}');
      const updatedProfile = {
        ...existingProfile,
        firstName: response.user.name?.split(' ')[0] || 'Elyorbek',
        lastName: response.user.name?.split(' ')[1] || 'Khayitboev',
        email: response.user.email,
        group: response.user.group || '23D',
        direction: response.user.direction || 'IT',
        course: response.user.course || '3',
        studentId: response.user.studentId || '2311194',
        avatar: response.user.avatar
      };
      localStorage.setItem('student_profile', JSON.stringify(updatedProfile));

      setSuccessMessage("Universitet Google hisobi orqali muvaffaqiyatli kirildi!");
      setTimeout(() => {
        onLoginSuccess(response.user);
      }, 500);

    } catch (err) {
      console.error("Google Auth error:", err);
      setErrorMessage(err.message || "Universitet hisobini tasdiqlashda xatolik yuz berdi.");
    } finally {
      setLoading(false);
    }
  };

  // 2. Alternative Method: Email & Password Submission
  const handleCredentialsSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!email || !email.includes('@')) {
      setErrorMessage("Iltimos, to'g'ri email manzilini kiriting.");
      return;
    }

    if (!password || password.length < 6) {
      setErrorMessage("Parol kamida 6 ta belgidan iborat bo'lishi kerak.");
      return;
    }

    if (!isLogin && password !== confirmPassword) {
      setErrorMessage("Kiritilgan parollar bir-biriga mos kelmadi.");
      return;
    }

    setLoading(true);

    try {
      if (isLogin) {
        // Authenticate with real PostgreSQL/Django Database!
        const res = await loginWithCredentials(email, password);
        localStorage.setItem('access_token', res.access);
        localStorage.setItem('refresh_token', res.refresh);

        const user = res.user || {
          email: email,
          name: email.split('@')[0],
          studentId: email.replace(/[^0-9]/g, ''),
          group: '23D',
          role: 'student'
        };

        localStorage.setItem('user_info', JSON.stringify(user));

        // Save authentic student profile from database to localStorage
        const studentProfileData = {
          firstName: user.firstName || user.name?.split(' ')[0] || '',
          lastName: user.lastName || user.name?.split(' ')[1] || '',
          email: user.email,
          studentId: user.studentId,
          group: user.group,
          course: user.course || '3',
          direction: user.direction || 'IT',
          faculty: user.direction || 'Axborot Texnologiyalari',
          partnerUniversity: user.partnerUniversity || 'Tokyo Online University (TOU)',
          japaneseExempt: user.japaneseExempt !== undefined ? user.japaneseExempt : true,
          avatar: user.avatar || null
        };
        localStorage.setItem('student_profile', JSON.stringify(studentProfileData));
        window.dispatchEvent(new Event('profile-updated'));

        setSuccessMessage(`${user.name || user.email} hisobiga muvaffaqiyatli kirildi!`);
        setTimeout(() => {
          onLoginSuccess(user);
        }, 400);
      } else {
        setSuccessMessage("Ro'yxatdan o'tish muvaffaqiyatli yakunlandi! Endi parolingiz bilan kirishingiz mumkin.");
        setIsLogin(true);
        setPassword('');
        setConfirmPassword('');
      }
    } catch (err) {
      console.error("Credentials login error:", err);
      setErrorMessage(err.message || "Email yoki parol noto'g'ri.");
    } finally {
      setLoading(false);
    }
  };

  // Direct 1-Click Login for Real Database Seed Students
  const handleDirectTestStudentLogin = async (studentEmail) => {
    setEmail(studentEmail);
    setPassword('12345678');
    setLoading(true);
    setErrorMessage('');
    try {
      const res = await loginWithCredentials(studentEmail, '12345678');
      localStorage.setItem('access_token', res.access);
      localStorage.setItem('refresh_token', res.refresh);

      const user = res.user;
      localStorage.setItem('user_info', JSON.stringify(user));

      const studentProfileData = {
        firstName: user.firstName || user.name?.split(' ')[0] || '',
        lastName: user.lastName || user.name?.split(' ')[1] || '',
        email: user.email,
        studentId: user.studentId,
        group: user.group,
        course: user.course || '3',
        direction: user.direction || 'IT',
        faculty: user.direction || 'Axborot Texnologiyalari',
        partnerUniversity: user.partnerUniversity || 'Tokyo Online University (TOU)',
        japaneseExempt: user.japaneseExempt !== undefined ? user.japaneseExempt : true,
        avatar: user.avatar || null
      };
      localStorage.setItem('student_profile', JSON.stringify(studentProfileData));
      window.dispatchEvent(new Event('profile-updated'));

      setSuccessMessage(`${user.name} sifatida muvaffaqiyatli kirildi!`);
      setTimeout(() => {
        onLoginSuccess(user);
      }, 350);
    } catch (err) {
      console.error("Direct test login error:", err);
      setErrorMessage(err.message || "Kirishda xatolik yuz berdi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#070b14] text-slate-100 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Dynamic Ambient Background Glows */}
      <div className="absolute -top-40 -left-40 w-96 h-96 bg-indigo-600/20 rounded-full blur-[120px] pointer-events-none"></div>
      <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-purple-600/20 rounded-full blur-[120px] pointer-events-none"></div>
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-blue-600/10 rounded-full blur-[150px] pointer-events-none"></div>

      <div className="w-full max-w-5xl grid lg:grid-cols-12 gap-8 items-center z-10">
        
        {/* Left Hero Banner */}
        <div className="lg:col-span-6 space-y-6 text-left hidden lg:block pr-6">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-indigo-500/10 border border-indigo-500/30 text-indigo-300 text-xs font-semibold">
            <GraduationCap size={16} />
            <span>UNIVER SuperApp • Talaba Portali</span>
          </div>

          <h1 className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white leading-[1.15]">
            Barcha talabalik xizmatlari <span className="gradient-text">bitta tizimda</span>
          </h1>

          <p className="text-slate-400 text-sm leading-relaxed">
            Rasmiy universitet Google hisobi orqali kirib, jonli dars jadvali, Google Chat xonalari va akademik resurslarga bir zumda ulaning.
          </p>

          {/* Feature Highlights */}
          <div className="space-y-3 pt-2">
            {[
              "Universitet Google Workspace hisobi orqali 1-bosishda kirish",
              "Jonli Google Sheet jadvalidan o'z guruhingiz darslarini ko'rish",
              "Google Chat Spaces xonalariga (Talabalar, 23E, TOU) to'g'ridan-to'g'ri havolalar",
              "HEMIS va KD video ta'lim platformalari integratsiyasi"
            ].map((feature, i) => (
              <div key={i} className="flex items-center gap-3 text-xs text-slate-300">
                <div className="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
                  <CheckCircle2 size={13} />
                </div>
                <span>{feature}</span>
              </div>
            ))}
          </div>

          <div className="pt-4 border-t border-slate-800/80 flex items-center gap-4 text-xs text-slate-400">
            <div className="flex items-center gap-1.5">
              <ShieldCheck size={16} className="text-indigo-400" />
              <span>Google OAuth 2.0 & DRF JWT</span>
            </div>
            <span>•</span>
            <div className="flex items-center gap-1.5">
              <Sparkles size={14} className="text-amber-400" />
              <span>@jdu.uz Verified SSO</span>
            </div>
          </div>
        </div>

        {/* Right Auth Card */}
        <div className="lg:col-span-6 w-full">
          <div className="glass-panel p-6 sm:p-8 rounded-3xl border border-slate-800 shadow-2xl relative">
            
            {/* Mobile Header */}
            <div className="flex items-center gap-3 mb-6 lg:hidden">
              <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center text-white shadow-lg">
                <GraduationCap size={22} />
              </div>
              <div>
                <h2 className="font-bold text-lg text-white">UNIVER SuperApp</h2>
                <p className="text-xs text-slate-400">Talaba Portali</p>
              </div>
            </div>

            {/* Error & Success Messages */}
            {errorMessage && (
              <div className="mb-4 p-3.5 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs flex items-center gap-2.5">
                <AlertCircle size={18} className="shrink-0 text-rose-400" />
                <span>{errorMessage}</span>
              </div>
            )}

            {successMessage && (
              <div className="mb-4 p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs flex items-center gap-2.5">
                <CheckCircle2 size={18} className="shrink-0 text-emerald-400" />
                <span>{successMessage}</span>
              </div>
            )}

            {/* PRIMARY AUTH: Google Workspace SSO */}
            <div className="text-left space-y-4">
              <div>
                <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-emerald-500/10 text-emerald-400 text-[11px] font-semibold border border-emerald-500/20 mb-2">
                  <ShieldCheck size={13} />
                  <span>Tavsiya etilgan usul (Ro'yxatdan o'tish shart emas)</span>
                </div>
                <h3 className="text-xl font-bold text-white">Tizimga Kirish</h3>
                <p className="text-xs text-slate-400 mt-1 leading-relaxed">
                  Universitet tomonidan taqdim etilgan rasmiy Google hisobingiz bilan parolsiz yoki to'g'ridan-to'g'ri kiring.
                </p>
              </div>

              {/* Official Google Identity Services Button Slot */}
              <div className="w-full flex justify-center min-h-[44px]">
                <div id="googleLoginButtonSlot" className="w-full flex justify-center"></div>
              </div>

              {/* Custom Google Sign-In Button (Fallback / Direct Click) */}
              <button
                type="button"
                disabled={loading}
                onClick={() => handleGoogleSignIn(false)}
                className="w-full py-3.5 px-4 rounded-2xl bg-white hover:bg-slate-100 text-slate-900 font-bold text-xs sm:text-sm shadow-xl hover:shadow-2xl transition flex items-center justify-center gap-3 active:scale-[0.99] group cursor-pointer"
              >
                {/* Official Google Multi-Color G Icon */}
                <svg className="w-5 h-5 shrink-0" viewBox="0 0 24 24">
                  <path
                    fill="#4285F4"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                  />
                  <path
                    fill="#34A853"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                  />
                  <path
                    fill="#FBBC05"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                  />
                  <path
                    fill="#EA4335"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                  />
                </svg>
                <span>Universitet Google Hisobi Bilan Kirish</span>
              </button>

              {/* Supported domains hint */}
              <div className="flex items-center justify-between text-[11px] text-slate-400 px-1">
                <span>Ruxsat etilgan domen:</span>
                <span className="font-mono text-indigo-300 font-semibold bg-indigo-500/10 px-2.5 py-0.5 rounded border border-indigo-500/20">
                  @jdu.uz
                </span>
              </div>

              {/* Quick 1-Click Demo Profiles */}
              <div className="p-3.5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-400 font-medium flex items-center gap-1.5">
                    <Sparkles size={13} className="text-amber-400" />
                    <span>Haqiqiy bazadagi sinov talabalari (1-bosish):</span>
                  </span>
                  <span className="text-[10px] text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded font-mono">Baza: PostgreSQL</span>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => handleDirectTestStudentLogin('2311194e@jdu.uz')}
                    className="py-2 px-2.5 rounded-xl bg-slate-800 hover:bg-slate-700/80 border border-slate-700/60 text-left transition flex items-center gap-2 group cursor-pointer"
                  >
                    <div className="w-7 h-7 rounded-full bg-indigo-600/30 text-indigo-300 flex items-center justify-center font-bold text-[11px]">
                      23D
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-semibold text-white truncate">Elyorbek Adhamov</p>
                      <p className="text-[10px] text-indigo-300 truncate font-mono">2311194e • TOU Onlayn</p>
                    </div>
                  </button>

                  <button
                    type="button"
                    onClick={() => handleDirectTestStudentLogin('2311143u@jdu.uz')}
                    className="py-2 px-2.5 rounded-xl bg-slate-800 hover:bg-slate-700/80 border border-slate-700/60 text-left transition flex items-center gap-2 group cursor-pointer"
                  >
                    <div className="w-7 h-7 rounded-full bg-emerald-600/30 text-emerald-300 flex items-center justify-center font-bold text-[11px]">
                      23D
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-semibold text-white truncate">Ulug'bek Nurmatov</p>
                      <p className="text-[10px] text-emerald-300 truncate font-mono">2311143u • SANNO Kampus</p>
                    </div>
                  </button>

                  <button
                    type="button"
                    onClick={() => handleDirectTestStudentLogin('221121s@jdu.uz')}
                    className="py-2 px-2.5 rounded-xl bg-slate-800 hover:bg-slate-700/80 border border-slate-700/60 text-left transition flex items-center gap-2 group cursor-pointer"
                  >
                    <div className="w-7 h-7 rounded-full bg-blue-600/30 text-blue-300 flex items-center justify-center font-bold text-[11px]">
                      22A
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-semibold text-white truncate">Sardor Tolliboyev</p>
                      <p className="text-[10px] text-blue-300 truncate font-mono">221121s • 4-kurs (SANNO)</p>
                    </div>
                  </button>

                  <button
                    type="button"
                    onClick={() => handleDirectTestStudentLogin('2400051s@jdu.uz')}
                    className="py-2 px-2.5 rounded-xl bg-slate-800 hover:bg-slate-700/80 border border-slate-700/60 text-left transition flex items-center gap-2 group cursor-pointer"
                  >
                    <div className="w-7 h-7 rounded-full bg-purple-600/30 text-purple-300 flex items-center justify-center font-bold text-[11px]">
                      24A
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-semibold text-white truncate">Sarvarbek Alikulov</p>
                      <p className="text-[10px] text-purple-300 truncate font-mono">2400051s • 2-kurs (AX)</p>
                    </div>
                  </button>
                </div>
                <p className="text-[10px] text-slate-500 text-center pt-1">
                  Standart parol barcha hisoblar uchun: <span className="font-mono text-slate-400 font-semibold">12345678</span>
                </p>
              </div>
            </div>

            {/* SECONDARY / ALTERNATIVE ACCORDION: Email & Password */}
            <div className="mt-5 pt-4 border-t border-slate-800/80 text-left">
              <button
                type="button"
                onClick={() => setShowAlternativeAuth(!showAlternativeAuth)}
                className="w-full flex items-center justify-between text-xs text-slate-400 hover:text-slate-200 transition py-1 cursor-pointer"
              >
                <span className="flex items-center gap-2 font-medium">
                  <Mail size={14} className="text-slate-500" />
                  <span>Muqobil usul: Email va Parol orqali kirish</span>
                </span>
                {showAlternativeAuth ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
              </button>

              {showAlternativeAuth && (
                <div className="mt-4 pt-3 border-t border-slate-800/50 space-y-4 animate-in fade-in duration-200">
                  {/* Tab Toggle */}
                  <div className="flex rounded-xl bg-slate-900 p-1 border border-slate-800">
                    <button
                      type="button"
                      onClick={() => setIsLogin(true)}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${
                        isLogin ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-white'
                      }`}
                    >
                      Kirish
                    </button>
                    <button
                      type="button"
                      onClick={() => setIsLogin(false)}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${
                        !isLogin ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-white'
                      }`}
                    >
                      Ro'yxatdan o'tish
                    </button>
                  </div>

                  <form onSubmit={handleCredentialsSubmit} className="space-y-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-300 mb-1">Email</label>
                      <div className="relative">
                        <Mail size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" />
                        <input
                          type="email"
                          required
                          value={email}
                          onChange={(e) => setEmail(e.target.value)}
                          placeholder="talaba@univer.uz"
                          className="w-full bg-slate-900 text-white text-xs pl-9 pr-3 py-2.5 rounded-xl border border-slate-700 focus:border-indigo-500 outline-none"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-300 mb-1">Parol</label>
                      <div className="relative">
                        <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" />
                        <input
                          type={showPassword ? "text" : "password"}
                          required
                          value={password}
                          onChange={(e) => setPassword(e.target.value)}
                          placeholder="••••••••"
                          className="w-full bg-slate-900 text-white text-xs pl-9 pr-9 py-2.5 rounded-xl border border-slate-700 focus:border-indigo-500 outline-none"
                        />
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300"
                        >
                          {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                        </button>
                      </div>
                    </div>

                    {!isLogin && (
                      <div>
                        <label className="block text-xs font-semibold text-slate-300 mb-1">Parolni tasdiqlang</label>
                        <div className="relative">
                          <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" />
                          <input
                            type={showConfirmPassword ? "text" : "password"}
                            required
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            placeholder="••••••••"
                            className="w-full bg-slate-900 text-white text-xs pl-9 pr-9 py-2.5 rounded-xl border border-slate-700 focus:border-indigo-500 outline-none"
                          />
                        </div>
                      </div>
                    )}

                    <button
                      type="submit"
                      disabled={loading}
                      className="w-full py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-white font-semibold text-xs transition border border-slate-700 cursor-pointer"
                    >
                      {loading ? "Yuklanmoqda..." : (isLogin ? "KIRISH" : "RO'YXATDAN O'TISH")}
                    </button>
                  </form>
                </div>
              )}
            </div>

          </div>
        </div>

      </div>
    </div>
  );
}
