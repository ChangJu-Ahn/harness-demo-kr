---
name: review-architecture
description: docs/architecture.md와 실제 코드를 대조해 구조 정합성을 점검한다. 읽기 전용, 판정만.
---

# review-architecture

## 언제
구현·리뷰 전에 현재 구조를 이해해야 할 때. 구조 변경 후 문서-코드 드리프트를 확인할 때.

## 절차
1. `docs/architecture.md`를 읽는다(서비스·레이어 규약·CI/배포).
2. 실제 코드(`app/`, `Dockerfile`, `.github/workflows/`)의 구조와 대조한다.
3. 불일치를 나열한다: 문서에 없는 컴포넌트 / 문서와 다른 배치 / 레이어 위반
   (예: 도메인 규칙이 HTTP 경계(`main.py`)로 샘).
4. 판정을 요약한다(정합 / 불일치 목록).

## 역할 경계 (강제)
- 읽기 전용. 코드·문서를 수정하지 않는다. 문서 갱신은 `update-adr`/`create-prd`가 한다.

## 정지(STOP)
**이 스킬만 호출됐다면 대조 보고까지만 하고 멈춘다.** 불일치를 발견해도 고치지 않는다 —
코드는 `tdd`, 문서는 `update-adr`로 넘긴다.

## 출력
구조 정합/불일치 목록(문서 ↔ 코드 매핑).
