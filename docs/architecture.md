# Architecture — 서비스 (현재 구조)

> 현재 구조의 **'무엇/어떻게'**. 구조가 바뀌면 이 파일을 덮어쓴다(최신본만).
> 결정의 **'왜'**는 `docs/adr.md`. 요구의 시간순 기록은 `docs/prd/`.
> 하네스(에이전트·메모리 계층)는 `AGENTS.md`. 갱신 담당 = `create-prd`(planner).

## 서비스
- `app/main.py` — HTTP 표면(FastAPI). 현재 `GET /healthz`를 노출한다.
- `tests/test_healthz.py` — healthz 스모크(초록).
- `requirements.txt` — 런타임 의존성.

## 레이어 규약
- `app/main.py` = HTTP 경계. 도메인 로직은 여기 두지 않는다.
- 도메인 규칙이 생기면 **별도 모듈**로 분리하고, 입출력은 Pydantic DTO로 둔다.
  경계를 지켜 테스트·리뷰를 쉽게 한다. 구체 구조는 기능이 정해질 때 이 파일에 갱신한다.

## CI · 배포
- CI(`.github/workflows/ci.yml`): `test`(pytest) → `build-image`(`docker build`, 컨테이너 이미지 아티팩트). 테스트가 green이어야 이미지가 빌드된다.
- 배포(`.github/workflows/deploy-azure.yml`): CICD가 컨테이너를 **TF 프로비저닝 인프라**(Azure Container Apps)에 OIDC 단명 토큰으로 배포한다(ACR 빌드 → 이미지 교체). `production` Environment 보호(승인·브랜치 정책)가 강제 게이트.
- `infra/` — Azure IaC(Terraform) + `scripts/bootstrap-identity.sh` + `scripts/teardown-azure.sh`.
- 앱 = **단일 컨테이너**(`Dockerfile`). 전용 배포 에이전트 없음(거버넌스는 Environment 게이트).
