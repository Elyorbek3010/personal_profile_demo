"""
AI & Heuristic Timetable Parser Service.
Parses messy raw cell texts (e.g. '23B\\nAI\\n302\\nMo\\'minbek' or 'N2A:305\\nN2D:208')
into clean, structured class attributes (subject, room, teacher, partner, is_japanese).
Uses Google Gemini API when available, with a resilient rule-based heuristic engine fallback.
"""
import os
import re
import json
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

def parse_with_gemini(raw_text_batch: list[str], api_key: str) -> list[dict] | None:
    """
    Sends a batch of raw timetable cell texts to Gemini AI.
    Returns structured JSON for each item.
    """
    if not api_key:
        return None

    prompt = f"""You are an expert university schedule parser for Japan Digital University (JDU).
Parse each of the following raw timetable cell contents into structured JSON.

Input items:
{json.dumps(raw_text_batch, ensure_ascii=False, indent=2)}

For each item, return a JSON object with:
- "subject": clean course or subject name (e.g. "AI", "Python", "Yapon tili N2A", "SANNO Menejment")
- "room": room number or location (e.g. "302", "304", "208", "Faollar zali", "Zoom")
- "teacher": instructor name if mentioned (e.g. "Mo'minbek", "Erkaboy", "Boburbek", or empty string)
- "target_partner": "TOU" if Tokyo Online University specific, "SANNO" if SANNO specific, otherwise "ALL"
- "is_japanese": boolean (true if Japanese language class or N1/N2/N3/N4/N5 class, false otherwise)
- "class_type": "lecture", "seminar", "exam", or "interview"

Return ONLY a valid JSON array of objects in the exact same order as the input items."""

    try:
        url = f"{GEMINI_API_URL}?key={api_key}"
        headers = {"Content-Type": "application/json"}
        payload = {
            "contents": [{
                "parts": [{"text": prompt}]
            }],
            "generationConfig": {
                "temperature": 0.1,
                "responseMimeType": "application/json"
            }
        }
        resp = requests.post(url, headers=headers, json=payload, timeout=20)
        if resp.status_code == 200:
            result = resp.json()
            candidates = result.get('candidates', [])
            if candidates:
                content_text = candidates[0].get('content', {}).get('parts', [{}])[0].get('text', '')
                parsed = json.loads(content_text)
                if isinstance(parsed, list) and len(parsed) == len(raw_text_batch):
                    return parsed
        else:
            logger.warning(f"Gemini API returned status {resp.status_code}: {resp.text[:200]}")
    except Exception as e:
        logger.warning(f"Gemini parsing error, falling back to heuristics: {e}")

    return None

def parse_with_heuristics(raw_text: str, group_code: str = "") -> list[dict]:
    """
    Deterministic rule-based parser that handles typical JDU timetable cells:
    - Multi-class Japanese cells: 'N2A:305\\nN2D:208 \\nN4:204'
    - Subject + Room + Teacher cells: '23B\\nAI\\n302\\nMo\\'minbek'
    - Special events: '22A DIPLOMA WORK\\nFaollar zali\\nBoburbek'
    """
    text = raw_text.strip()
    if not text:
        return []

    lines = [line.strip() for line in text.split('\n') if line.strip()]

    # Case A: Multi-level Japanese cell (e.g. 'N2A:305', 'N2D:208')
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

    # Case B: Standard class layout (Subject, Room, Teacher)
    room = ""
    teacher = ""
    subject_parts = []
    is_jp = bool(re.search(r'\b(N[1-5]|nihongo|japanese|yapon|面接|会話)\b', text, re.I))
    target_partner = "ALL"
    if "SANNO" in text.upper():
        target_partner = "SANNO"
    elif "TOU" in text.upper():
        target_partner = "TOU"
    elif "OKAYAMA" in text.upper():
        target_partner = "OKAYAMA"

    for line in lines:
        # Ignore redundant group repetition on first line
        if group_code and line.strip() == group_code:
            continue

        # Check room
        room_match = re.search(r'\b(30[1-6]|20[1-8]|Faollar zali|Zoom|Katta zal)\b', line, re.I)
        if room_match and not room:
            room = room_match.group(1)
            line_clean = line.replace(room, '').strip()
            if line_clean:
                subject_parts.append(line_clean)
            continue

        # Check common teacher names or title words
        if re.search(r'(bek|boy|jon|xon|ov|yev|eva|ova|sonobe|sensei|muallim)', line, re.I):
            teacher = line
            continue

        subject_parts.append(line)

    subject = ' - '.join(subject_parts).strip() if subject_parts else (lines[0] if lines else "Dars")

    # Clean up subject name
    subject = re.sub(r'^(2[2-5][A-Z])\s*[-:]?\s*', '', subject).strip()
    if not subject:
        subject = f"{group_code} Darsi"

    return [{
        "subject": subject,
        "room": room or "203",
        "teacher": teacher or "Universitet o'qituvchisi",
        "target_partner": target_partner,
        "is_japanese": is_jp,
        "class_type": "lecture"
    }]
