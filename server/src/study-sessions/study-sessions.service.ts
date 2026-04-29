import { ForbiddenException, Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateStudySessionDto } from './dto';

@Injectable()
export class StudySessionsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateStudySessionDto) {
    if (dto.subjectId) {
      const subject = await this.prisma.subject.findFirst({
        where: { id: dto.subjectId, userId },
      });
      if (!subject) throw new ForbiddenException('사용할 수 없는 과목입니다.');
    }

    return this.prisma.studySession.create({
      data: {
        userId,
        subjectId: dto.subjectId,
        startedAt: new Date(dto.startedAt),
        endedAt: new Date(dto.endedAt),
        durationMinutes: dto.durationMinutes,
        note: dto.note,
      },
    });
  }
}
