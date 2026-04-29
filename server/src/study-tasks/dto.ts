import { IsDateString, IsInt, IsString, Max, Min, MinLength } from 'class-validator';

export class CreateStudyTaskDto {
  @IsString()
  subjectId: string;

  @IsString()
  @MinLength(1)
  title: string;

  @IsInt()
  @Min(10)
  @Max(600)
  plannedMinutes: number;

  @IsDateString()
  plannedDate: string;
}
