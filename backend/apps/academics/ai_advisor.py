"""
AI Academic Advisor Engine.

Calculates:
- GPA from credit letter grades (A=4.0, B=3.0, C=2.0, D=1.0, F=0.0)
- Attendance risk analysis per subject (warns if <80% or approaching 80%)
- Smart predictions: "If you miss X more classes, you'll drop below 80%"
"""

# Letter grade to GPA point mapping
GRADE_POINTS = {
    'A': 4.0,
    'B': 3.0,
    'C': 2.0,
    'D': 1.0,
    'F': 0.0,
}

ATTENDANCE_DANGER_THRESHOLD = 80  # Below this = exam ban risk
ATTENDANCE_WARNING_THRESHOLD = 85  # Yellow warning zone


def calculate_gpa(categories: list) -> dict:
    """
    Calculate GPA from the 'Kreditlari' category.

    Returns:
        {
            'gpa': float (e.g., 3.42),
            'total_credits': int,
            'grade_distribution': {'A': 5, 'B': 3, ...},
            'by_group': [{'name': 'TOU', 'gpa': 3.8, 'count': 10}, ...]
        }
    """
    credits_cat = None
    for cat in categories:
        if cat.get('category') == 'Kreditlari':
            credits_cat = cat
            break

    if not credits_cat:
        return {'gpa': 0.0, 'total_credits': 0, 'grade_distribution': {}, 'by_group': []}

    all_points = []
    grade_dist = {}
    by_group = []

    for subj_group in credits_cat.get('subjects', []):
        group_name = subj_group.get('subject', 'Other')
        group_points = []

        for lesson in subj_group.get('lessons', []):
            mark = lesson.get('mark', '').strip().upper()
            if mark in GRADE_POINTS:
                points = GRADE_POINTS[mark]
                all_points.append(points)
                group_points.append(points)
                grade_dist[mark] = grade_dist.get(mark, 0) + 1

        if group_points:
            by_group.append({
                'name': group_name,
                'gpa': round(sum(group_points) / len(group_points), 2),
                'count': len(group_points),
            })

    overall_gpa = round(sum(all_points) / len(all_points), 2) if all_points else 0.0

    return {
        'gpa': overall_gpa,
        'total_credits': len(all_points),
        'grade_distribution': grade_dist,
        'by_group': by_group,
    }


