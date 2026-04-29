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
    const allSessions = await this.prisma.studySession.findMany({
      where: { userId },
      include: { subject: true },
      orderBy: { startedAt: 'asc' },
    });

    const daily = new Map(dateKeys.map((date) => [date, 0]));
    const subjectMinutes: Record<string, number> = {};
    const todaySubjectMinutes: Record<string, number> = {};
    let totalMinutes = 0;

    for (const session of allSessions) {
      totalMinutes += session.durationMinutes;
    }

    for (const session of sessions) {
      const key = toLocalDateKey(session.startedAt, timezoneOffsetMinutes);
      daily.set(key, (daily.get(key) ?? 0) + session.durationMinutes);
      if (session.subject) {
        subjectMinutes[session.subject.name] =
          (subjectMinutes[session.subject.name] ?? 0) + session.durationMinutes;
        if (key === dateKeys[dateKeys.length - 1]) {
          todaySubjectMinutes[session.subject.name] =
            (todaySubjectMinutes[session.subject.name] ?? 0) +
            session.durationMinutes;
        }
      }
    }

    const today = dateKeys[dateKeys.length - 1];
    const dailyList = dateKeys.map((date) => ({
      date,
      minutes: daily.get(date) ?? 0,
    }));
    const monthStart = startOfMonth(today);
    const yearStart = startOfYear(today);
    const tomorrow = addDays(today, 1);

    return {
      focusedToday: daily.get(today) ?? 0,
      weeklyTotal: dailyList.reduce((sum, item) => sum + item.minutes, 0),
      totalMinutes,
      daily: dailyList,
      subjectMinutes,
      todaySubjectMinutes,
      periods: {
        day: buildPeriodStats(
          allSessions,
          today,
          tomorrow,
          timezoneOffsetMinutes,
        ),
        week: buildPeriodStats(
          allSessions,
          dateKeys[0],
          tomorrow,
          timezoneOffsetMinutes,
        ),
        month: buildPeriodStats(
          allSessions,
          monthStart,
          addMonths(monthStart, 1),
          timezoneOffsetMinutes,
        ),
        year: buildPeriodStats(
          allSessions,
          yearStart,
          addYears(yearStart, 1),
          timezoneOffsetMinutes,
        ),
        total: buildPeriodStats(allSessions, null, null, timezoneOffsetMinutes),
      },
    };
  }
}

type SessionWithSubject = {
  startedAt: Date;
  durationMinutes: number;
  subject: { name: string } | null;
};

function buildPeriodStats(
  sessions: SessionWithSubject[],
  startKey: string | null,
  endKey: string | null,
  timezoneOffsetMinutes: number,
) {
  const subjectMinutes: Record<string, number> = {};
  const daily = new Map<string, number>();
  const monthly = new Map<string, number>();
  let totalMinutes = 0;

  for (const session of sessions) {
    const key = toLocalDateKey(session.startedAt, timezoneOffsetMinutes);
    if (startKey !== null && key < startKey) continue;
    if (endKey !== null && key >= endKey) continue;

    totalMinutes += session.durationMinutes;
    daily.set(key, (daily.get(key) ?? 0) + session.durationMinutes);
    const monthKey = key.slice(0, 7);
    monthly.set(monthKey, (monthly.get(monthKey) ?? 0) + session.durationMinutes);
    if (session.subject) {
      subjectMinutes[session.subject.name] =
        (subjectMinutes[session.subject.name] ?? 0) + session.durationMinutes;
    }
  }

  const dailyList =
    startKey === null || endKey === null
      ? Array.from(daily.entries())
          .sort(([first], [second]) => first.localeCompare(second))
          .map(([date, minutes]) => ({ date, minutes }))
      : dateRange(startKey, endKey).map((date) => ({
          date,
          minutes: daily.get(date) ?? 0,
        }));
  const activeDays = Array.from(daily.values()).filter((minutes) => minutes > 0)
    .length;
  const bestDayMinutes = Math.max(0, ...Array.from(daily.values()));

  return {
    totalMinutes,
    subjectMinutes,
    activeDays,
    averageMinutes: activeDays === 0 ? 0 : Math.round(totalMinutes / activeDays),
    bestDayMinutes,
    daily: dailyList,
    monthlyMinutes: Object.fromEntries(
      Array.from(monthly.entries()).sort(([first], [second]) =>
        first.localeCompare(second),
      ),
    ),
  };
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

function dateRange(startKey: string, endKey: string) {
  const dates: string[] = [];
  let current = startKey;
  while (current < endKey) {
    dates.push(current);
    current = addDays(current, 1);
  }
  return dates;
}

function startOfMonth(date: string) {
  return `${date.slice(0, 7)}-01`;
}

function startOfYear(date: string) {
  return `${date.slice(0, 4)}-01-01`;
}

function addMonths(date: string, months: number) {
  const next = new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
  next.setUTCMonth(next.getUTCMonth() + months);
  return next.toISOString().slice(0, 10);
}

function addYears(date: string, years: number) {
  const next = new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
  next.setUTCFullYear(next.getUTCFullYear() + years);
  return next.toISOString().slice(0, 10);
}

function toLocalDateKey(date: Date, timezoneOffsetMinutes: number) {
  return new Date(date.getTime() + timezoneOffsetMinutes * 60_000)
    .toISOString()
    .slice(0, 10);
}
