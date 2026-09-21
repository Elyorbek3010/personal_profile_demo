"""
AI & Heuristic Timetable Parser Service for Japan Digital University (JDU).
Parses messy raw cell texts (e.g. '23C\nAI\n302\nMo\'minbek' or 'Asosiy Kurs ③ 402 Okamoto' or 'N2A:305\nN2D:208')
into clean, structured class attributes (subject, room, teacher, partner, is_japanese).
Uses Google Gemini AI when available and responsive, with an intelligent domain-aware heuristic engine fallback.
Includes caching and circuit breaker to protect against external API 503 / 429 timeouts.
"""
import os
import re
import json
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

GEMINI_MODELS = [
    'gemini-flash-latest',
    'gemini-3.6-flash',
]

_gemini_failures = 0
_MAX_GEMINI_FAILURES = 3
_parsed_cache = {}

def parse_with_gemini(raw_text_batch: list[str], api_key: str) -> list[dict] | None:
    """
    Sends a batch of raw timetable cell texts to Gemini AI.
    Returns structured JSON for each item.
    """
    if not api_key:
        return None

    prompt = f"""You are an expert university schedule parser for Japan Digital University (JDU).
Parse each of the following raw timetable cell contents into structured JSON.

JDU Context & Rules:
- Japanese Language / Prep classes: Any class mentioning N1, N2, N3, N4, N5, or 'Asosiy Kurs' (JDU main Japanese preparation track), or taught by Japanese faculty (Okamoto, Yasuda, Sonobe) MUST have is_japanese=true.
- IT & technical classes (Python, AI, Web, Korpus lingvistikasi, C#, Database) MUST have is_japanese=false.
- If a teacher is mentioned (e.g. Okamoto, Yasuda, Sonobe, Mo'minbek, Erkaboy, Barno, Boburbek, Shermuhammad), assign their clean name to 'teacher'.
- target_partner: 'SANNO' if SANNO specific, 'TOU' if TOU specific, 'OKAYAMA' if Okayama specific, otherwise 'ALL'.
- room: extract room number (e.g. '402', '302', '208', '304', '206') or 'Online'.

Input items:
{json.dumps(raw_text_batch, ensure_ascii=False, indent=2)}

For each item, return a JSON object with:
- "subject": clean course or subject name (e.g. "AI", "Python", "Yapon tili (N3D)", "Asosiy Kurs ③")
- "room": room number or location (e.g. "402", "302", "304", "208", "Online")
- "teacher": instructor name if mentioned, otherwise "Universitet o'qituvchisi"
- "target_partner": "TOU", "SANNO", "OKAYAMA", or "ALL"
- "is_japanese": boolean (true for Japanese language/Asosiy Kurs/Okamoto/Yasuda, false for IT/general)
- "class_type": "lecture" or "seminar"

Return ONLY a valid JSON array of objects in the exact same order as the input items."""

    for model in GEMINI_MODELS:
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
            headers = {"Content-Type": "application/json"}
            payload = {
                "contents": [{"parts": [{"text": prompt}]}],
                "generationConfig": {
                    "temperature": 0.1,
                    "responseMimeType": "application/json"
                }
            }
            resp = requests.post(url, headers=headers, json=payload, timeout=8)
            if resp.status_code == 200:
                result = resp.json()
                candidates = result.get('candidates', [])
                if candidates:
                    content_text = candidates[0].get('content', {}).get('parts', [{}])[0].get('text', '')
                    parsed = json.loads(content_text)
                    if isinstance(parsed, list) and len(parsed) == len(raw_text_batch):
                        return parsed
            else:
                logger.warning(f"Gemini API ({model}) returned status {resp.status_code}")
        except Exception as e:
            logger.warning(f"Gemini parsing error with {model}: {e}")

    return None

