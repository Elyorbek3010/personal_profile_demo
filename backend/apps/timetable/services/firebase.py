import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings
import logging
import os

logger = logging.getLogger(__name__)

def initialize_firebase():
    """Initializes the Firebase Admin SDK if not already initialized."""
    if not firebase_admin._apps:
        # User will need to provide their service account JSON
        cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized successfully.")
        else:
            logger.warning("Firebase credentials path not found or invalid. Push notifications will not work.")

def send_push_notification(token, title, body, data=None):
    """
    Sends a push notification to a specific device token.
    """
    if not firebase_admin._apps:
        initialize_firebase()
        
    if not firebase_admin._apps:
        logger.error("Cannot send notification: Firebase is not initialized.")
        return False

    if not token:
        logger.warning("Cannot send notification: No token provided.")
        return False

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data if data else {},
        token=token,
    )

    try:
        response = messaging.send(message)
        logger.info(f"Successfully sent message: {response}")
        return True
    except Exception as e:
        logger.error(f"Error sending message: {e}")
        return False

def notify_student_of_schedule_change(student_profile, entry):
    """
    Constructs and sends a notification for a timetable change.
    """
    if not student_profile.fcm_token:
        return False
        
    title = "Dars jadvali o'zgardi"
    body = f"{entry.specific_date.strftime('%Y-%m-%d')} dagi {entry.period}-para darsida o'zgarish bor. Yangi xona: {entry.room}."
    
    data = {
        "type": "schedule_change",
        "entry_id": str(entry.id),
        "date": str(entry.specific_date)
    }
    
    return send_push_notification(student_profile.fcm_token, title, body, data)
