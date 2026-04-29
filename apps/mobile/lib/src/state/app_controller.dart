import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AppController extends ChangeNotifier {
  AppController(this.api);

  static const tokenKey = 'cmstudy.accessToken';
  static const userKey = 'cmstudy.user';
  static const themeModeKey = 'cmstudy.themeMode';
  static const accentColorKey = 'cmstudy.accentColor';
  static const showPlansOnHomeKey = 'cmstudy.showPlansOnHome';
  static const showImagesKey = 'cmstudy.showImages';
  static const denseStatsKey = 'cmstudy.denseStats';

  final ApiClient api;

  AuthUser? user;
  List<StudySubject> subjects = const [];
  List<StudyTask> tasks = const [];
  StudyStats stats = StudyStats.empty;
  DateTime selectedDate = DateTime.now();
  ThemeMode themeMode = ThemeMode.system;
  int accentColorValue = 0xFF2563EB;
  bool showPlansOnHome = false;
  bool showImages = true;
  bool denseStats = true;
  bool isInitialized = false;
  bool isBusy = false;
  String? errorMessage;

  bool get isAuthenticated => user != null && api.token != null;

  Color get accentColor => Color(accentColorValue);

  int get openTaskCount => tasks.where((task) => !task.isDone).length;

  int get plannedMinutesToday {
    return tasks.fold<int>(0, (sum, task) => sum + task.plannedMinutes);
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      final result = await api.login(email, password);
      await setSession(result);
      await loadDashboard();
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    await _run(() async {
      final result = await api.register(
        email: email,
        password: password,
        nickname: nickname,
      );
      await setSession(result);
      await loadDashboard();
    });
  }

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    loadSettings(preferences);
    final savedToken = preferences.getString(tokenKey);
    final savedUser = preferences.getString(userKey);
    if (savedToken == null || savedUser == null) {
      isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      api.token = savedToken;
      user = AuthUser.fromJson(jsonDecode(savedUser) as Map<String, dynamic>);
      await loadDashboard(DateTime.now());
    } catch (_) {
      await clearSession();
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  void loadSettings(SharedPreferences preferences) {
    themeMode = switch (preferences.getString(themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    accentColorValue = preferences.getInt(accentColorKey) ?? 0xFF2563EB;
    showPlansOnHome = preferences.getBool(showPlansOnHomeKey) ?? false;
    showImages = preferences.getBool(showImagesKey) ?? true;
    denseStats = preferences.getBool(denseStatsKey) ?? true;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(themeModeKey, value.name);
    notifyListeners();
  }

  Future<void> setAccentColor(Color value) async {
    accentColorValue = value.toARGB32();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(accentColorKey, accentColorValue);
    notifyListeners();
  }

  Future<void> setShowPlansOnHome(bool value) async {
    showPlansOnHome = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(showPlansOnHomeKey, value);
    notifyListeners();
  }

  Future<void> setShowImages(bool value) async {
    showImages = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(showImagesKey, value);
    notifyListeners();
  }

  Future<void> setDenseStats(bool value) async {
    denseStats = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(denseStatsKey, value);
    notifyListeners();
  }

  Future<void> setSession(AuthResult result) async {
    api.token = result.token;
    user = result.user;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(tokenKey, result.token);
    await preferences.setString(userKey, jsonEncode(result.user.toJson()));
  }

  Future<void> loadDashboard([DateTime? date]) async {
    selectedDate = date ?? selectedDate;
    final data = await api.getDashboard(selectedDate);
    subjects = data.subjects;
    tasks = data.tasks;
    stats = data.stats;
    notifyListeners();
  }

  Future<void> goToDate(DateTime date) async {
    await _run(() async {
      await loadDashboard(date);
    });
  }

  Future<void> createTask({
    required String subjectId,
    required String title,
    required int plannedMinutes,
    DateTime? plannedDate,
  }) async {
    await _run(() async {
      await api.createTask(
        subjectId: subjectId,
        title: title,
        plannedMinutes: plannedMinutes,
        plannedDate: plannedDate ?? selectedDate,
      );
      await loadDashboard();
    });
  }

  Future<void> createSubject({
    required String name,
    required String color,
    required int targetMinutesPerDay,
  }) async {
    await _run(() async {
      await api.createSubject(
        name: name,
        color: color,
        targetMinutesPerDay: targetMinutesPerDay,
      );
      await loadDashboard();
    });
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    required String color,
    required int targetMinutesPerDay,
  }) async {
    await _run(() async {
      await api.updateSubject(
        id: id,
        name: name,
        color: color,
        targetMinutesPerDay: targetMinutesPerDay,
      );
      await loadDashboard();
    });
  }

  Future<void> deleteSubject(String id) async {
    await _run(() async {
      await api.deleteSubject(id);
      await loadDashboard();
    });
  }

  Future<void> toggleTask(String taskId) async {
    await _run(() async {
      await api.toggleTask(taskId);
      await loadDashboard();
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _run(() async {
      await api.deleteTask(taskId);
      await loadDashboard();
    });
  }

  Future<void> recordFocusSession({
    required int minutes,
    String? subjectId,
  }) async {
    await _run(() async {
      final endedAt = DateTime.now();
      await api.recordStudySession(
        startedAt: endedAt.subtract(Duration(minutes: minutes)),
        endedAt: endedAt,
        durationMinutes: minutes,
        subjectId: subjectId,
      );
      await loadDashboard();
    });
  }

  Future<void> logout() async {
    await clearSession();
    notifyListeners();
  }

  Future<void> clearSession() async {
    api.token = null;
    user = null;
    subjects = const [];
    tasks = const [];
    stats = StudyStats.empty;
    selectedDate = DateTime.now();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(tokenKey);
    await preferences.remove(userKey);
  }

  Future<void> _run(Future<void> Function() job) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await job();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '알 수 없는 오류가 발생했습니다.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
