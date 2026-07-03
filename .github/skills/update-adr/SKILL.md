---
name: update-adr
description: 구조·기능이 바뀌었을 때 docs/adr.md를 현재 결정으로 덮어쓴다. 쓰기 범위 = adr.md만.
---

# update-adr

## 언제
`senior-developer`가 구현하면서 아키텍처 결정이 바뀌거나 새 결정이 생겼을 때(구현 완료·구조 변경 후).

## 절차
1. 현재 `docs/adr.md`를 읽는다.
2. 바뀐 결정을 반영한다 — **낡은 내용은 지우고 현재 결정만 남긴다(덮어쓰기)**.
   각 결정: 결정 / 근거(왜) / `status`(accepted·superseded·deprecated). 결정엔 확신 점수를 달지 않는다(확신 태그는 실측 주장용).
3. `docs/architecture.md`(현재 구조)와 모순이 없는지 확인한다.
4. **필요하면** 결정의 구조 영향을 `mermaid`로 간단히 곁들인다(선택).

## 역할 경계 (강제)
- 담당 = **`senior-developer`**(구현하며 결정을 기록한다). 쓰기 범위 = `docs/adr.md`뿐. 코드·PRD·이슈·배포를 수정하지 않는다.
- ADR은 '왜'만 담는다. '무엇/어떻게'(구조 사실)는 `architecture.md`에 둔다(중복 금지).

## 정지(STOP)
**이 스킬만 호출됐다면 adr.md 갱신까지만 하고 멈춘다.** 코드·PRD 변경으로 넘어가지 않는다.

## 출력
갱신된 `docs/adr.md`의 요지(바뀐 결정).
