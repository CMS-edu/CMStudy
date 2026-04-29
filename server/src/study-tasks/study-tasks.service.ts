import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateStudyTaskDto } from './dto';

@Injectable()
export class StudyTasksService {
  constructor(private readonly prisma: PrismaService) {}

  async findForDate(userId: string, date: string) {
    const { start, end } = dayRange(date);
    const tasks = await this.prisma.studyTask.findMany({
      where: {
        userId,
        plannedDate: { gte: start, lt: end },
      },
      include: { subject: true },
      orderBy: [{ completedAt: 'asc' }, { createdAt: 'desc' }],
    });
    return tasks.map(toTaskResponse);
  }

  async create(userId: string, dto: CreateStudyTaskDto) {
    const subject = await this.prisma.subject.findFirst({
      where: { id: dto.subjectId, userId },
    });
    if (!subject) throw new ForbiddenException('사용할 수 없는 과목입니다.');

    const task = await this.prisma.studyTask.create({
      data: {
        userId,
        subjectId: dto.subjectId,
        title: dto.title,
        plannedMinutes: dto.plannedMinutes,
        plannedDate: dateOnly(dto.plannedDate),
      },
      include: { subject: true },
    });
    return toTaskResponse(task);
  }

  async toggle(userId: string, id: string) {
    const task = await this.prisma.studyTask.findFirst({
      where: { id, userId },
    });
    if (!task) throw new NotFoundException('계획을 찾을 수 없습니다.');

    const updated = await this.prisma.studyTask.update({
      where: { id },
      data: { completedAt: task.completedAt ? null : new Date() },
      include: { subject: true },
    });
    return toTaskResponse(updated);
  }

  async remove(userId: string, id: string) {
    const task = await this.prisma.studyTask.findFirst({
      where: { id, userId },
    });
    if (!task) throw new NotFoundException('계획을 찾을 수 없습니다.');
    await this.prisma.studyTask.delete({ where: { id } });
    return { ok: true };
  }
}

export function dayRange(date: string) {
  const start = dateOnly(date);
  const end = new Date(start);
  end.setUTCDate(end.getUTCDate() + 1);
  return { start, end };
}

function dateOnly(date: string) {
  return new Date(`${date.slice(0, 10)}T00:00:00.000Z`);
}

function toTaskResponse(task: {
  id: string;
  title: string;
  plannedMinutes: number;
  plannedDate: Date;
  completedAt: Date | null;
  subject: {
    id: string;
    name: string;
    color: string;
    targetMinutesPerDay: number;
  };
}) {
  return {
    id: task.id,
    title: task.title,
    plannedMinutes: task.plannedMinutes,
    plannedDate: task.plannedDate.toISOString().slice(0, 10),
    completedAt: task.completedAt?.toISOString() ?? null,
    subject: task.subject,
  };
}
