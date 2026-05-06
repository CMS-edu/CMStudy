import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({
    super.key,
    required this.controller,
    required this.onStartStudy,
  });

  final AppController controller;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final missionData = controller.missionData;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
          children: [
            Text(
              '미션',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              '혼자 버티는 기록을 개인 미션과 그룹 미션으로 바꿉니다.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            _MissionHero(data: missionData),
            const SizedBox(height: 18),
            _GroupCommandCenter(controller: controller),
            const SizedBox(height: 18),
            _SectionHeader(
              title: '내 공부 그룹',
              trailing: '${missionData.groups.length}개',
            ),
            const SizedBox(height: 10),
            if (missionData.groups.isEmpty)
              _EmptyGroupCard(controller: controller)
            else
              ...missionData.groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MissionGroupCard(
                    group: group,
                    onOpen: () => showGroupDetailSheet(context, group),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            _GroupDiscoverySection(controller: controller),
            const SizedBox(height: 18),
            _SectionHeader(
              title: '시간대 미션',
              trailing: '${missionData.timeMissions.length}개',
            ),
            const SizedBox(height: 10),
            if (missionData.timeMissions.isEmpty)
              _EmptyTimeMissionCard(controller: controller)
            else
              ...missionData.timeMissions.map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TimeMissionCard(
                    mission: mission,
                    onStartStudy: onStartStudy,
                  ),
                ),
              ),
            if (missionData.timeMissions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      showCreateTimeMissionSheet(context, controller),
                  icon: const Icon(Icons.add_alarm_outlined),
                  label: const Text('시간대 미션 추가'),
                ),
              ),
            const SizedBox(height: 18),
            const _SectionHeader(title: '개인 미션'),
            const SizedBox(height: 10),
            if (missionData.personal.isEmpty)
              const _EmptyMissionCard(
                title: '개인 미션 준비 중',
                message: '서버 배포가 끝나면 오늘 목표, 주간 리듬, 보강 과목 미션이 표시됩니다.',
              )
            else
              ...missionData.personal.map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PersonalMissionCard(mission: mission),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MissionHero extends StatelessWidget {
  const _MissionHero({required this.data});

  final MissionData data;

  @override
  Widget build(BuildContext context) {
    final completed =
        data.personal.where((mission) => mission.isCompleted).length +
        data.timeMissions.where((mission) => mission.isCompleted).length;
    final total = data.personal.length + data.timeMissions.length;
    final progress = total == 0 ? 0 : ((completed / total) * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                '$progress%',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.weekStart.isEmpty
                        ? '이번 주 미션'
                        : '${data.weekStart.substring(5)} - ${data.weekEnd.substring(5)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? '미션 데이터를 불러오는 중입니다.'
                        : '$completed/$total개 미션 완료 · 그룹 ${data.groups.length}개',
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / total,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCommandCenter extends StatelessWidget {
  const _GroupCommandCenter({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final joined = controller.missionData.groups.length;
    final discoverable = controller.groupDirectory.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '그룹 허브',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '내 그룹 $joined · 공개 $discoverable',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '같이 공부할 방을 만들고, 이미 열린 그룹을 둘러본 뒤 바로 참여할 수 있습니다.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 10),
              _InlineError(message: controller.errorMessage!),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : () => showCreateGroupSheet(context, controller),
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('그룹 만들기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : () => showJoinGroupSheet(context, controller),
                    icon: const Icon(Icons.key_outlined),
                    label: const Text('코드 참여'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(22),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupDiscoverySection extends StatelessWidget {
  const _GroupDiscoverySection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final groups = controller.groupDirectory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: '그룹 둘러보기', trailing: '${groups.length}개'),
        const SizedBox(height: 10),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.travel_explore_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '아직 볼 수 있는 그룹이 없습니다. 첫 공개 그룹을 만들어보세요.',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GroupDirectoryCard(group: group, controller: controller),
            ),
          ),
      ],
    );
  }
}

class _GroupDirectoryCard extends StatelessWidget {
  const _GroupDirectoryCard({required this.group, required this.controller});

  final MissionGroupSummary group;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final topMember = group.members.isEmpty ? null : group.members.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusPill(
                  label: group.isJoined ? '참여 중' : '공개',
                  selected: group.isJoined,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.memberCount}명 · 방장 ${group.ownerNickname ?? '-'} · 이번 주 ${formatMinutes(group.weeklyMinutes)}',
              style: const TextStyle(color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
            ),
            if (topMember != null) ...[
              const SizedBox(height: 8),
              Text(
                '1위 ${topMember.nickname} · ${formatMinutes(topMember.weeklyMinutes)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (group.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showGroupDetailSheet(context, group),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('열람'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: group.isJoined || controller.isBusy
                        ? null
                        : () => joinGroupFromUi(
                            context,
                            controller,
                            group.inviteCode,
                          ),
                    icon: const Icon(Icons.login),
                    label: Text(group.isJoined ? '참여 완료' : '참여'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF059669)
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(24),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _EmptyTimeMissionCard extends StatelessWidget {
  const _EmptyTimeMissionCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm_add_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '기상 공부 미션을 만들어보세요',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '예: 05:30-07:00에 60분 공부. 알림을 누르면 앱이 기록 탭으로 열립니다.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => showCreateTimeMissionSheet(context, controller),
              icon: const Icon(Icons.add_alarm_outlined),
              label: const Text('시간대 미션 만들기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeMissionCard extends StatelessWidget {
  const _TimeMissionCard({required this.mission, required this.onStartStudy});

  final TimeMissionSummary mission;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final color = mission.isCompleted
        ? const Color(0xFF059669)
        : Theme.of(context).colorScheme.primary;
    final scope = mission.isGroupMission
        ? '${mission.groupName ?? '그룹'} · ${mission.participantCount}명'
        : '개인 미션';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: color.withAlpha(24),
                  ),
                  child: Icon(
                    mission.isCompleted
                        ? Icons.verified_outlined
                        : Icons.schedule_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${timeRangeLabel(mission.startMinute, mission.endMinute)} · $scope',
                        style: const TextStyle(color: Colors.blueGrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (mission.reminderEnabled)
                  const Tooltip(
                    message: '매일 시작 시간 알림',
                    child: Icon(Icons.notifications_active_outlined, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricLine(
                    label: mission.isGroupMission ? '전체' : '오늘',
                    value:
                        '${formatMinutes(mission.currentMinutes)} / ${formatMinutes(mission.targetMinutes)}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricLine(
                    label: '내 기록',
                    value: formatMinutes(mission.myMinutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (mission.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 9,
                color: color,
                backgroundColor: color.withAlpha(26),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onStartStudy,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('공부 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _PersonalMissionCard extends StatelessWidget {
  const _PersonalMissionCard({required this.mission});

  final PersonalMission mission;

  @override
  Widget build(BuildContext context) {
    final color = mission.isCompleted
        ? const Color(0xFF059669)
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mission.isCompleted
                      ? Icons.check_circle
                      : Icons.flag_outlined,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mission.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  missionLabel(mission),
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.description,
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (mission.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 8,
                color: color,
                backgroundColor: color.withAlpha(28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroupCard extends StatelessWidget {
  const _EmptyGroupCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '아직 그룹이 없습니다',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              '친구와 주간 목표를 같이 채우는 작은 공부방을 만들 수 있습니다.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showCreateGroupSheet(context, controller),
                    icon: const Icon(Icons.add),
                    label: const Text('그룹 만들기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showJoinGroupSheet(context, controller),
                    icon: const Icon(Icons.login),
                    label: const Text('코드 참여'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionGroupCard extends StatelessWidget {
  const _MissionGroupCard({required this.group, required this.onOpen});

  final MissionGroupSummary group;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _InviteCode(code: group.inviteCode),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.memberCount}명 · 이번 주 ${formatMinutes(group.weeklyMinutes)} / ${formatMinutes(group.weeklyTargetMinutes)}',
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (group.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 9,
                color: color,
                backgroundColor: color.withAlpha(28),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  '주간 랭킹',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...group.members
                .take(5)
                .map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MemberRow(member: member),
                  ),
                ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new),
                label: const Text('그룹 상세'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteCode extends StatelessWidget {
  const _InviteCode({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(code, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final MissionMemberSummary member;

  @override
  Widget build(BuildContext context) {
    final color = member.isCurrentUser
        ? Theme.of(context).colorScheme.primary
        : Colors.blueGrey;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(member.isCurrentUser ? 32 : 18),
          ),
          child: Text(
            member.rank == 0 ? '-' : '${member.rank}',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            member.isCurrentUser ? '${member.nickname} · 나' : member.nickname,
            style: const TextStyle(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (member.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: color.withAlpha(20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatMinutes(member.weeklyMinutes),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: Colors.blueGrey)),
      ],
    );
  }
}

class _TimeMissionDraft {
  const _TimeMissionDraft({
    required this.title,
    required this.startMinute,
    required this.endMinute,
    required this.targetMinutes,
    required this.reminderEnabled,
    this.groupId,
  });

  final String title;
  final int startMinute;
  final int endMinute;
  final int targetMinutes;
  final bool reminderEnabled;
  final String? groupId;
}

class _CreateGroupDraft {
  const _CreateGroupDraft({
    required this.name,
    required this.weeklyTargetMinutes,
  });

  final String name;
  final int weeklyTargetMinutes;
}

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet();

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final nameController = TextEditingController(text: '새 미션 그룹');
  int targetMinutes = 1800;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '미션 그룹 만들기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '그룹 이름'),
          ),
          const SizedBox(height: 16),
          Text('주간 그룹 목표 ${formatMinutes(targetMinutes)}'),
          Slider(
            value: targetMinutes.toDouble(),
            min: 300,
            max: 6000,
            divisions: 19,
            label: formatMinutes(targetMinutes),
            onChanged: (value) {
              setState(() => targetMinutes = value.round());
            },
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void submit() {
    final name = nameController.text.trim();
    if (name.length < 2) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(
      context,
    ).pop(_CreateGroupDraft(name: name, weeklyTargetMinutes: targetMinutes));
  }
}

class _EmptyMissionCard extends StatelessWidget {
  const _EmptyMissionCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.flag_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.blueGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> joinGroupFromUi(
  BuildContext context,
  AppController controller,
  String inviteCode,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await controller.joinMissionGroup(inviteCode);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok ? '그룹에 참여했습니다.' : controller.errorMessage ?? '그룹 참여에 실패했습니다.',
      ),
    ),
  );
}

Future<void> showGroupDetailSheet(
  BuildContext context,
  MissionGroupSummary group,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    requestFocus: false,
    showDragHandle: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.76,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _InviteCode(code: group.inviteCode),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${group.memberCount}명 · 방장 ${group.ownerNickname ?? '-'}',
                style: const TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricLine(
                      label: '이번 주 전체',
                      value: formatMinutes(group.weeklyMinutes),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricLine(
                      label: '주간 목표',
                      value: formatMinutes(group.weeklyTargetMinutes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (group.progressPercent / 100).clamp(0.0, 1.0),
                  minHeight: 9,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '주간 멤버 랭킹',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (group.members.isEmpty)
                const Text(
                  '아직 표시할 멤버 기록이 없습니다.',
                  style: TextStyle(color: Colors.blueGrey),
                )
              else
                ...group.members.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MemberRow(member: member),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showCreateTimeMissionSheet(
  BuildContext context,
  AppController controller,
) async {
  final titleController = TextEditingController(text: '기상 공부 미션');
  var startTime = const TimeOfDay(hour: 5, minute: 30);
  var endTime = const TimeOfDay(hour: 7, minute: 0);
  var targetMinutes = 60;
  var reminderEnabled = true;
  String? groupId;

  final result = await showModalBottomSheet<_TimeMissionDraft>(
    context: context,
    isScrollControlled: true,
    requestFocus: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickStart() async {
            final picked = await showTimePicker(
              context: context,
              initialTime: startTime,
            );
            if (picked != null) setModalState(() => startTime = picked);
          }

          Future<void> pickEnd() async {
            final picked = await showTimePicker(
              context: context,
              initialTime: endTime,
            );
            if (picked != null) setModalState(() => endTime = picked);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.viewInsetsOf(context).bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '시간대 미션 만들기',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '미션 이름'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickStart,
                        icon: const Icon(Icons.play_arrow_outlined),
                        label: Text('시작 ${startTime.format(context)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickEnd,
                        icon: const Icon(Icons.stop_outlined),
                        label: Text('종료 ${endTime.format(context)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: groupId,
                  decoration: const InputDecoration(labelText: '적용 범위'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('개인 미션'),
                    ),
                    ...controller.missionData.groups.map(
                      (group) => DropdownMenuItem<String?>(
                        value: group.id,
                        child: Text('${group.name} 그룹 미션'),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(() => groupId = value),
                ),
                const SizedBox(height: 16),
                Text('목표 시간 ${formatMinutes(targetMinutes)}'),
                Slider(
                  value: targetMinutes.toDouble(),
                  min: 10,
                  max: 240,
                  divisions: 23,
                  label: formatMinutes(targetMinutes),
                  onChanged: (value) {
                    setModalState(() => targetMinutes = value.round());
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: reminderEnabled,
                  onChanged: (value) {
                    setModalState(() => reminderEnabled = value);
                  },
                  title: const Text('시작 시간 알림'),
                  subtitle: const Text('알림을 누르면 기록 탭으로 이동합니다.'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.length < 2) return;
                    Navigator.pop(
                      context,
                      _TimeMissionDraft(
                        title: title,
                        startMinute: timeOfDayToMinutes(startTime),
                        endMinute: timeOfDayToMinutes(endTime),
                        targetMinutes: targetMinutes,
                        reminderEnabled: reminderEnabled,
                        groupId: groupId,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alarm_outlined),
                  label: const Text('미션 만들기'),
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(titleController.dispose);

  if (result == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 300));
  await controller.createTimeMission(
    title: result.title,
    startMinute: result.startMinute,
    endMinute: result.endMinute,
    targetMinutes: result.targetMinutes,
    reminderEnabled: result.reminderEnabled,
    groupId: result.groupId,
  );
}

Future<void> showCreateGroupSheet(
  BuildContext context,
  AppController controller,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await showModalBottomSheet<_CreateGroupDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    requestFocus: false,
    builder: (_) => const _CreateGroupSheet(),
  );

  if (result == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final ok = await controller.createMissionGroup(
    name: result.name,
    weeklyTargetMinutes: result.weeklyTargetMinutes,
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok
            ? '${result.name} 그룹을 만들었습니다.'
            : controller.errorMessage ?? '그룹을 만들지 못했습니다.',
      ),
    ),
  );
}

Future<void> showJoinGroupSheet(
  BuildContext context,
  AppController controller,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final codeController = TextEditingController();
  final inviteCode = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    requestFocus: false,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '초대 코드로 참여',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '초대 코드'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.length < 4) return;
                Navigator.pop(context, code);
              },
              icon: const Icon(Icons.login),
              label: const Text('참여'),
            ),
          ],
        ),
      );
    },
  ).whenComplete(codeController.dispose);

  if (inviteCode == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final ok = await controller.joinMissionGroup(inviteCode);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok ? '그룹에 참여했습니다.' : controller.errorMessage ?? '그룹 참여에 실패했습니다.',
      ),
    ),
  );
}

String missionLabel(PersonalMission mission) {
  if (mission.targetMinutes != null && mission.currentMinutes != null) {
    return '${formatMinutes(mission.currentMinutes!)} / ${formatMinutes(mission.targetMinutes!)}';
  }
  if (mission.targetCount != null && mission.currentCount != null) {
    return '${mission.currentCount}/${mission.targetCount}';
  }
  return '${mission.progressPercent}%';
}

int timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

String timeRangeLabel(int startMinute, int endMinute) {
  return '${clockLabel(startMinute)}-${clockLabel(endMinute)}';
}

String clockLabel(int minuteOfDay) {
  final minute = minuteOfDay.clamp(0, 1439);
  final hour = minute ~/ 60;
  final minutePart = minute % 60;
  return '${hour.toString().padLeft(2, '0')}:${minutePart.toString().padLeft(2, '0')}';
}
