---
name: create-prd
description: 요구를 PRD로 기록한다 — 누가·언제·왜·무엇 + architecture.md 갱신. 쓰기 = docs/prd + architecture.md. 이슈는 만들지 않는다.
---

# create-prd

## 언제
`grill`로 정렬하고 **사용자 승인을 받은 뒤**, 새 요구·변경을 durable 명세로 남길 때.

## 원칙 — PRD는 로컬 SSOT
PRD(`docs/prd/*.md`) = 요구·행동의 버전 관리 기록. 이슈(클라우드)와 분리한다.

## 절차
1. **파일**: `docs/prd/NNN-<슬러그>.md`(신규) 또는 기존 PRD 갱신.
2. **헤더(추적)**: 누가(요청자) · 언제(ISO 시각) · 왜(배경·이유) · 무엇(요구 요약).
3. **본문**: 규칙 · 경계 · 임계값 · 범위 밖. 테스트 가능하게 쓴다. **필요하면** 흐름·상태를 `mermaid` 다이어그램으로 곁들인다(과하면 생략).
4. **architecture.md 갱신**: 이 요구가 구조에 영향을 주면 `docs/architecture.md`의 해당 부분을
   현재 상태로 반영한다(무엇/어떻게).
5. **비식별(PHI-0)**: 환자 식별자·파형 원본·PHI를 PRD에 넣지 않는다(도메인 맥락의 출처는 Space).

## 역할 경계 (강제)
- 담당 = **`planner`**. 쓰기 범위 = `docs/prd/` + `docs/architecture.md`뿐.
- 코드·테스트·이슈·배포를 만들거나 수정하지 않는다.

## 정지(STOP)
**이 스킬만 호출됐다면 PRD(+architecture.md) 기록까지만 하고 멈춘다.**
이슈화(`create-issue`)로 **자동으로 넘어가지 않는다** — 이슈는 별도 스킬·별도 승인이다.

## 출력
새/갱신 PRD 경로 + 요지. 이후 `create-issue`는 별도 단계.
