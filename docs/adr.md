# ADR — 서비스 아키텍처 결정 (현재)

> 이 서비스의 **아키텍처 결정과 근거('왜')**. 구조가 바뀌면 낡은 결정을 지우고 현재 결정으로
> 덮어쓴다(최신본만). '무엇/어떻게'는 `docs/architecture.md`.
> **하네스(에이전트 토폴로지·이슈 창구·리뷰 통합·배포 소유)는 이 문서가 아니라 `AGENTS.md`가 정본.**
> status: `accepted`(현재 유효) · `superseded`(대체됨) · `deprecated`(폐기).
> 새 기능을 구현하며 그 기능의 아키텍처 결정은 `update-adr`(senior-developer)가 여기에 추가한다.

## 1. 단일 컨테이너 서비스 — status: accepted
앱은 단일 컨테이너(`Dockerfile`)로 패키징한다. 레지스트리·클러스터·오케스트레이터(차트) 없이
CI가 `build-image`로 이미지를 만들어 배포 단위로 쓴다. 관심사 분리는 워크플로 + Environment 게이트로 충분하다.

## 2. 배포 = CICD → TF 프로비저닝 인프라, OIDC — status: accepted
배포는 Actions(`deploy-azure.yml`)가 컨테이너를 Terraform으로 만든 인프라에 **OIDC 단명 토큰**으로
올린다(장수 시크릿 0). `production` Environment의 승인·브랜치 정책이 강제 게이트.

## 3. HTTP 경계와 도메인 로직 분리 — status: accepted
`app/main.py`는 HTTP 표면만 담당한다. 도메인 로직·DTO는 기능이 정해질 때 별도 모듈로 분리한다.
규칙을 한곳에 모아 테스트·리뷰를 쉽게 하려는 것.

## 4. ECG 인테이크 게이트 — 순수 판정 함수 분리 — status: accepted
`POST /ecg/intake`의 판정 규칙은 `app/ecg_intake.py`의 순수 함수(`evaluate_intake`)와 Pydantic DTO에
모은다(HTTP 경계 `main.py`와 분리). 규칙을 순서 있는 조기 반환으로 두어 **스키마 위반(리드·샘플레이트·
길이)이 신뢰도 게이트보다 우선**임을 코드 순서로 강제한다. 임계값은 포함적(`<`만 미달)이라 경계값이
통과하도록 한다. 사람 검토(`needs_human_review`)는 판정 값만 반환하고 실제 워크플로는 게이트 밖.

---
> 기능별 도메인 결정(규칙·경계·데이터 계약)은 이 서비스에 기능이 추가될 때 `update-adr`가 기록한다.
