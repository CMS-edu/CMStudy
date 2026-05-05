import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key, required this.controller});

  final AppController controller;

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
            const SizedBox(height: 18),
            _SectionHeader(
              title: '미션 그룹',
              trailing: '${missionData.groups.length}개',
            ),
            const SizedBox(height: 10),
            if (missionData.groups.isEmpty)
              _EmptyGroupCard(controller: controller)
            else
              ...missionData.groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MissionGroupCard(group: group),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _MissionActions(controller: controller),
    );
  }
}

class _MissionHero extends StatelessWidget {
  const _MissionHero({required this.data});

  final MissionData data;

  @override
  Widget build(BuildContext context) {
    final completed = data.personal
        .where((mission) => mission.isCompleted)
        .length;
    final total = data.personal.length;
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
                        : '$completed/$total개 개인 미션 완료',
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
  const _MissionGroupCard({required this.group});

  final MissionGroupSummary group;

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
            ...group.members
                .take(5)
                .map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MemberRow(member: member),
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
    return Row(
      children: [
        CircleAvatar(radius: 14, child: Text(member.nickname.characters.first)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            member.nickname,
            style: const TextStyle(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(formatMinutes(member.weeklyMinutes)),
      ],
    );
  }
}

class _MissionActions extends StatelessWidget {
  const _MissionActions({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'join-mission-group',
          onPressed: () => showJoinGroupSheet(context, controller),
          child: const Icon(Icons.login),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'create-mission-group',
          onPressed: () => showCreateGroupSheet(context, controller),
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('그룹 만들기'),
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

Future<void> showCreateGroupSheet(
  BuildContext context,
  AppController controller,
) {
  final nameController = TextEditingController(text: '새 미션 그룹');
  var targetMinutes = 1800;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                  '미션 그룹 만들기',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '그룹 이름'),
                  autofocus: true,
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
                    setModalState(() => targetMinutes = value.round());
                  },
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.length < 2) return;
                    await controller.createMissionGroup(
                      name: name,
                      weeklyTargetMinutes: targetMinutes,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('만들기'),
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(nameController.dispose);
}

Future<void> showJoinGroupSheet(
  BuildContext context,
  AppController controller,
) {
  final codeController = TextEditingController();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
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
              autofocus: true,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.length < 4) return;
                await controller.joinMissionGroup(code);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.login),
              label: const Text('참여'),
            ),
          ],
        ),
      );
    },
  ).whenComplete(codeController.dispose);
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
