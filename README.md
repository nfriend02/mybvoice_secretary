# MYB Voice Secretary

MyBranch 포트폴리오 브랜치앱. Flutter 웹/모바일, Firebase Firestore, Github → Vercel.

- Github: https://github.com/nfriend02/mybvoice_secretary
- Vercel: https://mybvoice-secretary.vercel.app

음성 대화, PDF 요약, 대화 요약, RAG 검색에 일정, 메일 초안, 번역, 워크플로, 학습 카드를 더한 음성 비서입니다. 웹과 모바일을 함께 씁니다.

## 구조

Feature-Sliced Design. 자세한 트리는 `lib/STRUCTURE.md`.

| 레이어 | 역할 |
|--------|------|
| `lib/main.dart` | 진입점. dotenv 후 Firebase 초기화 |
| `lib/app/` | 라우터, 테마, Firebase 부트스트랩 |
| `lib/pages/` | Home, 음성, PDF, 대화, RAG, 일정, 메일, 번역, 워크플로, 학습, 업로드 |
| `lib/features/` | 음성 응답, 일정 해석, 메일 초안, 번역, 워크플로, 학습 카드, PDF, RAG |
| `lib/services/` | Firestore CRUD, Auth, 세션 |
| `lib/shared/` | 반응형 셸, 10개 페이지네이션, `/api` 클라이언트 |
| `api/` | `/api/health`, `/api/summarize` |

## 반응형

- 데스크톱 769px 이상: 왼쪽 사이드바 + 오른쪽 콘텐츠
- 모바일 768px 이하: 상단 메뉴 한 줄 + 아래 콘텐츠
- 목록은 스크롤 끝에서 10개씩 더 보여 줍니다

## 로컬 실행

```bash
cp .env.example .env
flutter pub get
flutter run -d chrome
```

Firebase 초기화에 실패하면 데모 모드로 UI만 열립니다. 기본 클라이언트 설정은 `lib/firebase_options.dart`와 `assets/config/app.env`에 있습니다. DB 연결 값은 `.env`에 둡니다.

## Firebase

- 프로젝트: `mybvoicesecretary`
- 컬렉션: `messages`, `summaries`, `documents`, `uploads`
- 기본 인덱스: `createdAt`, `status` (`firestore.indexes.json`)
- 규칙: `firestore.rules`
- CRUD: `lib/services/firestore_service.dart`

Supabase를 붙일 때는 `id`, `created_at` 인덱스를 기본으로 둡니다. 이 앱의 저장소는 Firestore입니다.

## Github → Vercel

1. Vercel에서 이 저장소를 연결하고 Production Branch를 `main`으로 둡니다.
2. 빌드는 `vercel.json` → `vercel/build.sh` (Flutter web).
3. Environment Variables에 `.env.example`과 같은 키를 넣습니다. 비어 있으면 저장소의 공개 웹 설정을 사용합니다.
4. `main`에 PR이 병합되면 Vercel이 웹을 다시 빌드해 전시합니다.
5. `/api/health`, `/api/summarize`는 `api/` 서버리스 함수입니다.

### Vercel 환경변수

`FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`, `FIREBASE_MEASUREMENT_ID`, `APP_TITLE`, `APP_DESCRIPTION`, `APP_AUTHOR`, `APP_ICON_URL`, `GITHUB_BRANCH_URL`, `VERCEL_SITE_URL`, `OPENWEATHER_API_KEY`, `EXCHANGE_RATE_API_KEY`, `GEMINI_API_KEY`, `YOUR_GOOGLE_MAPS_API_KEY`

날씨, 환율, 지도, Gemini 요약은 `/api/weather`, `/api/exchange`, `/api/maps`, `/api/summarize`에서 이 키를 읽습니다. 로컬 실행은 `.env.example`을 `assets/config/app_config.env`로 복사합니다.

### 업로드 체크리스트

- [x] Github branch URL: https://github.com/nfriend02/mybvoice_secretary
- [x] 아이콘: `web/icons/Icon-512.png` (`/icons/Icon-512.png`)
- [x] 설명 200자 이내 (`APP_DESCRIPTION`)
- [x] 제작자/팀명: MyBranch Team

## PR

기능 브랜치에서 작업한 뒤 `main`으로 PR을 보냅니다. 병합되면 Vercel이 자동으로 빌드합니다.
