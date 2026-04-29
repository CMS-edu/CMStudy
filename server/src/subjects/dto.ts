import {
  IsHexColor,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
} from 'class-validator';

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

export class UpdateSubjectDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  name?: string;

  @IsOptional()
  @IsHexColor()
  color?: string;

  @IsOptional()
  @IsInt()
  @Min(10)
  @Max(600)
  targetMinutesPerDay?: number;
}
