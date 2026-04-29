import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StatsService } from '../stats/stats.service';
import { StudyTasksService } from '../study-tasks/study-tasks.service';
import { SubjectsService } from '../subjects/subjects.service';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(
    private readonly subjectsService: SubjectsService,
    private readonly tasksService: StudyTasksService,
    private readonly statsService: StatsService,
  ) {}

  @Get()
  async get(
    @Req() request: AuthenticatedRequest,
    @Query('date') date?: string,
    @Query('timezoneOffsetMinutes') timezoneOffsetMinutes = '0',
  ) {
    const targetDate = date ?? new Date().toISOString().slice(0, 10);
    const [subjects, tasks, stats] = await Promise.all([
      this.subjectsService.findAll(request.user!.sub),
      this.tasksService.findForDate(request.user!.sub, targetDate),
      this.statsService.summary(
        request.user!.sub,
        7,
        targetDate,
        Number(timezoneOffsetMinutes),
      ),
    ]);

    return { subjects, tasks, stats };
  }
}
