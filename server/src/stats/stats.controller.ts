import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StatsService } from './stats.service';

@Controller('stats')
@UseGuards(JwtAuthGuard)
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('summary')
  summary(
    @Req() request: AuthenticatedRequest,
    @Query('days') days = '7',
    @Query('date') date?: string,
    @Query('timezoneOffsetMinutes') timezoneOffsetMinutes = '0',
  ) {
    return this.statsService.summary(
      request.user!.sub,
      Number(days),
      date,
      Number(timezoneOffsetMinutes),
    );
  }
}
