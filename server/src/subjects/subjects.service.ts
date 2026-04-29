import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateSubjectDto, UpdateSubjectDto } from './dto';

@Injectable()
export class SubjectsService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(userId: string) {
    return this.prisma.subject.findMany({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });
  }

  create(userId: string, dto: CreateSubjectDto) {
    return this.prisma.subject.create({
      data: {
        userId,
        name: dto.name,
        color: dto.color,
        targetMinutesPerDay: dto.targetMinutesPerDay,
      },
    });
  }

  async update(userId: string, id: string, dto: UpdateSubjectDto) {
    await this.ensureOwnedSubject(userId, id);

    return this.prisma.subject.update({
      where: { id },
      data: {
        name: dto.name,
        color: dto.color,
        targetMinutesPerDay: dto.targetMinutesPerDay,
      },
    });
  }

  async remove(userId: string, id: string) {
    await this.ensureOwnedSubject(userId, id);
    const count = await this.prisma.subject.count({ where: { userId } });
    if (count <= 1) {
      throw new BadRequestException('과목은 최소 1개 이상 필요합니다.');
    }

    await this.prisma.subject.delete({ where: { id } });
    return { ok: true };
  }

  private async ensureOwnedSubject(userId: string, id: string) {
    const subject = await this.prisma.subject.findFirst({
      where: { id, userId },
    });
    if (!subject) throw new NotFoundException('과목을 찾을 수 없습니다.');
    return subject;
  }
}
