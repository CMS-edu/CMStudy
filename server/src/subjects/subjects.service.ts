import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateSubjectDto } from './dto';

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
}
