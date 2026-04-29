import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateStudyTaskDto } from './dto';
import { StudyTasksService } from './study-tasks.service';

@Controller('study-tasks')
@UseGuards(JwtAuthGuard)
export class StudyTasksController {
  constructor(private readonly tasksService: StudyTasksService) {}

  @Get()
  findForDate(@Req() request: AuthenticatedRequest, @Query('date') date: string) {
    return this.tasksService.findForDate(request.user!.sub, date);
  }

  @Post()
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateStudyTaskDto) {
    return this.tasksService.create(request.user!.sub, dto);
  }

  @Patch(':id/toggle')
  toggle(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.tasksService.toggle(request.user!.sub, id);
  }

  @Delete(':id')
  remove(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.tasksService.remove(request.user!.sub, id);
  }
}
