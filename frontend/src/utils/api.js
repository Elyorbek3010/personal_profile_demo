/**
 * UNIVER SuperApp - API Client & Backend Connection
 */

export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

/**
 * University Google Workspace OAuth login
 */
export async function loginWithGoogle({ credential, demo = false, email, name, group, student_id }) {
  try {
    const res = await fetch(`${API_BASE_URL}/auth/google/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ credential, demo, email, name, group, student_id }),
    });

    const data = await res.json();
    if (!res.ok) {
      throw new Error(data.error || data.detail || "Universitet hisobi bilan kirishda xatolik yuz berdi.");
    }
    return data;
  } catch (err) {
    // If backend server is not running or network fails, provide graceful error
    if (err.message.includes('Failed to fetch') || err.message.includes('NetworkError')) {
      throw new Error("Backend serverga ulanib bo'lmadi (http://localhost:8000). Server ishga tushirilganini tekshiring.");
    }
    throw err;
  }
}

/**
 * Standard Email/Password login
 */
export async function loginWithCredentials(email, password) {
  const res = await fetch(`${API_BASE_URL}/auth/login/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ username: email, password }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.detail || "Email yoki parol noto'g'ri.");
  }
  return data;
}
