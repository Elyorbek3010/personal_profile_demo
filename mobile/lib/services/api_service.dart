import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/timetable_model.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> _getHeaders() {
    final token = AuthService().accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _getWithAuth(Uri url) async {
    var response = await http.get(url, headers: _getHeaders()).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception("Serverga ulanish vaqti tugadi. Qaytadan urinib ko'ring."),
    );
    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();
      if (refreshed) {
        response = await http.get(url, headers: _getHeaders()).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception("Serverga ulanish vaqti tugadi. Qaytadan urinib ko'ring."),
        );
      } else {
        await AuthService().logout();
        throw Exception("Sessiya muddati tugagan. Qaytadan kiring.");
      }
    }
    return response;
  }

  Future<http.Response> _postWithAuth(Uri url, {Object? body}) async {
    var response = await http.post(url, headers: _getHeaders(), body: body).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception("Serverga ulanish vaqti tugadi. Qaytadan urinib ko'ring."),
    );
    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();
      if (refreshed) {
        response = await http.post(url, headers: _getHeaders(), body: body).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception("Serverga ulanish vaqti tugadi. Qaytadan urinib ko'ring."),
        );
      } else {
        await AuthService().logout();
        throw Exception("Sessiya muddati tugagan. Qaytadan kiring.");
      }
    }
    return response;
  }

  Future<List<DayScheduleModel>> getMySchedule() async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/timetable/my-schedule/');
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List rawSchedule = data['schedule'] ?? [];
      return rawSchedule.map((e) => DayScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Dars jadvalini yuklashda xatolik: ${response.statusCode}");
    }
  }

  Future<NextClassResponse> getNextClass() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/api/timetable/next/');
      final response = await _getWithAuth(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return NextClassResponse.fromJson(data);
      }
    } catch (_) {}
    return NextClassResponse(hasNextClass: false, isToday: false, dayName: '');
  }

  /// Fetch academic data (grades, attendance, GPA, AI warnings)
  Future<Map<String, dynamic>> getAcademicData() async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/academics/my-data/');
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception("Ma'lumotlarni yuklashda xatolik: ${response.statusCode}");
    }
  }

  /// Save student's data.jdu.uz link/hash
  Future<Map<String, dynamic>> setDataLink(String link) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/academics/set-link/');
    final response = await _postWithAuth(
      url,
      body: jsonEncode({'link': link}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMsg = data['error'] ?? data['detail'] ?? "Havolani saqlashda xatolik (${response.statusCode})";
      throw Exception(errorMsg);
    }
  }
}

