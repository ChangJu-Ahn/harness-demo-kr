---
name: read-unresolved-issues
description: 아직 열려 있는(미해결) GitHub 이슈(유저스토리+버그)를 조회한다. 읽기 전용.
---

# read-unresolved-issues

## 언제
다음 작업을 파악하거나, 중복을 확인하거나, 정합성 점검 전 열린 작업을 볼 때.

## 절차
1. `gh issue list --state open`(필요 시 `--label story|bug`, `--search`).
2. 각 이슈의 **type(story|bug)** · PRD 출처(본문의 `PRD 기준:` 각인) · 수용 기준을 요약한다.
3. (`senior-developer`) 전달받은 PRD에 해당하는 이슈만 필터한다(그 PRD 각인이 있는 이슈).

## 역할 경계 (강제)
- 읽기 전용. 이슈를 만들거나 수정·종료하지 않는다(생성은 `create-issue`).

## 정지(STOP)
**이 스킬만 호출됐다면 목록·요약까지만 하고 멈춘다.** 구현·해결로 넘어가지 않는다.

## 출력
미해결 이슈 목록(type · PRD 출처 · 수용 기준).
