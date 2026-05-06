import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AuthModule } from './auth/auth.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { HealthController } from './health.controller';
import { MissionsModule } from './missions/missions.module';
import { PrismaModule } from './prisma/prisma.module';
import { StatsModule } from './stats/stats.module';
import { StudySessionsModule } from './study-sessions/study-sessions.module';
import { StudyTasksModule } from './study-tasks/study-tasks.module';
import { SubjectsModule } from './subjects/subjects.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    SubjectsModule,
    StudyTasksModule,
    StudySessionsModule,
    StatsModule,
    MissionsModule,
    DashboardModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