def parse_with_heuristics(raw_text: str, group_code: str = "") -> list[dict]:
    """
    Deterministic domain-aware rule parser for JDU timetable cells:
    - Multi-class Japanese cells: 'N2A:305\nN2D:208 \nN4:204'
    - Japanese Main Course & Faculty: 'Asosiy Kurs ③ 402 Okamoto' -> is_japanese=True, teacher=Okamoto
    - Standard class layout: '23C\nAI\n302\nMo\'minbek'
    """
    text = raw_text.strip()
    if not text:
        return []

    lines = [line.strip() for line in text.split('\n') if line.strip()]

    # Case A: Multi-level Japanese cell (e.g. 'N2A:305', 'N2D:208', 'N3D:303\nN3E:204')
    colon_levels = re.findall(r'(N[1-5][A-Z]?)\s*:\s*(\w+)', text)
    if colon_levels:
        results = []
        for level, room in colon_levels:
            results.append({
                "subject": f"Yapon tili ({level})",
                "room": room,
                "teacher": "Yapon tili o'qituvchisi",
                "target_partner": "ALL",
                "is_japanese": True,
                "class_type": "seminar"
            })
        return results

    # Case B: Identify Japanese language or preparation course
    is_jp = bool(re.search(
        r'\b(N[1-5]|nihongo|japanese|yapon|面接|会話|Asosiy Kurs|科目履修)\b|okamoto|yasuda|sonobe',
        text,
        re.I
    ))

    # Identify partner university track
    target_partner = "ALL"
    text_upper = text.upper()
    if "SANNO" in text_upper:
        target_partner = "SANNO"
    elif "TOU" in text_upper:
        target_partner = "TOU"
    elif "OKAYAMA" in text_upper:
        target_partner = "OKAYAMA"
    elif "NIIGATA" in text_upper or "KAISHI" in text_upper:
        target_partner = "NIIGATA"
    elif "KYOTO" in text_upper or "京都" in text:
        target_partner = "KYOTO"

    room = ""
    teacher = ""
    subject_parts = []

    for line in lines:
        # Ignore redundant group repetition (e.g. '23C')
        if group_code and line.strip() == group_code:
            continue

        # Extract room if present (e.g. 402, 304, 203, Online, Zoom)
        room_match = re.search(r'\b(40[1-6]|30[1-6]|20[1-8]|Faollar zali|Zoom|Online|Katta zal)\b', line, re.I)
        if room_match and not room:
            room = room_match.group(1)
            line = line.replace(room, '').strip()

        # Extract known faculty / teacher names
        teacher_match = re.search(
            r'\b(Okamoto|Yasuda|Sonobe|Mo\'minbek|Erkaboy|Barno|Boburbek|Shermuhammad|Doston|Xurshid)\b|(\w+(?:bek|boy|jon|xon|ov|yev|eva|ova))\b',
            line,
            re.I
        )
        if teacher_match and not teacher:
            teacher = teacher_match.group(1) or teacher_match.group(2)
            line = re.sub(r'\b' + re.escape(teacher) + r'\b', '', line).strip()

        line_clean = line.strip(' -:\t')
        if line_clean:
            subject_parts.append(line_clean)

    subject = ' - '.join(subject_parts).strip() if subject_parts else (lines[0] if lines else "Dars")

    # Clean up redundant group prefix if present (e.g. '23C PYTHON' -> 'PYTHON')
    subject = re.sub(r'^(?:2[2-5][A-Z]|IT)\s*[-:]?\s*', '', subject, flags=re.I).strip()
    if not subject:
        subject = f"{group_code} Darsi"

    return [{
        "subject": subject,
        "room": room or "203",
        "teacher": teacher or ("Yapon tili o'qituvchisi" if is_jp else "Universitet o'qituvchisi"),
        "target_partner": target_partner,
        "is_japanese": is_jp,
        "class_type": "seminar" if is_jp else "lecture"
    }]

def parse_timetable_item(raw_text: str, group_code: str = "", api_key: str = "") -> list[dict]:
    """
    Unified entry point with memoization and circuit breaker.
    Tries Gemini AI first when operational; falls back cleanly to domain heuristics.
    """
    cache_key = (raw_text.strip(), group_code)
    if cache_key in _parsed_cache:
        return _parsed_cache[cache_key]

    global _gemini_failures
    if api_key and _gemini_failures < _MAX_GEMINI_FAILURES:
        ai_res = parse_with_gemini([raw_text], api_key)
        if ai_res and len(ai_res) == 1:
            _gemini_failures = 0
            _parsed_cache[cache_key] = ai_res
            return ai_res
        else:
            _gemini_failures += 1
            if _gemini_failures >= _MAX_GEMINI_FAILURES:
                logger.warning("Gemini AI API temporarily unavailable (503/rate limit). Using resilient JDU heuristics.")

    res = parse_with_heuristics(raw_text, group_code=group_code)
    _parsed_cache[cache_key] = res
    return res
