import { IsHexColor, IsInt, IsString, Max, Min, MinLength } from 'class-validator';

export class CreateSubjectDto {
  @IsString()
  @MinLength(1)
  name: string;

  @IsHexColor()
  color: string;

  @IsInt()
  @Min(10)
  @Max(600)
  targetMinutesPerDay: number;
}
