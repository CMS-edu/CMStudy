import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateSubjectDto } from './dto';
import { SubjectsService } from './subjects.service';

@Controller('subjects')
@UseGuards(JwtAuthGuard)
export class SubjectsController {
  constructor(private readonly subjectsService: SubjectsService) {}

  @Get()
  findAll(@Req() request: AuthenticatedRequest) {
    return this.subjectsService.findAll(request.user!.sub);
  }

  @Post()
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateSubjectDto) {
    return this.subjectsService.create(request.user!.sub, dto);
  }
}
