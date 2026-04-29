import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

export type AuthenticatedRequest = {
  headers: Record<string, string | undefined>;
  user?: { sub: string; email: string };
};

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authorization = request.headers.authorization;
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('로그인이 필요합니다.');
    }

    const token = authorization.slice('Bearer '.length);
    try {
      request.user = await this.jwt.verifyAsync<{ sub: string; email: string }>(
        token,
      );
      return true;
    } catch {
      throw new UnauthorizedException('로그인이 만료되었습니다.');
    }
  }
}
