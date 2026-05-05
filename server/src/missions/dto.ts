import { IsInt, IsString, Max, Min, MinLength } from 'class-validator';

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
