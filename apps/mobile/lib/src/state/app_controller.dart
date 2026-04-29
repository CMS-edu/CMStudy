import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AppController extends ChangeNotifier {
  AppController(this.api);

  final ApiClient api;

  AuthUser? user;
  List<StudySubject> subjects = const [];
  List<StudyTask> tasks = const [];
  StudyStats stats = StudyStats.empty;
  bool isBusy = false;
  String? errorMessage;

  bool get isAuthenticated => user != null && api.token != null;

  int get openTaskCount => tasks.where((task) => !task.isDone).length;

  int get plannedMinutesToday {
    return tasks.fold<int>(0, (sum, task) => sum + task.plannedMinutes);
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      final result = await api.login(email, password);
      api.token = result.token;
      user = result.user;
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
      api.token = result.token;
      user = result.user;
      await loadDashboard();
    });
  }

  Future<void> loadDashboard() async {
    final data = await api.getDashboard(DateTime.now());
    subjects = data.subjects;
    tasks = data.tasks;
    stats = data.stats;
    notifyListeners();
  }

  Future<void> createTask({
    required String subjectId,
    required String title,
    required int plannedMinutes,
  }) async {
    await _run(() async {
      await api.createTask(
        subjectId: subjectId,
        title: title,
        plannedMinutes: plannedMinutes,
        plannedDate: DateTime.now(),
      );
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

  void logout() {
    api.token = null;
    user = null;
    subjects = const [];
    tasks = const [];
    stats = StudyStats.empty;
    notifyListeners();
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
