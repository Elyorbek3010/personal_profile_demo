import React, { useState, useEffect, useRef } from 'react';
import {
  User,
  Camera,
  Save,
  Edit3,
  X,
  CheckCircle2,
  GraduationCap,
  Phone,
  Mail,
  Calendar,
  Building2,
  BookOpen,
  Users,
  FileText,
  Sparkles,
  Trash2
} from 'lucide-react';

const STORAGE_KEY = 'student_profile';
const AVATAR_KEY = 'student_avatar';

const DEFAULT_PROFILE = {
  firstName: '',
  lastName: '',
  age: '',
  birthDate: '',
  university: 'JDU',
  faculty: '',
  direction: '',
  course: '',
  group: '',
  phone: '',
  email: '',
  bio: ''
};

/** localStorage dan profilni yuklash */
function loadProfile() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) return { ...DEFAULT_PROFILE, ...JSON.parse(saved) };
  } catch (e) {
    console.error('Profile load error:', e);
  }
  return { ...DEFAULT_PROFILE };
}

/** localStorage dan avatarni yuklash */
function loadAvatar() {
  try {
    return localStorage.getItem(AVATAR_KEY) || null;
  } catch (e) {
    return null;
  }
}

export default function Profile() {
  const [profile, setProfile] = useState(loadProfile);
  const [avatar, setAvatar] = useState(loadAvatar);
  const [isEditing, setIsEditing] = useState(false);
  const [editForm, setEditForm] = useState({ ...DEFAULT_PROFILE });
  const [saveNotice, setSaveNotice] = useState(null);
  const fileInputRef = useRef(null);

  // Form tahrirlashni boshlash
  const startEditing = () => {
    setEditForm({ ...profile });
    setIsEditing(true);
    setSaveNotice(null);
  };

  // Tahrirlashni bekor qilish
  const cancelEditing = () => {
    setIsEditing(false);
    setSaveNotice(null);
  };

  // Profilni saqlash
  const saveProfile = () => {
    // Yoshni tug'ilgan sanadan hisoblash
    const updatedForm = { ...editForm };
    if (updatedForm.birthDate) {
      const birth = new Date(updatedForm.birthDate);
      const today = new Date();
      let age = today.getFullYear() - birth.getFullYear();
      const monthDiff = today.getMonth() - birth.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
        age--;
      }
      updatedForm.age = String(age);
    }

    setProfile(updatedForm);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(updatedForm));
    window.dispatchEvent(new Event('profile-updated'));
    setIsEditing(false);
    setSaveNotice({ type: 'success', message: "Profil ma'lumotlari muvaffaqiyatli saqlandi!" });
    setTimeout(() => setSaveNotice(null), 4000);
  };

  // Profil rasmini yuklash
  const handleAvatarUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      setSaveNotice({ type: 'error', message: "Faqat rasm fayllarini yuklash mumkin." });
      setTimeout(() => setSaveNotice(null), 3000);
      return;
    }

    if (file.size > 2 * 1024 * 1024) {
      setSaveNotice({ type: 'error', message: "Rasm hajmi 2MB dan oshmasligi kerak." });
      setTimeout(() => setSaveNotice(null), 3000);
      return;
    }

    const reader = new FileReader();
    reader.onload = (evt) => {
      const dataUrl = evt.target.result;
      setAvatar(dataUrl);
      localStorage.setItem(AVATAR_KEY, dataUrl);
      window.dispatchEvent(new Event('profile-updated'));
      setSaveNotice({ type: 'success', message: "Profil rasmi yangilandi!" });
      setTimeout(() => setSaveNotice(null), 3000);
    };
    reader.readAsDataURL(file);
    // Reset input to allow re-uploading same file
    e.target.value = '';
  };

  // Profil rasmini o'chirish
  const removeAvatar = () => {
    setAvatar(null);
    localStorage.removeItem(AVATAR_KEY);
    window.dispatchEvent(new Event('profile-updated'));
    setSaveNotice({ type: 'success', message: "Profil rasmi olib tashlandi." });
    setTimeout(() => setSaveNotice(null), 3000);
  };

  // Form field o'zgarishi
  const handleChange = (field, value) => {
    setEditForm(prev => ({ ...prev, [field]: value }));
  };


  // Ma'lumot ko'rsatish maydonlari konfiguratsiyasi
  const fieldConfig = [
    { key: 'firstName', label: 'Ism', icon: User, placeholder: 'Elyorbek', type: 'text' },
    { key: 'lastName', label: 'Familiya', icon: User, placeholder: 'Amirullayev', type: 'text' },
    { key: 'birthDate', label: "Tug'ilgan sana", icon: Calendar, placeholder: '', type: 'date' },
    { key: 'age', label: 'Yosh', icon: Calendar, placeholder: 'Avtomatik hisoblanadi', type: 'number', disabled: true },
    { key: 'university', label: 'Universitet', icon: Building2, placeholder: "Toshkent Axborot Texnologiyalari Universiteti", type: 'text' },
    { key: 'faculty', label: 'Fakultet', icon: GraduationCap, placeholder: "Kompyuter injiniringi", type: 'text' },
    { key: 'direction', label: "Yo'nalish", icon: BookOpen, placeholder: "Dasturiy injiniring", type: 'text' },
    { key: 'course', label: 'Kurs', icon: GraduationCap, placeholder: '3', type: 'select', options: ['1', '2', '3', '4', '5', '6'] },
    { key: 'group', label: 'Guruh', icon: Users, placeholder: 'KI-21-04', type: 'text' },
    { key: 'phone', label: 'Telefon raqami', icon: Phone, placeholder: '+998 90 123 45 67', type: 'tel' },
    { key: 'email', label: 'Email', icon: Mail, placeholder: 'talaba@univer.uz', type: 'email' },
  ];

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-2xl gradient-bg flex items-center justify-center text-white shadow-lg shadow-indigo-600/30">
            <User size={22} />
          </div>
          <div>
            <h1 className="text-xl sm:text-2xl font-bold text-white tracking-tight">Talaba Profili</h1>
            <p className="text-xs text-slate-400">Shaxsiy ma'lumotlaringizni boshqaring</p>
          </div>
        </div>

        {/* Edit / Save Buttons */}
        <div className="flex items-center gap-2">
          {isEditing ? (
            <>
              <button
                onClick={cancelEditing}
                className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 transition text-xs font-semibold"
              >
                <X size={15} />
                <span>Bekor qilish</span>
              </button>
              <button
                onClick={saveProfile}
                className="flex items-center gap-1.5 px-5 py-2.5 rounded-xl gradient-bg text-white shadow-lg shadow-indigo-600/30 hover:opacity-95 transition text-xs font-semibold"
              >
                <Save size={15} />
                <span>Saqlash</span>
              </button>
            </>
          ) : (
            <button
              onClick={startEditing}
              className="flex items-center gap-1.5 px-5 py-2.5 rounded-xl gradient-bg text-white shadow-lg shadow-indigo-600/30 hover:opacity-95 transition text-xs font-semibold"
            >
              <Edit3 size={15} />
              <span>Tahrirlash</span>
            </button>
          )}
        </div>
      </div>

      {/* Save Notice */}
      {saveNotice && (
        <div className={`p-3 rounded-xl text-xs flex items-center gap-2 animate-slideDown ${
          saveNotice.type === 'success'
            ? 'bg-emerald-500/10 border border-emerald-500/30 text-emerald-300'
            : 'bg-rose-500/10 border border-rose-500/30 text-rose-300'
        }`}>
          <CheckCircle2 size={16} className={saveNotice.type === 'success' ? 'text-emerald-400' : 'text-rose-400'} />
          <span>{saveNotice.message}</span>
        </div>
      )}

      {/* Profile Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">

        {/* Left Column: Avatar & Summary Card */}
        <div className="lg:col-span-4 space-y-5">
          {/* Avatar Card */}
          <div className="glass-panel rounded-3xl border border-slate-800 p-6 text-center space-y-4">
            {/* Avatar */}
            <div className="relative inline-block group">
              <div className="w-28 h-28 sm:w-32 sm:h-32 rounded-full overflow-hidden border-[3px] border-indigo-500/40 shadow-xl shadow-indigo-600/20 mx-auto bg-slate-800">
                {avatar ? (
                  <img src={avatar} alt="Profil rasmi" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-indigo-600 to-purple-600">
                    <span className="text-3xl sm:text-4xl font-bold text-white">
                      {profile.firstName && profile.lastName
                        ? `${profile.firstName[0]}${profile.lastName[0]}`.toUpperCase()
                        : '?'}
                    </span>
                  </div>
                )}
              </div>
              {/* Camera overlay */}
              <button
                onClick={() => fileInputRef.current?.click()}
                className="absolute bottom-1 right-1 w-9 h-9 rounded-full gradient-bg text-white flex items-center justify-center shadow-lg border-2 border-[#070b14] hover:scale-110 transition transform cursor-pointer"
                title="Rasm yuklash"
              >
                <Camera size={16} />
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleAvatarUpload}
                className="hidden"
              />
            </div>

            {/* Name & Role */}
            <div>
              <h2 className="text-lg font-bold text-white">
                {profile.firstName || profile.lastName
                  ? `${profile.firstName} ${profile.lastName}`.trim()
                  : "Ism kiritilmagan"}
              </h2>
              <p className="text-xs text-indigo-300 font-medium mt-1">
                {profile.direction || "Yo'nalish ko'rsatilmagan"}
              </p>
            </div>

            {/* Remove avatar */}
            {avatar && (
              <button
                onClick={removeAvatar}
                className="inline-flex items-center gap-1.5 text-[11px] text-rose-400 hover:text-rose-300 transition"
              >
                <Trash2 size={12} />
                <span>Rasmni olib tashlash</span>
              </button>
            )}

            {/* Quick Info Chips */}
            <div className="flex flex-wrap justify-center gap-2 pt-2">
              {profile.course && (
                <span className="px-2.5 py-1 rounded-lg bg-indigo-500/10 text-indigo-300 text-[11px] font-semibold border border-indigo-500/20">
                  {profile.course}-kurs
                </span>
              )}
              {profile.group && (
                <span className="px-2.5 py-1 rounded-lg bg-purple-500/10 text-purple-300 text-[11px] font-semibold border border-purple-500/20">
                  {profile.group}
                </span>
              )}
              {profile.age && (
                <span className="px-2.5 py-1 rounded-lg bg-emerald-500/10 text-emerald-300 text-[11px] font-semibold border border-emerald-500/20">
                  {profile.age} yosh
                </span>
              )}
            </div>
          </div>


          {/* Bio Card */}
          <div className="glass-panel rounded-3xl border border-slate-800 p-5 space-y-3">
            <div className="flex items-center gap-2 text-xs font-semibold text-slate-300">
              <FileText size={14} className="text-indigo-400" />
              <span>O'zi haqida</span>
            </div>
            {isEditing ? (
              <textarea
                value={editForm.bio}
                onChange={(e) => handleChange('bio', e.target.value)}
                placeholder="O'zingiz haqingizda qisqacha yozing..."
                rows={4}
                maxLength={300}
                className="w-full bg-slate-900/90 text-white text-xs px-3.5 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-600 resize-none"
              />
            ) : (
              <p className="text-xs text-slate-400 leading-relaxed">
                {profile.bio || "Hali ma'lumot kiritilmagan. Tahrirlash tugmasini bosib yozing."}
              </p>
            )}
            {isEditing && (
              <p className="text-[10px] text-slate-600 text-right">{editForm.bio.length}/300</p>
            )}
          </div>
        </div>

        {/* Right Column: Profile Details Form/View */}
        <div className="lg:col-span-8">
          <div className="glass-panel rounded-3xl border border-slate-800 p-5 sm:p-7 space-y-1">
            <div className="flex items-center gap-2 mb-5">
              <h3 className="text-sm font-bold text-white">Shaxsiy Ma'lumotlar</h3>
              {isEditing && (
                <span className="px-2 py-0.5 rounded-md bg-amber-500/10 text-amber-300 text-[10px] font-semibold border border-amber-500/20">
                  Tahrirlash rejimi
                </span>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {fieldConfig.map((field) => {
                const Icon = field.icon;
                const value = isEditing ? editForm[field.key] : profile[field.key];
                return (
                  <div key={field.key} className="space-y-1.5">
                    <label className="flex items-center gap-1.5 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                      <Icon size={13} className="text-indigo-400" />
                      {field.label}
                    </label>
                    {isEditing ? (
                      field.type === 'select' ? (
                        <select
                          value={editForm[field.key]}
                          onChange={(e) => handleChange(field.key, e.target.value)}
                          className="w-full bg-slate-900/90 text-white text-xs px-3.5 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition appearance-none cursor-pointer"
                        >
                          <option value="">Tanlang...</option>
                          {field.options.map(opt => (
                            <option key={opt} value={opt}>{opt}-kurs</option>
                          ))}
                        </select>
                      ) : (
                        <input
                          type={field.type}
                          value={editForm[field.key]}
                          onChange={(e) => handleChange(field.key, e.target.value)}
                          placeholder={field.placeholder}
                          disabled={field.disabled}
                          className={`w-full bg-slate-900/90 text-white text-xs px-3.5 py-3 rounded-xl border border-slate-700/80 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none transition placeholder:text-slate-600 ${
                            field.disabled ? 'opacity-50 cursor-not-allowed' : ''
                          }`}
                        />
                      )
                    ) : (
                      <div className="px-3.5 py-3 rounded-xl bg-slate-900/50 border border-slate-800/60 text-xs min-h-[42px] flex items-center">
                        <span className={value ? 'text-slate-200' : 'text-slate-600 italic'}>
                          {field.key === 'course' && value ? `${value}-kurs` : value || "Kiritilmagan"}
                        </span>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>

            {/* Bottom action bar in edit mode */}
            {isEditing && (
              <div className="flex items-center justify-end gap-3 pt-5 mt-4 border-t border-slate-800/80">
                <button
                  onClick={cancelEditing}
                  className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 transition text-xs font-semibold"
                >
                  <X size={14} />
                  Bekor qilish
                </button>
                <button
                  onClick={saveProfile}
                  className="flex items-center gap-1.5 px-5 py-2.5 rounded-xl gradient-bg text-white shadow-lg shadow-indigo-600/30 hover:opacity-95 transition text-xs font-semibold"
                >
                  <Save size={14} />
                  O'zgarishlarni Saqlash
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
