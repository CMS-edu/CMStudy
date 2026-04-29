import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateStudySessionDto } from './dto';
import { StudySessionsService } from './study-sessions.service';

@Controller('study-sessions')
@UseGuards(JwtAuthGuard)
export class StudySessionsController {
  constructor(private readonly sessionsService: StudySessionsService) {}

  @Post()
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateStudySessionDto) {
    return this.sessionsService.create(request.user!.sub, dto);
  }
}
