import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
} from 'class-validator';

export class CreateMissionGroupDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsInt()
  @Min(60)
  @Max(10080)
  weeklyTargetMinutes: number;
}

export class JoinMissionGroupDto {
  @IsString()
  @MinLength(4)
  inviteCode: string;
}

export class CreateTimeMissionDto {
  @IsString()
  @MinLength(2)
  title: string;

  @IsInt()
  @Min(0)
  @Max(1439)
  startMinute: number;

  @IsInt()
  @Min(0)
  @Max(1439)
  endMinute: number;

  @IsInt()
  @Min(5)
  @Max(1440)
  targetMinutes: number;

  @IsBoolean()
  @IsOptional()
  reminderEnabled?: boolean;

  @IsString()
  @IsOptional()
  groupId?: string;
}
