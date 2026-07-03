# AGENTS.md — 하네스 (에이전트 헌법)

> 이 파일은 이 하네스의 **메모리 계층**의 헌법이다. 에이전트는 작업 시작 전 이 파일을 먼저 읽는다.
> 하네스 = "파일 + 루프 + 게이트". 무거운 프레임워크 없이 이 셋으로 모델을 일하게 만든다.
> 메모리 계층 = `AGENTS.md`(헌법) + `docs/prd/`(요구) + `docs/adr.md`(결정) + `docs/architecture.md`(구조)
> + **GitHub Space**(도메인 맥락). 시드엔 도메인이 없다 — Space를 붙이고 `grill`로 정렬해 PRD로 태어난다.

## 1. 이 서비스 / 도메인
시드는 **동작하는 서비스 스켈레톤**이다(`GET /healthz`, CI green). 도메인 요구는 **아직 시드에 없다.**
도메인 맥락은 **GitHub Space**(`https://github.com/copilot/spaces/hy2219/1`)로 주입하고,
`grill`로 정렬해 PRD(`docs/prd/`)로 태어난다. 근거(Space·PRD)에 없는 값은 추측하지 않는다 — 질문한다.

규제 도메인 원칙:
- **거버넌스가 기본.** 편의(자동화)와 통제(사람 승인 게이트)를 함께 설계한다.
- **비식별(PHI-0).** 환자 식별자·파형 원본·PHI를 코드·테스트·로그·이슈에 넣지 않는다.

## 2. 핵심 원칙 (타협 불가)
1. **테스트가 계약이다.** `tests/`는 행동 명세다. 테스트를 고쳐서 통과시키지 않는다 — 구현 코드를 바꿔 green을 만든다.
2. **작게, 수직으로.** 한 번에 한 슬라이스를 끝까지 관통시킨다.
3. **모호하면 멈추고 근거를 본다.** 도메인 맥락은 **GitHub Space**, 합의된 규칙·경계는 `docs/prd/`의 PRD가
   정본(시드엔 없다 — grill→create-prd로 태어난다). 근거에 없으면 추측하지 말고 질문한다.
4. **게이트를 통과시킨다.** green 후 reviewer 관점으로 스스로 점검한다(§5).

## 3. 기술 스택 / 명령어
- 런타임: Python 3, FastAPI(`app/main.py`). 현재 표면 = `GET /healthz`.
- 테스트: `python -m pytest -q` (저장소 루트 = 이 랩 폴더). 의존성: `pip install -r requirements.txt`.
- 도메인 로직이 생기면 **별도 모듈**로 분리하고 규칙을 한곳에 모은다(HTTP 경계 `main.py`와 분리).
  입출력은 Pydantic DTO로 둔다. 구조는 정해질 때 `docs/architecture.md`에 갱신한다.
- CI(`.github/workflows/ci.yml`): `test`(pytest) → `build-image`(`docker build` — 컨테이너 이미지·아티팩트).
  앱은 **단일 컨테이너**. 테스트가 green이어야 이미지가 빌드된다.
- 배포(`.github/workflows/deploy-azure.yml`): CICD가 컨테이너를 **TF(Terraform) 프로비저닝 인프라**에
  OIDC 단명 토큰으로 올린다 — 전용 배포 에이전트 없음(거버넌스는 `production` Environment 게이트).

## 4. 작업 루프 (표준)
에이전트(3): `planner` · `senior-developer` · `reviewer`
스킬(12): `grill` · `review-architecture` · `read-adr` · `update-adr` · `read-prd` ·
`read-unresolved-issues` · `create-prd` · `create-issue` · `tdd` · `strategize-fix` ·
`review-security` · `review-integrity`

```
planner[grill(대화 정렬) → 승인 → create-prd(로컬 PRD) → create-issue(클라우드 이슈)]
  → red 테스트 → senior-developer[tdd 최소 구현 (막히면 strategize-fix) → update-adr(결정 기록)]
  → green → reviewer(정합성·보안·PHI·OWASP 단일 게이트) → 머지 → CICD 배포(에이전트 없음) → 끝
```
- 정렬·기록·이슈화(구현 전) → **`planner`**: `grill`(대화) → **사용자 승인** → `create-prd`(로컬 `docs/prd/` + `architecture.md`) → `create-issue`(할당용 **클라우드** 이슈). 이슈까지 만들고 **멈춘다**.
- 구현/변경 → **`senior-developer`**: `tdd`. 실패 디버깅은 `strategize-fix`(전략만) → 다시 `tdd`.
- 머지 게이트 → **`reviewer`**: `review-integrity` + `review-security`.
- 배포 → **CICD**(`deploy-azure.yml`)가 컨테이너를 TF 인프라에 배포한다. 전용 에이전트 없음(거버넌스는 Environment 게이트).
- 역할 경계는 §6 표. planner는 코드를 안 쓰고, senior-developer는 이슈/PRD 확정 후에만 구현한다.

