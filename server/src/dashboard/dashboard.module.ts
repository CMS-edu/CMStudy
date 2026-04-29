import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { StatsModule } from '../stats/stats.module';
import { StudyTasksModule } from '../study-tasks/study-tasks.module';
import { SubjectsModule } from '../subjects/subjects.module';
import { DashboardController } from './dashboard.controller';

@Module({
  imports: [AuthModule, SubjectsModule, StudyTasksModule, StatsModule],
  controllers: [DashboardController],
})
export class DashboardModule {}
