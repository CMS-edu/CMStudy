import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateMissionGroupDto, JoinMissionGroupDto } from './dto';

@Injectable()
export class MissionsService {
  constructor(private readonly prisma: PrismaService) {}

  async summary(
    userId: string,
    anchorDate?: string,
    timezoneOffsetMinutes = 0,
  ) {
    const today = (anchorDate ?? new Date().toISOString()).slice(0, 10);
    const tomorrow = addDays(today, 1);
    const weekStart = startOfWeek(today);
    const weekEnd = addDays(weekStart, 7);
    const todayFrom = localDateToUtc(today, timezoneOffsetMinutes);
    const todayUntil = localDateToUtc(tomorrow, timezoneOffsetMinutes);
    const weekFrom = localDateToUtc(weekStart, timezoneOffsetMinutes);
    const weekUntil = localDateToUtc(weekEnd, timezoneOffsetMinutes);

    const [subjects, todaySessions, weekSessions, memberships] =
      await Promise.all([
        this.prisma.subject.findMany({ where: { userId } }),
        this.prisma.studySession.findMany({
          where: { userId, startedAt: { gte: todayFrom, lt: todayUntil } },
          include: { subject: true },
        }),
        this.prisma.studySession.findMany({
          where: { userId, startedAt: { gte: weekFrom, lt: weekUntil } },
        }),
        this.prisma.missionGroupMember.findMany({
          where: { userId },
          include: {
            group: {
              include: {
                members: {
                  include: {
                    user: { select: { id: true, nickname: true, email: true } },
                  },
                  orderBy: { joinedAt: 'asc' },
                },
              },
            },
          },
          orderBy: { joinedAt: 'desc' },
        }),
      ]);

    const todayMinutes = sumMinutes(todaySessions);
    const weekMinutes = sumMinutes(weekSessions);
    const dailyTarget = subjects.reduce(
      (sum, subject) => sum + subject.targetMinutesPerDay,
      0,
    );
    const subjectMinutes = new Map<string, number>();
    for (const session of todaySessions) {
      if (!session.subject) continue;
      subjectMinutes.set(
        session.subject.name,
        (subjectMinutes.get(session.subject.name) ?? 0) +
          session.durationMinutes,
      );
    }

    const personal = buildPersonalMissions({
      subjects,
      subjectMinutes,
      todayMinutes,
      weekMinutes,
      dailyTarget,
      weekSessions,
      weekStart,
      timezoneOffsetMinutes,
    });

    const groups = await Promise.all(
      memberships.map(async (membership) => {
        const memberIds = membership.group.members.map((member) => member.userId);
        const sessions = await this.prisma.studySession.findMany({
          where: {
            userId: { in: memberIds },
            startedAt: { gte: weekFrom, lt: weekUntil },
          },
          select: { userId: true, durationMinutes: true },
        });
        const minutesByUser = new Map<string, number>();
        for (const session of sessions) {
          minutesByUser.set(
            session.userId,
            (minutesByUser.get(session.userId) ?? 0) + session.durationMinutes,
          );
        }
        const members = membership.group.members.map((member) => {
          const weeklyMinutes = minutesByUser.get(member.userId) ?? 0;
          const memberTarget = Math.max(
            1,
            Math.round(
              membership.group.weeklyTargetMinutes /
                Math.max(1, membership.group.members.length),
            ),
          );
          return {
            userId: member.userId,
            nickname: member.user.nickname,
            role: member.role,
            weeklyMinutes,
            progressPercent: percent(weeklyMinutes, memberTarget),
          };
        });
        const weeklyMinutes = Array.from(minutesByUser.values()).reduce(
          (sum, minutes) => sum + minutes,
          0,
        );
        return {
          id: membership.group.id,
          name: membership.group.name,
          inviteCode: membership.group.inviteCode,
          weeklyTargetMinutes: membership.group.weeklyTargetMinutes,
          weeklyMinutes,
          progressPercent: percent(
            weeklyMinutes,
            membership.group.weeklyTargetMinutes,
          ),
          memberCount: membership.group.members.length,
          myMinutes: minutesByUser.get(userId) ?? 0,
          members: members.sort((a, b) => b.weeklyMinutes - a.weeklyMinutes),
        };
      }),
    );

    return {
      personal,
      groups,
      weekStart,
      weekEnd: addDays(weekEnd, -1),
    };
  }

  async createGroup(userId: string, dto: CreateMissionGroupDto) {
    const inviteCode = await this.generateInviteCode();
    const group = await this.prisma.missionGroup.create({
      data: {
        ownerId: userId,
        name: dto.name.trim(),
        weeklyTargetMinutes: dto.weeklyTargetMinutes,
        inviteCode,
        members: {
          create: {
            userId,
            role: 'owner',
          },
        },
      },
    });
    return group;
  }

