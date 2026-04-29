import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatsService {
  constructor(private readonly prisma: PrismaService) {}

  async summary(
    userId: string,
    days = 7,
    anchorDate?: string,
    timezoneOffsetMinutes = 0,
  ) {
    const dateKeys = lastDateKeys(days, anchorDate);
    const from = localDateToUtc(dateKeys[0], timezoneOffsetMinutes);
    const until = localDateToUtc(
      addDays(dateKeys[dateKeys.length - 1], 1),
      timezoneOffsetMinutes,
    );
    const sessions = await this.prisma.studySession.findMany({
      where: {
        userId,
        startedAt: { gte: from, lt: until },
      },
      include: { subject: true },
      orderBy: { startedAt: 'asc' },
    });

    const daily = new Map(dateKeys.map((date) => [date, 0]));
    const subjectMinutes: Record<string, number> = {};

    for (const session of sessions) {
      const key = toLocalDateKey(session.startedAt, timezoneOffsetMinutes);
      daily.set(key, (daily.get(key) ?? 0) + session.durationMinutes);
      if (session.subject) {
        subjectMinutes[session.subject.name] =
          (subjectMinutes[session.subject.name] ?? 0) + session.durationMinutes;
      }
    }

    const today = dateKeys[dateKeys.length - 1];
    const dailyList = dateKeys.map((date) => ({
      date,
      minutes: daily.get(date) ?? 0,
    }));

    return {
      focusedToday: daily.get(today) ?? 0,
      weeklyTotal: dailyList.reduce((sum, item) => sum + item.minutes, 0),
      daily: dailyList,
      subjectMinutes,
    };
  }
}

function lastDateKeys(days: number, anchorDate?: string) {
  const count = Number.isFinite(days) ? Math.min(Math.max(days, 1), 31) : 7;
  const anchor = anchorDate
    ? new Date(`${anchorDate.slice(0, 10)}T00:00:00.000Z`)
    : new Date();
  return Array.from({ length: count }, (_, index) => {
    const date = new Date(anchor);
    date.setUTCDate(date.getUTCDate() - (count - 1 - index));
    return date.toISOString().slice(0, 10);
  });
}

function localDateToUtc(date: string, timezoneOffsetMinutes: number) {
  return new Date(
    Date.parse(`${date.slice(0, 10)}T00:00:00.000Z`) -
      timezoneOffsetMinutes * 60_000,
  );
}

function addDays(date: string, days: number) {
  const next = new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
  next.setUTCDate(next.getUTCDate() + days);
  return next.toISOString().slice(0, 10);
}

function toLocalDateKey(date: Date, timezoneOffsetMinutes: number) {
  return new Date(date.getTime() + timezoneOffsetMinutes * 60_000)
    .toISOString()
    .slice(0, 10);
}
