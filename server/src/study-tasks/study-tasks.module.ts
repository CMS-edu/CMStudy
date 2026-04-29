import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { PrismaModule } from '../prisma/prisma.module';
import { StudyTasksController } from './study-tasks.controller';
import { StudyTasksService } from './study-tasks.service';

@Module({
  imports: [AuthModule, PrismaModule],
  controllers: [StudyTasksController],
  providers: [StudyTasksService],
  exports: [StudyTasksService],
})
export class StudyTasksModule {}
