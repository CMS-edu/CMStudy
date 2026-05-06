import 'dart:async';
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

  static const requestTimeout = Duration(seconds: 90);

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

  Future<MissionData> getMissionData(DateTime date) async {
    final json = await _request(
      'GET',
      '/missions',
      query: {
        'date': isoDate(date),
        'timezoneOffsetMinutes': date.timeZoneOffset.inMinutes.toString(),
      },
    );
    return MissionData.fromJson(json);
  }

  Future<List<MissionGroupSummary>> getMissionGroups(
    DateTime date, {
    String query = '',
  }) async {
    final json = await _request(
      'GET',
      '/missions/groups',
      query: {
        'date': isoDate(date),
        'timezoneOffsetMinutes': date.timeZoneOffset.inMinutes.toString(),
        if (query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    final groups = json['groups'] as List<dynamic>? ?? const [];
    return groups
        .map(
          (item) => MissionGroupSummary.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> createMissionGroup({
    required String name,
    required int weeklyTargetMinutes,
  }) async {
    await _request(
      'POST',
      '/missions/groups',
      body: {'name': name, 'weeklyTargetMinutes': weeklyTargetMinutes},
    );
  }

  Future<void> joinMissionGroup(String inviteCode) async {
    await _request(
      'POST',
      '/missions/groups/join',
      body: {'inviteCode': inviteCode},
    );
  }

  Future<void> createTimeMission({
    required String title,
    required int startMinute,
    required int endMinute,
    required int targetMinutes,
    required bool reminderEnabled,
    String? groupId,
  }) async {
    await _request(
      'POST',
      '/missions/time-rules',
      body: {
        'title': title,
        'startMinute': startMinute,
        'endMinute': endMinute,
        'targetMinutes': targetMinutes,
        'reminderEnabled': reminderEnabled,
        if (groupId != null && groupId.isNotEmpty) 'groupId': groupId,
      },
    );
  }

  Future<StudySubject> createSubject({
    required String name,
    required String color,
    required int targetMinutesPerDay,
  }) async {
    final json = await _request(
      'POST',
      '/subjects',
      body: {
        'name': name,
        'color': color,
        'targetMinutesPerDay': targetMinutesPerDay,
      },
    );
    return StudySubject.fromJson(json);
  }

  Future<StudySubject> updateSubject({
    required String id,
    required String name,
    required String color,
    required int targetMinutesPerDay,
  }) async {
    final json = await _request(
      'PATCH',
      '/subjects/$id',
      body: {
        'name': name,
        'color': color,
        'targetMinutesPerDay': targetMinutesPerDay,
      },
    );
    return StudySubject.fromJson(json);
  }

  Future<void> deleteSubject(String id) async {
    await _request('DELETE', '/subjects/$id');
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
    String? note,
  }) async {
    await _request(
      'POST',
      '/study-sessions',
      body: {
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endedAt': endedAt.toUtc().toIso8601String(),
        'durationMinutes': durationMinutes,
        if (subjectId != null) 'subjectId': subjectId,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
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
    final client = HttpClient()..connectionTimeout = requestTimeout;
    try {
      final request = await client.openUrl(method, uri).timeout(requestTimeout);
      request.headers.contentType = ContentType.json;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(requestTimeout);
      final text = await utf8.decoder
          .bind(response)
          .join()
          .timeout(requestTimeout);
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
    } on TimeoutException {
      throw const ApiException('서버가 깨어나는 중입니다. 1분 뒤 다시 시도하세요.');
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
