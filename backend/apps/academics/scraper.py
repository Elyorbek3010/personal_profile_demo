"""
Scraper for data.jdu.uz student pages.

Extracts grades (Baholari), attendance (Davomati), credits (Kreditlari),
and turnstile visit status from the student's personal page.

The page embeds all data as a JavaScript `const data = [...]` variable,
which we parse with regex + JSON conversion.
"""
import re
import json
import html as html_lib
import logging
import requests

logger = logging.getLogger(__name__)

DATA_JDU_BASE_URL = "https://data.jdu.uz"

# Shared requests session for connection reuse
_session = requests.Session()
_session.headers.update({
    'User-Agent': 'UNIVER-SuperApp/2.0 (Academic Data Sync)',
    'Accept': 'text/html',
    'Accept-Language': 'uz,en;q=0.9',
})


def fetch_page(student_hash: str) -> str:
    """Fetch the raw HTML from data.jdu.uz/<hash> using requests Session."""
    url = f"{DATA_JDU_BASE_URL}/{student_hash}"
    try:
        response = _session.get(url, timeout=15)
        response.raise_for_status()
        response.encoding = 'utf-8'
        return response.text
    except Exception as e:
        logger.error(f"Failed to fetch data.jdu.uz/{student_hash}: {e}")
        raise ValueError(f"data.jdu.uz sahifasini yuklab bo'lmadi: {e}")


def parse_student_name(html_content: str) -> str:
    """Extract and sanitize student name from the page."""
    # Look for h1/h2 with name pattern
    match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.DOTALL)
    if match:
        name = html_lib.unescape(match.group(1))
        name = re.sub(r'<[^>]+>', '', name)
        name = re.sub(r'[<>]', '', name).strip()
        if name and len(name) > 2:
            return name
    # Fallback: look for bold text-gray-800
    match = re.search(r'font-bold[^>]*text-gray-800[^>]*>(.*?)</', html_content)
    if match:
        name = html_lib.unescape(match.group(1))
        name = re.sub(r'<[^>]+>', '', name)
        name = re.sub(r'[<>]', '', name).strip()
        return name
    return "Talaba"


def parse_turnstile_status(html_content: str) -> dict:
    """Extract university visit / turnstile check-in status."""
    result = {
        'has_data': False,
        'status_text': '',
        'entries': [],
    }
    match = re.search(
        r'Universitetga tashrif holati.*?</div>\s*</div>',
        html_content, re.DOTALL
    )
    if match:
        section = match.group(0)
        paragraphs = re.findall(r'<p[^>]*>(.*?)</p>', section, re.DOTALL)
        texts = [html_lib.unescape(re.sub(r'<[^>]+>', '', p)).strip() for p in paragraphs]
        result['status_text'] = ' '.join(texts)
        if "mavjud emas" not in result['status_text'].lower():
            result['has_data'] = True
    return result


def parse_js_data(html_content: str) -> list:
    """
    Extract and parse the `const data = [...]` JavaScript variable
    embedded in the page into a Python list of category dicts.
    """
    match = re.search(
        r'const\s+data\s*=\s*(\[.*?\]);\s*(?:const|let|var|function|document\.|window\.)',
        html_content, re.DOTALL
    )
    if not match:
        logger.warning("Could not find 'const data = [...]' in page HTML")
        return []

    raw_js = match.group(1)

    # Remove single-line comments
    clean = re.sub(r'//[^\n]*', '', raw_js)
    # Quote unquoted JS property keys (e.g., category: -> "category":)
    clean = re.sub(r'([{\s,])([a-zA-Z_][a-zA-Z0-9_]*)\s*:', r'\1"\2":', clean)
    # Remove trailing commas before } or ]
    clean = re.sub(r',\s*([\]}])', r'\1', clean)

    try:
        data = json.loads(clean)
        return data
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JS data as JSON: {e}")
        return []


def scrape_student_data(student_hash: str) -> dict:
    """
    Main entry point: scrape and return structured academic data.

    Returns a dict with:
    - student_name: str
    - turnstile: dict (visit status)
    - categories: list of {category, percentage, subjects: [...]}
        where category is one of: "Baholari", "Davomati", "Kreditlari"
    """
    html_content = fetch_page(student_hash)

    student_name = parse_student_name(html_content)
    turnstile = parse_turnstile_status(html_content)
    categories = parse_js_data(html_content)

    # Decode HTML entities in lesson names (e.g., O&#039;zbek -> O'zbek)
    for cat in categories:
        for subj in cat.get('subjects', []):
            subj['subject'] = html_lib.unescape(subj.get('subject', ''))
            for lesson in subj.get('lessons', []):
                if 'lesson' in lesson:
                    lesson['lesson'] = html_lib.unescape(lesson['lesson'])

    return {
        'student_name': student_name,
        'turnstile': turnstile,
        'categories': categories,
    }
