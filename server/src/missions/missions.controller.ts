import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  CreateMissionGroupDto,
  CreateTimeMissionDto,
  JoinMissionGroupDto,
} from './dto';
import { MissionsService } from './missions.service';

@Controller('missions')
@UseGuards(JwtAuthGuard)
export class MissionsController {
  constructor(private readonly missionsService: MissionsService) {}

  @Get()
  summary(
    @Req() request: AuthenticatedRequest,
    @Query('date') date?: string,
    @Query('timezoneOffsetMinutes') timezoneOffsetMinutes = '0',
  ) {
    return this.missionsService.summary(
      request.user!.sub,
      date,
      Number(timezoneOffsetMinutes),
    );
  }

  @Post('groups')
  createGroup(
    @Req() request: AuthenticatedRequest,
    @Body() dto: CreateMissionGroupDto,
  ) {
    return this.missionsService.createGroup(request.user!.sub, dto);
  }

  @Post('groups/join')
  joinGroup(
    @Req() request: AuthenticatedRequest,
    @Body() dto: JoinMissionGroupDto,
  ) {
    return this.missionsService.joinGroup(request.user!.sub, dto);
  }

  @Post('time-rules')
  createTimeMission(
    @Req() request: AuthenticatedRequest,
    @Body() dto: CreateTimeMissionDto,
  ) {
    return this.missionsService.createTimeMission(request.user!.sub, dto);
  }
}
