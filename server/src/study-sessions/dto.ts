import { IsDateString, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateStudySessionDto {
  @IsDateString()
  startedAt: string;

  @IsDateString()
  endedAt: string;

  @IsInt()
  @Min(1)
  @Max(720)
  durationMinutes: number;

  @IsOptional()
  @IsString()
  subjectId?: string;

  @IsOptional()
  @IsString()
  note?: string;
}