### 오케스트레이션 규칙 (강제)
- **스킬 단위 정지:** 각 스킬은 자기 한 가지 일만 하고 멈춘다("이 스킬만 호출됐다면 거기서 멈춤"). 다음 스킬 일로 자동 연쇄하지 않는다.
- **직접 핸드오프 금지:** 한 에이전트가 다음 에이전트에 결과를 **직접** 넘기지 않는다. 상위(오케스트레이터) 에이전트가 산출물을 받아 다음 역할에 전달한다. (관례+쓰기범위 규율이며 런타임 강제는 아니다.)
- **이슈 단일 창구:** 이슈(story·bug)는 **planner의 create-issue만** 만든다. reviewer·senior-developer·테스트가 버그를 발견하면 상위 에이전트를 거쳐 planner로 라우팅한다.

### 문서 모델
- `docs/prd/*` = 요구·행동(시간순, **로컬 SSOT**). 이슈 = GitHub(**클라우드 SSOT**), `story`/`bug`.
- `docs/architecture.md` = 현재 구조(무엇/어떻게, **planner**=create-prd가 기록). `docs/adr.md` = 현재 결정·근거(왜, **senior-developer**=update-adr가 기록). 둘 다 **덮어쓰기**(최신본만).

## 5. 리뷰 게이트 (머지 전 self-check)
- [ ] 기능 테스트 전부 green, 테스트가 **PRD 계약**을 충실히 인코딩(통과시키려 무력화 없음).
- [ ] 변경 범위 = 의도한 레이어만(기능 코드 = 도메인 모듈, 결정기록 = `docs/adr.md`). 무관 변경 없음.
- [ ] **PRD의 규칙 순서·경계**를 정확히 지킨다(임계값 포함/제외·우선순위 등 계약대로).
- [ ] CI(`test` → `build-image`)가 모두 green — 테스트가 통과해야 컨테이너 이미지가 빌드된다.
- [ ] PHI·환자 식별자·company/repo 이름이 코드·주석·로그에 없다.

> 이 self-check의 **전체 게이트 정본**은 `review-integrity` 스킬(정렬·범위·정확성·테스트·회귀·보안·가독성·관찰성·상태정직성). 심층 보안(PHI·시크릿·주입·권한·OWASP)은 `review-security`가 전담한다.

## 6. 역할 경계 — 자기 역할 밖은 하지 않는다 (강제)

**전역 규칙:** 모든 에이전트·스킬은 아래 표의 **자기 쓰기 범위 안에서만** 산출물을 만든다.
경계에 닿으면 **멈추고 다음 역할에 위임**한다. 역할이 애매하거나 PRD에 근거가 없으면
**진행하지 말고 질문**한다. "할 수 있어 보여서" 다음 단계를 대신 하지 않는다.

| 역할(에이전트) | 허용 쓰기 범위 | 정지(STOP) 조건 |
|------|----------------|-----------------|
| planner (grill·review-architecture·read-adr·read-prd·create-prd·create-issue) | `docs/prd/` + `docs/architecture.md`(create-prd) + **승인된 클라우드 이슈** 본문(create-issue). 로컬 `docs/issues/` 금지 | grill은 대화로만. **승인 후에만** create-prd·create-issue. 이슈 후 상위 에이전트 경유로 senior-developer에 넘기고 정지. 코드·테스트·배포 생성/수정 금지 |
| senior-developer (review-architecture·read-adr·read-unresolved-issues·tdd·strategize-fix·review-integrity·update-adr) | `app/`(도메인 모듈) + 신규 테스트 + `docs/adr.md`(update-adr) | 이슈/PRD 밖 변경 금지. **정렬·이슈화 금지**(planner 몫). 테스트는 계약(무력화 금지). strategize-fix는 전략만·수정은 tdd. 범위 모호=정지·질문 |
| reviewer (review-security·review-integrity) | 없음(판정만) | 코드 수정 금지 — senior-developer에 반려. 버그는 상위 경유 planner로(직접 이슈 생성 금지) |

**하지 말 것(공통):** 테스트 수정, 의존성 추가, 새 엔드포인트/파일 신설(요청 범위 밖),
추측으로 규칙 생성. PRD가 정본, 없으면 질문.

---
이 하네스는 라이브 데모용으로 **의도적으로 최소화**한 3역할(정렬 planner · 구현 senior-developer ·
리뷰 reviewer) 셋이다. 배포는 에이전트가 아니라 CICD(Actions→TF 인프라)가 수행한다.
정렬(planner)과 구현(senior-developer)을 별도 에이전트로 나눈 건 '각 역할이 자기 lane만' 원칙과
사람 승인 게이트를 눈에 보이게 하려는 설계다. 12개 스킬은 규제 SDLC의 메모리(PRD·ADR·architecture)·
정합성·보안 추적을 skills-first로 보이기 위한 것이다.
구조 출처: 사내 레퍼런스 하네스(agents·skills·PRD) + 발표 덱의 파일·루프·게이트 패턴.
