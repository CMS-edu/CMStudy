class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.nickname,
  });

  final String id;
  final String email;
  final String nickname;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );
  }
}

class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    required this.color,
    required this.targetMinutesPerDay,
  });

  final String id;
  final String name;
  final String color;
  final int targetMinutesPerDay;

  factory StudySubject.fromJson(Map<String, dynamic> json) {
    return StudySubject(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#2563EB',
      targetMinutesPerDay: json['targetMinutesPerDay'] as int? ?? 60,
    );
  }
}

class StudyTask {
  const StudyTask({
    required this.id,
    required this.title,
    required this.plannedMinutes,
    required this.plannedDate,
    required this.subject,
    this.completedAt,
  });

  final String id;
  final String title;
  final int plannedMinutes;
  final String plannedDate;
  final StudySubject subject;
  final DateTime? completedAt;

  bool get isDone => completedAt != null;

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      plannedMinutes: json['plannedMinutes'] as int,
      plannedDate: json['plannedDate'] as String,
      subject: StudySubject.fromJson(json['subject'] as Map<String, dynamic>),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }
}

class DailyFocus {
  const DailyFocus({required this.date, required this.minutes});

  final String date;
  final int minutes;

  factory DailyFocus.fromJson(Map<String, dynamic> json) {
    return DailyFocus(
      date: json['date'] as String,
      minutes: json['minutes'] as int? ?? 0,
    );
  }
}

class StudyStats {
  const StudyStats({
    required this.focusedToday,
    required this.weeklyTotal,
    required this.daily,
    required this.subjectMinutes,
  });

  final int focusedToday;
  final int weeklyTotal;
  final List<DailyFocus> daily;
  final Map<String, int> subjectMinutes;

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    final subjects = json['subjectMinutes'] as Map<String, dynamic>? ?? {};
    return StudyStats(
      focusedToday: json['focusedToday'] as int? ?? 0,
      weeklyTotal: json['weeklyTotal'] as int? ?? 0,
      daily: (json['daily'] as List<dynamic>? ?? [])
          .map((item) => DailyFocus.fromJson(item as Map<String, dynamic>))
          .toList(),
      subjectMinutes: subjects.map(
        (key, value) => MapEntry(key, value as int? ?? 0),
      ),
    );
  }

  static const empty = StudyStats(
    focusedToday: 0,
    weeklyTotal: 0,
    daily: [],
    subjectMinutes: {},
  );
}

class DashboardData {
  const DashboardData({
    required this.subjects,
    required this.tasks,
    required this.stats,
  });

  final List<StudySubject> subjects;
  final List<StudyTask> tasks;
  final StudyStats stats;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((item) => StudySubject.fromJson(item as Map<String, dynamic>))
          .toList(),
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((item) => StudyTask.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: StudyStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
    );
  }
}
