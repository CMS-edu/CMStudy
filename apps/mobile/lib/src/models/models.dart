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

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'nickname': nickname};
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
    required this.totalMinutes,
    required this.daily,
    required this.subjectMinutes,
    required this.todaySubjectMinutes,
    required this.periods,
  });

  final int focusedToday;
  final int weeklyTotal;
  final int totalMinutes;
  final List<DailyFocus> daily;
  final Map<String, int> subjectMinutes;
  final Map<String, int> todaySubjectMinutes;
  final Map<String, StudyPeriodStats> periods;

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    final subjects = json['subjectMinutes'] as Map<String, dynamic>? ?? {};
    final todaySubjects =
        json['todaySubjectMinutes'] as Map<String, dynamic>? ?? {};
    return StudyStats(
      focusedToday: json['focusedToday'] as int? ?? 0,
      weeklyTotal: json['weeklyTotal'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      daily: (json['daily'] as List<dynamic>? ?? [])
          .map((item) => DailyFocus.fromJson(item as Map<String, dynamic>))
          .toList(),
      subjectMinutes: subjects.map(
        (key, value) => MapEntry(key, value as int? ?? 0),
      ),
      todaySubjectMinutes: todaySubjects.map(
        (key, value) => MapEntry(key, value as int? ?? 0),
      ),
      periods: parsePeriods(json['periods'] as Map<String, dynamic>? ?? {}),
    );
  }

  static const empty = StudyStats(
    focusedToday: 0,
    weeklyTotal: 0,
    totalMinutes: 0,
    daily: [],
    subjectMinutes: {},
    todaySubjectMinutes: {},
    periods: {},
  );
}

class StudyPeriodStats {
  const StudyPeriodStats({
    required this.totalMinutes,
    required this.subjectMinutes,
    required this.activeDays,
    required this.averageMinutes,
    required this.bestDayMinutes,
    required this.daily,
    required this.monthlyMinutes,
  });

  final int totalMinutes;
  final Map<String, int> subjectMinutes;
  final int activeDays;
  final int averageMinutes;
  final int bestDayMinutes;
  final List<DailyFocus> daily;
  final Map<String, int> monthlyMinutes;

