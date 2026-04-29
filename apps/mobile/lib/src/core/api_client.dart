import 'dart:convert';
import 'dart:io';

import '../models/models.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['accessToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ApiClient {
  ApiClient({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    ),
  });

  final String baseUrl;
  String? token;

  Future<AuthResult> login(String email, String password) async {
    final json = await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResult.fromJson(json);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final json = await _request(
      'POST',
      '/auth/register',
      body: {'email': email, 'password': password, 'nickname': nickname},
    );
    return AuthResult.fromJson(json);
  }

  Future<DashboardData> getDashboard(DateTime date) async {
    final json = await _request(
      'GET',
      '/dashboard',
      query: {
        'date': isoDate(date),
        'timezoneOffsetMinutes': date.timeZoneOffset.inMinutes.toString(),
      },
    );
    return DashboardData.fromJson(json);
  }

  Future<StudyTask> createTask({
    required String subjectId,
    required String title,
    required int plannedMinutes,
    required DateTime plannedDate,
  }) async {
    final json = await _request(
      'POST',
      '/study-tasks',
      body: {
        'subjectId': subjectId,
        'title': title,
        'plannedMinutes': plannedMinutes,
        'plannedDate': isoDate(plannedDate),
      },
    );
    return StudyTask.fromJson(json);
  }

  Future<StudyTask> toggleTask(String taskId) async {
    final json = await _request('PATCH', '/study-tasks/$taskId/toggle');
    return StudyTask.fromJson(json);
  }

  Future<void> deleteTask(String taskId) async {
    await _request('DELETE', '/study-tasks/$taskId');
  }

  Future<void> recordStudySession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
    String? subjectId,
  }) async {
    await _request(
      'POST',
      '/study-sessions',
      body: {
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endedAt': endedAt.toUtc().toIso8601String(),
        'durationMinutes': durationMinutes,
        if (subjectId != null) 'subjectId': subjectId,
      },
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      request.headers.contentType = ContentType.json;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final text = await utf8.decoder.bind(response).join();
      final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? '요청에 실패했습니다.'
            : '요청에 실패했습니다.';
        throw ApiException(message, response.statusCode);
      }

      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on SocketException {
      throw const ApiException('서버에 연결할 수 없습니다. API 서버가 켜져 있는지 확인하세요.');
    } finally {
      client.close(force: true);
    }
  }
}

String isoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
