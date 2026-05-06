import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';

import { PrismaService } from './prisma/prisma.service';

@Controller()
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  root() {
    return { ok: true, service: 'cmstudy-server' };
  }

  @Get('health')
  health() {
    return { ok: true };
  }

  @Get('health/db')
  async database() {
    const startedAt = Date.now();
    try {
      await Promise.race([
        this.prisma.$queryRaw`SELECT 1`,
        new Promise((_, reject) => {
          setTimeout(
            () => reject(new ServiceUnavailableException('DB 응답 지연')),
            5000,
          );
        }),
      ]);
    } catch (error) {
      if (error instanceof ServiceUnavailableException) throw error;
      throw new ServiceUnavailableException('DB 연결 실패');
    }

    return { ok: true, latencyMs: Date.now() - startedAt };
  }
}
