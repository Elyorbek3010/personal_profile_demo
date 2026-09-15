import React, { useState } from 'react';
import { 
  GraduationCap, 
  Mail, 
  Lock, 
  Eye, 
  EyeOff, 
  ArrowRight, 
  CheckCircle2, 
  Sparkles,
  ShieldCheck,
  AlertCircle
} from 'lucide-react';

export default function AuthPage({ onLoginSuccess }) {
  const [isLogin, setIsLogin] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Form State
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(true);

  // Status & Validation State
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Handle Submission (Login or Register via Email & Password)
  const handleSubmit = (e) => {
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

    // Simulate Django REST Framework (DRF) JWT Authentication API call
    setTimeout(() => {
      setLoading(false);

      if (isLogin) {
        // Save mock DRF JWT tokens to localStorage
        const mockJwtResponse = {
          access: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockAccessKey2026",
          refresh: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockRefreshKey2026",
          user: {
            email: email,
            name: email.split('@')[0],
            role: "student"
          }
        };

        localStorage.setItem('access_token', mockJwtResponse.access);
        localStorage.setItem('refresh_token', mockJwtResponse.refresh);
        localStorage.setItem('user_info', JSON.stringify(mockJwtResponse.user));

        onLoginSuccess(mockJwtResponse.user);
      } else {
        // Registration success
        setSuccessMessage("Ro'yxatdan o'tish muvaffaqiyatli yakunlandi! Endi kirishingiz mumkin.");
        setIsLogin(true);
        setPassword('');
        setConfirmPassword('');
      }
    }, 900);
  };

  // Quick Demo Auto-fill
  const handleQuickDemo = () => {
    setEmail('elyorbek@univer.uz');
    setPassword('student2026');
    setErrorMessage('');
  };

  return (
    <div className="min-h-screen bg-[#070b14] text-slate-100 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Dynamic Background Glows */}
      <div className="absolute -top-40 -left-40 w-96 h-96 bg-indigo-600/20 rounded-full blur-[120px] pointer-events-none"></div>
      <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-purple-600/20 rounded-full blur-[120px] pointer-events-none"></div>

      <div className="w-full max-w-5xl grid lg:grid-cols-12 gap-8 items-center z-10">
        
        {/* Left Hero Banner */}
        <div className="lg:col-span-6 space-y-6 text-left hidden lg:block pr-6">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-indigo-500/10 border border-indigo-500/30 text-indigo-300 text-xs font-semibold">
            <GraduationCap size={16} />
            <span>Univer SuperApp Platformasi</span>
          </div>

          <h1 className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white leading-[1.15]">
            Barcha talabalik xizmatlari <span className="gradient-text">bitta tizimda</span>
          </h1>

          <p className="text-slate-400 text-sm leading-relaxed">
            Excel dars jadvallarini avtomatik AI tahlili, HEMIS baholar va davomat monitoringi hamda KD platformasi video darsliklariga tezkor kirish.
          </p>

          {/* Feature Highlights */}
          <div className="space-y-3 pt-2">
            {[
              "Email va Xavfsiz Parol orqali Kirish (DRF JWT Auth)",
              "Dars jadvallarini Excel fayllaridan UI da qidirish",
              "Davomat 85% dan tushganda o'z vaqtida ogohlantirish",
              "KD platformasi darsliklari va resurslari"
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
              <span>DRF JWT Protected</span>
            </div>
            <span>•</span>
            <div className="flex items-center gap-1.5">
              <Sparkles size={14} className="text-amber-400" />
              <span>Univer Student SSO</span>
            </div>
          </div>
        </div>

        {/* Right Auth Form Card */}
        <div className="lg:col-span-6 w-full">
          <div className="glass-panel p-6 sm:p-8 rounded-3xl border border-slate-800 shadow-2xl relative">
            
            {/* Logo header for mobile */}
            <div className="flex items-center gap-3 mb-6 lg:hidden">
              <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center text-white shadow-lg">
                <GraduationCap size={22} />
              </div>
              <div>
                <h2 className="font-bold text-lg text-white">UNIVER SuperApp</h2>
                <p className="text-xs text-slate-400">Talaba Portali</p>
              </div>
            </div>

            {/* Tab Toggle: Kirish vs Ro'yxatdan O'tish */}
            <div className="flex rounded-2xl bg-slate-900/90 p-1.5 mb-6 border border-slate-800">
              <button
                type="button"
                onClick={() => { setIsLogin(true); setErrorMessage(''); setSuccessMessage(''); }}
                className={`flex-1 py-2.5 rounded-xl text-xs font-bold transition-all ${
                  isLogin 
                    ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-md' 
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                Kirish (Login)
              </button>
              <button
                type="button"
                onClick={() => { setIsLogin(false); setErrorMessage(''); setSuccessMessage(''); }}
                className={`flex-1 py-2.5 rounded-xl text-xs font-bold transition-all ${
                  !isLogin 
                    ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-md' 
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                Ro'yxatdan O'tish
              </button>
            </div>

            <div className="text-left mb-5">
              <h3 className="text-xl font-bold text-white">
                {isLogin ? "Tizimga Kirish" : "Yangi Hisob Yaratish"}
              </h3>
              <p className="text-xs text-slate-400 mt-1">
                {isLogin 
                  ? "Email va parolingizni kiritib shaxsiy kabinetingizga kiring" 
                  : "Email hamda parolingizni ko'rsatib ro'yxatdan o'ting"}
              </p>
            </div>

            {/* Error & Success Messages */}
            {errorMessage && (
              <div className="mb-4 p-3 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs flex items-center gap-2">
                <AlertCircle size={16} className="shrink-0 text-rose-400" />
                <span>{errorMessage}</span>
              </div>
            )}

            {successMessage && (
              <div className="mb-4 p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs flex items-center gap-2">
                <CheckCircle2 size={16} className="shrink-0 text-emerald-400" />
                <span>{successMessage}</span>
              </div>
            )}

            {/* Authentication Form */}
            <form onSubmit={handleSubmit} className="space-y-4 text-left">
              
              {/* Email Input */}
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                  Email Manzil <span className="text-indigo-400">*</span>
                </label>
                <div className="relative">
                  <Mail size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="masalan: talaba@univer.uz"
                    className="w-full bg-slate-900/90 text-white text-xs sm:text-sm pl-10 pr-4 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-600"
                  />
                </div>
              </div>

              {/* Password Input */}
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                  Parol <span className="text-indigo-400">*</span>
                </label>
                <div className="relative">
                  <Lock size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full bg-slate-900/90 text-white text-xs sm:text-sm pl-10 pr-10 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-600"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300 transition"
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              {/* Confirm Password (only on Register tab) */}
              {!isLogin && (
                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                    Parolni Tasdiqlang <span className="text-indigo-400">*</span>
                  </label>
                  <div className="relative">
                    <Lock size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
                    <input
                      type={showConfirmPassword ? "text" : "password"}
                      required
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full bg-slate-900/90 text-white text-xs sm:text-sm pl-10 pr-10 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-600"
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300 transition"
                    >
                      {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>
                </div>
              )}

              {/* Remember Me & Forgot Password */}
              {isLogin && (
                <div className="flex items-center justify-between text-xs pt-1">
                  <label className="flex items-center gap-2 text-slate-400 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={rememberMe}
                      onChange={(e) => setRememberMe(e.target.checked)}
                      className="w-4 h-4 rounded bg-slate-900 border-slate-700 text-indigo-600 focus:ring-indigo-500 focus:ring-offset-slate-900"
                    />
                    <span>Meni eslab qol (JWT Token)</span>
                  </label>
                  <a href="#" onClick={(e) => { e.preventDefault(); alert("Parolni qayta tiklash havolasi emailingizga yuboriladi."); }} className="text-indigo-400 hover:underline">
                    Parolni unutdingizmi?
                  </a>
                </div>
              )}

              {/* Submit Button */}
              <button
                type="submit"
                disabled={loading}
                className="w-full mt-2 py-3 rounded-xl gradient-bg text-white font-semibold text-xs sm:text-sm shadow-lg shadow-indigo-600/30 hover:opacity-95 transition flex items-center justify-center gap-2 group"
              >
                {loading ? (
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>{isLogin ? "KIRISH" : "RO'YXATDAN O'TISH"}</span>
                    <ArrowRight size={16} className="group-hover:translate-x-1 transition" />
                  </>
                )}
              </button>
            </form>

            {/* Quick Demo Helper Button */}
            <div className="mt-6 pt-5 border-t border-slate-800/80 flex items-center justify-between text-xs">
              <span className="text-slate-500">Sinov uchun tezkor to'ldirish:</span>
              <button
                type="button"
                onClick={handleQuickDemo}
                className="text-xs px-3 py-1 rounded-lg bg-indigo-500/10 text-indigo-300 hover:bg-indigo-500/20 border border-indigo-500/30 transition font-medium flex items-center gap-1.5"
              >
                <Sparkles size={12} className="text-amber-400" />
                <span>Demo ma'lumotlar</span>
              </button>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
}