  async joinGroup(userId: string, dto: JoinMissionGroupDto) {
    const inviteCode = dto.inviteCode.trim().toUpperCase();
    const group = await this.prisma.missionGroup.findUnique({
      where: { inviteCode },
    });
    if (!group) throw new NotFoundException('존재하지 않는 초대 코드입니다.');

    try {
      await this.prisma.missionGroupMember.create({
        data: { groupId: group.id, userId, role: 'member' },
      });
    } catch {
      throw new ConflictException('이미 참여한 미션 그룹입니다.');
    }
    return group;
  }

  private async generateInviteCode() {
    for (let attempt = 0; attempt < 10; attempt += 1) {
      const code = Math.random().toString(36).slice(2, 8).toUpperCase();
      const exists = await this.prisma.missionGroup.findUnique({
        where: { inviteCode: code },
      });
      if (!exists) return code;
    }
    return `${Date.now().toString(36).slice(-6)}`.toUpperCase();
  }
}

type SubjectLike = {
  name: string;
  targetMinutesPerDay: number;
};

type PersonalMissionInput = {
  subjects: SubjectLike[];
  subjectMinutes: Map<string, number>;
  todayMinutes: number;
  weekMinutes: number;
  dailyTarget: number;
  weekSessions: Array<{ startedAt: Date; durationMinutes: number }>;
  weekStart: string;
  timezoneOffsetMinutes: number;
};

function buildPersonalMissions(input: PersonalMissionInput) {
  const activeDays = new Set(
    input.weekSessions.map((session) =>
      toLocalDateKey(session.startedAt, input.timezoneOffsetMinutes),
    ),
  ).size;
  const weakestSubject = [...input.subjects].sort((a, b) => {
    const aGap = a.targetMinutesPerDay - (input.subjectMinutes.get(a.name) ?? 0);
    const bGap = b.targetMinutesPerDay - (input.subjectMinutes.get(b.name) ?? 0);
    return bGap - aGap;
  })[0];
  const weakestProgress = weakestSubject
    ? Math.min(
        input.subjectMinutes.get(weakestSubject.name) ?? 0,
        weakestSubject.targetMinutesPerDay,
      )
    : 0;

  return [
    {
      id: 'today-target',
      title: '오늘 목표 채우기',
      description: '과목별 하루 목표를 합산한 오늘의 핵심 미션입니다.',
      targetMinutes: input.dailyTarget,
      currentMinutes: input.todayMinutes,
      progressPercent: percent(input.todayMinutes, input.dailyTarget),
      status: missionStatus(input.todayMinutes, input.dailyTarget),
    },
    {
      id: 'weekly-rhythm',
      title: '주간 리듬 만들기',
      description: '이번 주 5일 이상 공부 기록을 남기면 완료됩니다.',
      targetCount: 5,
      currentCount: activeDays,
      progressPercent: percent(activeDays, 5),
      status: missionStatus(activeDays, 5),
    },
    {
      id: 'weekly-volume',
      title: '주간 누적 10시간',
      description: '이번 주 총 공부 시간을 10시간까지 끌어올립니다.',
      targetMinutes: 600,
      currentMinutes: input.weekMinutes,
      progressPercent: percent(input.weekMinutes, 600),
      status: missionStatus(input.weekMinutes, 600),
    },
    {
      id: 'weak-subject',
      title: weakestSubject
        ? `${weakestSubject.name} 보강`
        : '부족 과목 보강',
      description: weakestSubject
        ? '오늘 목표 대비 가장 부족한 과목을 보강합니다.'
        : '과목을 추가하면 자동으로 보강 미션이 만들어집니다.',
      targetMinutes: weakestSubject?.targetMinutesPerDay ?? 0,
      currentMinutes: weakestProgress,
      progressPercent: weakestSubject
        ? percent(weakestProgress, weakestSubject.targetMinutesPerDay)
        : 0,
      status: weakestSubject
        ? missionStatus(weakestProgress, weakestSubject.targetMinutesPerDay)
        : 'locked',
    },
  ];
}

function missionStatus(current: number, target: number) {
  if (target <= 0) return 'locked';
  if (current >= target) return 'completed';
  if (current > 0) return 'active';
  return 'ready';
}

function percent(current: number, target: number) {
  if (target <= 0) return 0;
  return Math.min(100, Math.round((current / target) * 100));
}

function sumMinutes(sessions: Array<{ durationMinutes: number }>) {
  return sessions.reduce((sum, session) => sum + session.durationMinutes, 0);
}

function startOfWeek(date: string) {
  const value = new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
  const day = value.getUTCDay();
  const diff = day === 0 ? 6 : day - 1;
  value.setUTCDate(value.getUTCDate() - diff);
  return value.toISOString().slice(0, 10);
}

function addDays(date: string, days: number) {
  const next = new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
  next.setUTCDate(next.getUTCDate() + days);
  return next.toISOString().slice(0, 10);
}

function localDateToUtc(date: string, timezoneOffsetMinutes: number) {
  return new Date(
    Date.parse(`${date.slice(0, 10)}T00:00:00.000Z`) -
      timezoneOffsetMinutes * 60_000,
  );
}

function toLocalDateKey(date: Date, timezoneOffsetMinutes: number) {
  return new Date(date.getTime() + timezoneOffsetMinutes * 60_000)
    .toISOString()
    .slice(0, 10);
}
