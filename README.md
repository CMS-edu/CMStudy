# CMStudy

Flutter Android 앱과 NestJS API 서버로 구성한 공부 관리 앱입니다.

## 구성

- `apps/mobile`: Android 설치용 Flutter 앱
- `server`: NestJS API 서버
- `docker-compose.yml`: 로컬 PostgreSQL

## 로컬 실행 순서

1. PostgreSQL 실행

```powershell
docker compose up -d postgres
```

2. 서버 환경변수 준비

```powershell
Copy-Item server\.env.example server\.env
```

3. 서버 의존성 설치 및 DB 마이그레이션

```powershell
npm.cmd --prefix server install
npm.cmd --prefix server run prisma:migrate
npm.cmd --prefix server run start:dev
```

4. Flutter 앱 실행

```powershell
flutter --suppress-analytics -d android run apps/mobile
```

Android 에뮬레이터는 API 서버 주소로 `http://10.0.2.2:3000`을 사용합니다. 실제 스마트폰에서 테스트할 때는 같은 Wi-Fi의 PC IP를 `--dart-define=API_BASE_URL=http://PC_IP:3000`으로 넘기면 됩니다.