def analyze_attendance(categories: list) -> dict:
    """
    Analyze attendance from the 'Davomati' category.

    Returns:
        {
            'overall_percentage': int,
            'status': 'safe' | 'warning' | 'danger',
            'subjects': [
                {
                    'name': str,
                    'percentage': int,
                    'total_classes': int,
                    'attended': int,
                    'missed': int,
                    'excused': int,
                    'status': 'safe' | 'warning' | 'danger',
                    'risk_message': str | None,
                    'classes_can_miss': int,  # how many more can miss before hitting 80%
                }
            ],
            'warnings': [str],  # AI-generated warning messages
        }
    """
    attendance_cat = None
    for cat in categories:
        if cat.get('category') == 'Davomati':
            attendance_cat = cat
            break

    if not attendance_cat:
        return {
            'overall_percentage': 0,
            'status': 'unknown',
            'subjects': [],
            'warnings': [],
        }

    overall_pct = attendance_cat.get('percentage', 0)
    subjects_analysis = []
    warnings = []

    for subj in attendance_cat.get('subjects', []):
        subj_name = subj.get('subject', '')
        subj_pct = subj.get('percentage', 0)
        lessons = subj.get('lessons', [])
        total = len(lessons)

        # Count attendance statuses
        attended = sum(1 for l in lessons if l.get('mark_status') == 'P')
        excused = sum(1 for l in lessons if l.get('mark_status') == 'E')
        missed = sum(1 for l in lessons if l.get('mark_status') == 'A')

        # Determine status — skip subjects with no attendance records (online courses)
        if total == 0:
            status = 'no_data'
        elif subj_pct < ATTENDANCE_DANGER_THRESHOLD:
            status = 'danger'
        elif subj_pct < ATTENDANCE_WARNING_THRESHOLD:
            status = 'warning'
        else:
            status = 'safe'

        # Calculate how many more classes can be missed before hitting 80%
        # Current attended ratio: attended / total
        # After missing X more out of (total + remaining_classes):
        # We estimate based on current data
        classes_can_miss = 0
        risk_message = None

        if total > 0:
            # Simulate future classes: assume ~4 more classes per subject remaining
            estimated_remaining = max(4, int(total * 0.3))
            future_total = total + estimated_remaining

            # How many can miss total to stay at 80%?
            max_missable_total = int(future_total * 0.2)  # 20% of total allowed to miss
            current_missed = missed
            classes_can_miss = max(0, max_missable_total - current_missed)

            if status == 'danger':
                risk_message = f"🚨 {subj_name}: Davomat {subj_pct}% — 80% dan past! Imtihonga kiritilmaslik xavfi mavjud!"
                warnings.append(risk_message)
            elif status == 'warning':
                if classes_can_miss <= 1:
                    risk_message = f"⚠️ {subj_name}: Yana 1 ta dars qoldirsangiz, davomat 80% dan tushib ketadi!"
                else:
                    risk_message = f"⚠️ {subj_name}: Diqqat! Faqat {classes_can_miss} ta dars qoldirish mumkin."
                warnings.append(risk_message)
            else:
                if classes_can_miss <= 2:
                    risk_message = f"ℹ️ {subj_name}: Davomatingiz yaxshi, lekin faqat {classes_can_miss} ta dars qoldirishingiz mumkin."

        subjects_analysis.append({
            'name': subj_name,
            'percentage': subj_pct,
            'total_classes': total,
            'attended': attended,
            'missed': missed,
            'excused': excused,
            'status': status,
            'risk_message': risk_message,
            'classes_can_miss': classes_can_miss,
        })

    # Overall status
    if overall_pct < ATTENDANCE_DANGER_THRESHOLD:
        overall_status = 'danger'
        warnings.insert(0, f"🚨 UMUMIY DAVOMAT {overall_pct}% — XAVFLI! 80% dan past!")
    elif overall_pct < ATTENDANCE_WARNING_THRESHOLD:
        overall_status = 'warning'
        warnings.insert(0, f"⚠️ Umumiy davomat {overall_pct}% — 80% chegarasiga yaqin!")
    else:
        overall_status = 'safe'

    return {
        'overall_percentage': overall_pct,
        'status': overall_status,
        'subjects': subjects_analysis,
        'warnings': warnings,
    }


def analyze_current_grades(categories: list) -> dict:
    """
    Analyze current semester grades from 'Baholari' category.

    Returns:
        {
            'overall_percentage': int,
            'subjects': [
                {
                    'name': str,
                    'percentage': int,
                    'assignments': [{'name': str, 'mark': str, 'deadline': str}],
                    'status': 'excellent' | 'good' | 'needs_work' | 'failing',
                }
            ]
        }
    """
    grades_cat = None
    for cat in categories:
        if cat.get('category') == 'Baholari':
            grades_cat = cat
            break

    if not grades_cat:
        return {'overall_percentage': 0, 'subjects': []}

    subjects = []
    for subj in grades_cat.get('subjects', []):
        pct = subj.get('percentage', 0)
        if pct >= 85:
            status = 'excellent'
        elif pct >= 70:
            status = 'good'
        elif pct >= 50:
            status = 'needs_work'
        else:
            status = 'failing'

        assignments = []
        for lesson in subj.get('lessons', []):
            assignments.append({
                'name': lesson.get('lesson', ''),
                'mark': lesson.get('mark', ''),
                'deadline': lesson.get('assignment_deadline', ''),
            })

        subjects.append({
            'name': subj.get('subject', ''),
            'percentage': pct,
            'assignments': assignments,
            'status': status,
        })

    return {
        'overall_percentage': grades_cat.get('percentage', 0),
        'subjects': subjects,
    }


def generate_full_report(scraped_data: dict) -> dict:
    """
    Generate the complete AI academic report from scraped data.

    This is the main function called by the view.
    """
    categories = scraped_data.get('categories', [])

    gpa = calculate_gpa(categories)
    attendance = analyze_attendance(categories)
    grades = analyze_current_grades(categories)

    return {
        'student_name': scraped_data.get('student_name', ''),
        'turnstile': scraped_data.get('turnstile', {}),
        'gpa': gpa,
        'attendance': attendance,
        'current_grades': grades,
    }
