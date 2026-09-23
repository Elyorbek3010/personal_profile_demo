import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'fcm_service.dart';
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _currentUser;
  String? _accessToken;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  Future<void> init() async {
    // 1. Read access token from secure encrypted storage
    _accessToken = await _secureStorage.read(key: AppConstants.keyAccessToken);

    final prefs = await SharedPreferences.getInstance();

    // 2. Migration: if tokens were previously in plain SharedPreferences, migrate them
    if (_accessToken == null) {
      final legacyAccess = prefs.getString(AppConstants.keyAccessToken);
      final legacyRefresh = prefs.getString(AppConstants.keyRefreshToken);
      if (legacyAccess != null) {
        _accessToken = legacyAccess;
        await _secureStorage.write(key: AppConstants.keyAccessToken, value: legacyAccess);
        await prefs.remove(AppConstants.keyAccessToken);
      }
      if (legacyRefresh != null) {
        await _secureStorage.write(key: AppConstants.keyRefreshToken, value: legacyRefresh);
        await prefs.remove(AppConstants.keyRefreshToken);
      }
    }

    final userJsonStr = prefs.getString(AppConstants.keyUserData);
    if (userJsonStr != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJsonStr));
      } catch (e) {
        debugPrint('Failed to parse cached user: $e');
      }
    }
    notifyListeners();
    if (_accessToken != null) {
      _syncFCMToken();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.baseUrl}/api/auth/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email.trim(),
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Serverga ulanish vaqti tugadi (Timeout). Qaytadan urinib ko'ring."),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        _accessToken = data['access'];
        final refresh = data['refresh'];
        _currentUser = UserModel.fromJson(data['user']);

        // Save tokens in secure encrypted storage
        if (_accessToken != null) {
          await _secureStorage.write(key: AppConstants.keyAccessToken, value: _accessToken!);
        }
        if (refresh != null) {
          await _secureStorage.write(key: AppConstants.keyRefreshToken, value: refresh);
        }

        // Cache non-sensitive user profile in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserData, jsonEncode(_currentUser!.toJson()));

        _isLoading = false;
        notifyListeners();
        _syncFCMToken();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        final rawDetail = data['detail'] ?? data['error'];
        String detailMsg = 'Kirishda xatolik yuz berdi';
        if (rawDetail is List && rawDetail.isNotEmpty) {
          detailMsg = rawDetail.first.toString();
        } else if (rawDetail is String && rawDetail.isNotEmpty) {
          detailMsg = rawDetail;
        }
        throw Exception(detailMsg);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refreshes expired access token using the securely stored refresh token
  Future<bool> refreshToken() async {
    try {
      final refresh = await _secureStorage.read(key: AppConstants.keyRefreshToken);
      if (refresh == null || refresh.isEmpty) {
        return false;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/auth/refresh/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _accessToken = data['access'];
        if (_accessToken != null) {
          await _secureStorage.write(key: AppConstants.keyAccessToken, value: _accessToken!);
        }
        final newRefresh = data['refresh'];
        if (newRefresh != null) {
          await _secureStorage.write(key: AppConstants.keyRefreshToken, value: newRefresh);
        }
        notifyListeners();
        return true;
      } else {
        debugPrint('Token refresh failed (${response.statusCode})');
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh exception: $e');
      return false;
    }
  }

  Future<bool> updateAvatar(String newAvatarUrl) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/api/auth/update-avatar/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'avatar': newAvatarUrl}),
      );

      if (response.statusCode == 200) {
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(avatar: newAvatarUrl);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.keyUserData, jsonEncode(_currentUser!.toJson()));
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to update avatar: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _currentUser = null;
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUserData);
    notifyListeners();
  }

  Future<void> _syncFCMToken() async {
    if (_accessToken == null) return;
    try {
      final token = await FCMService().getToken();
      if (token != null) {
        final url = Uri.parse('${AppConstants.baseUrl}/api/auth/update-fcm-token/');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: jsonEncode({'fcm_token': token}),
        );
        debugPrint('FCM Token synced to backend.');
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }
}
