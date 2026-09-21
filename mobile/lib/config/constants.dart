
class AppConstants {
  static const String appName = 'UNIVER SuperApp';
  static const String appVersion = '2.0.0';

  // Base API URL
  static String get baseUrl {
    return 'http://127.0.0.1:8000';
  }

  // Storage Keys
  static const String keyAccessToken = 'jwt_access_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyUserData = 'cached_user_data';
}