  factory StudyPeriodStats.fromJson(Map<String, dynamic> json) {
    final subjects = json['subjectMinutes'] as Map<String, dynamic>? ?? {};
    final monthly = json['monthlyMinutes'] as Map<String, dynamic>? ?? {};
    return StudyPeriodStats(
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      subjectMinutes: subjects.map(
        (key, value) => MapEntry(key, value as int? ?? 0),
      ),
      activeDays: json['activeDays'] as int? ?? 0,
      averageMinutes: json['averageMinutes'] as int? ?? 0,
      bestDayMinutes: json['bestDayMinutes'] as int? ?? 0,
      daily: (json['daily'] as List<dynamic>? ?? [])
          .map((item) => DailyFocus.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthlyMinutes: monthly.map(
        (key, value) => MapEntry(key, value as int? ?? 0),
      ),
    );
  }

  static const empty = StudyPeriodStats(
    totalMinutes: 0,
    subjectMinutes: {},
    activeDays: 0,
    averageMinutes: 0,
    bestDayMinutes: 0,
    daily: [],
    monthlyMinutes: {},
  );
}

Map<String, StudyPeriodStats> parsePeriods(Map<String, dynamic> json) {
  return json.map(
    (key, value) =>
        MapEntry(key, StudyPeriodStats.fromJson(value as Map<String, dynamic>)),
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

class MissionData {
  const MissionData({
    required this.personal,
    required this.timeMissions,
    required this.groups,
    required this.weekStart,
    required this.weekEnd,
  });

  final List<PersonalMission> personal;
  final List<TimeMissionSummary> timeMissions;
  final List<MissionGroupSummary> groups;
  final String weekStart;
  final String weekEnd;

  factory MissionData.fromJson(Map<String, dynamic> json) {
    return MissionData(
      personal: (json['personal'] as List<dynamic>? ?? [])
          .map((item) => PersonalMission.fromJson(item as Map<String, dynamic>))
          .toList(),
      timeMissions: (json['timeMissions'] as List<dynamic>? ?? [])
          .map(
            (item) => TimeMissionSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      groups: (json['groups'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                MissionGroupSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      weekStart: json['weekStart'] as String? ?? '',
      weekEnd: json['weekEnd'] as String? ?? '',
    );
  }

  static const empty = MissionData(
    personal: [],
    timeMissions: [],
    groups: [],
    weekStart: '',
    weekEnd: '',
  );
}

class PersonalMission {
  const PersonalMission({
    required this.id,
    required this.title,
    required this.description,
    required this.progressPercent,
    required this.status,
    this.targetMinutes,
    this.currentMinutes,
    this.targetCount,
    this.currentCount,
  });

  final String id;
  final String title;
  final String description;
  final int progressPercent;
  final String status;
  final int? targetMinutes;
  final int? currentMinutes;
  final int? targetCount;
  final int? currentCount;

  bool get isCompleted => status == 'completed';

  factory PersonalMission.fromJson(Map<String, dynamic> json) {
    return PersonalMission(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      progressPercent: json['progressPercent'] as int? ?? 0,
      status: json['status'] as String? ?? 'ready',
      targetMinutes: json['targetMinutes'] as int?,
      currentMinutes: json['currentMinutes'] as int?,
      targetCount: json['targetCount'] as int?,
      currentCount: json['currentCount'] as int?,
    );
  }
}

class TimeMissionSummary {
  const TimeMissionSummary({
    required this.id,
    required this.title,
    required this.startMinute,
    required this.endMinute,
    required this.targetMinutes,
    required this.currentMinutes,
    required this.myMinutes,
    required this.progressPercent,
    required this.status,
    required this.reminderEnabled,
    required this.participantCount,
    this.groupId,
    this.groupName,
  });

  final String id;
  final String title;
  final int startMinute;
  final int endMinute;
  final int targetMinutes;
  final int currentMinutes;
  final int myMinutes;
  final int progressPercent;
  final String status;
  final bool reminderEnabled;
  final int participantCount;
  final String? groupId;
  final String? groupName;

  bool get isCompleted => status == 'completed';
  bool get isGroupMission => groupId != null && groupId!.isNotEmpty;

  factory TimeMissionSummary.fromJson(Map<String, dynamic> json) {
    return TimeMissionSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startMinute: json['startMinute'] as int? ?? 0,
      endMinute: json['endMinute'] as int? ?? 0,
      targetMinutes: json['targetMinutes'] as int? ?? 0,
      currentMinutes: json['currentMinutes'] as int? ?? 0,
      myMinutes: json['myMinutes'] as int? ?? 0,
      progressPercent: json['progressPercent'] as int? ?? 0,
      status: json['status'] as String? ?? 'ready',
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      participantCount: json['participantCount'] as int? ?? 1,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
    );
  }
}

class MissionGroupSummary {
  const MissionGroupSummary({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.weeklyTargetMinutes,
    required this.weeklyMinutes,
    required this.progressPercent,
    required this.memberCount,
    required this.myMinutes,
    required this.members,
  });

  final String id;
  final String name;
  final String inviteCode;
  final int weeklyTargetMinutes;
  final int weeklyMinutes;
  final int progressPercent;
  final int memberCount;
  final int myMinutes;
  final List<MissionMemberSummary> members;

  factory MissionGroupSummary.fromJson(Map<String, dynamic> json) {
    return MissionGroupSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      weeklyTargetMinutes: json['weeklyTargetMinutes'] as int? ?? 0,
      weeklyMinutes: json['weeklyMinutes'] as int? ?? 0,
      progressPercent: json['progressPercent'] as int? ?? 0,
      memberCount: json['memberCount'] as int? ?? 0,
      myMinutes: json['myMinutes'] as int? ?? 0,
      members: (json['members'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                MissionMemberSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class MissionMemberSummary {
  const MissionMemberSummary({
    required this.userId,
    required this.nickname,
    required this.role,
    required this.weeklyMinutes,
    required this.progressPercent,
    required this.rank,
    required this.isCurrentUser,
  });

  final String userId;
  final String nickname;
  final String role;
  final int weeklyMinutes;
  final int progressPercent;
  final int rank;
  final bool isCurrentUser;

  factory MissionMemberSummary.fromJson(Map<String, dynamic> json) {
    return MissionMemberSummary(
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '사용자',
      role: json['role'] as String? ?? 'member',
      weeklyMinutes: json['weeklyMinutes'] as int? ?? 0,
      progressPercent: json['progressPercent'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}
