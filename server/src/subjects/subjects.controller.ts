import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedRequest, JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateSubjectDto, UpdateSubjectDto } from './dto';
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

  @Patch(':id')
  update(
    @Req() request: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() dto: UpdateSubjectDto,
  ) {
    return this.subjectsService.update(request.user!.sub, id, dto);
  }

  @Delete(':id')
  remove(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.subjectsService.remove(request.user!.sub, id);
  }
}
