---
name: review-security
description: 규제 의료 도메인에서 중요한 보안 요소를 점검한다 — PHI 경계·시크릿·의존성·인젝션·OWASP. 읽기 전용, 플래그만.
---

# review-security

## 언제
구현이 green이 된 뒤 머지 전(리뷰 게이트). 변경 diff를 대상으로 한다.

## 정본 계약 (반드시 이 순서)
1. `AGENTS.md`를 먼저 읽는다(PHI-0 원칙).
2. 변경 diff만 심사한다 — 전체 앱 코드를 재심사하지 않는다.

## 체크리스트
- [ ] **PHI-0**: 처리 대상이 비식별 메타데이터로 한정되고 PHI가 섞이지 않음.
- [ ] 환자 식별자·파형 원본·이름·날짜·기관명 없음(코드·주석·로그·테스트 포함).
- [ ] 시크릿·API 키·자격증명 없음(GitHub Secret scanning 신호 포함).
- [ ] 추가된 의존성에 알려진 CVE·타이포스쿼팅 위험 없음.
- [ ] **OWASP Top 10** 관점: 인젝션(SQLi·command)·안전하지 않은 역직렬화·접근제어·암호화 오용
      (CodeQL이 잡을 패턴) 없음.
- [ ] 사람 머지 게이트를 우회하는 로직 없음.

## 역할 경계 (강제)
- 담당 = **`reviewer`**. 읽기 = `app/`, `tests/`, `Dockerfile`, `.github/workflows/`.
- 쓰기 = **없음**. 수정은 `senior-developer`에게 반려한다.

## 정지(STOP)
**이 스킬만 호출됐다면 판정까지만 하고 멈춘다.** 코드를 직접 고치지 않는다.

## 출력
`SECURITY PASS` 또는 `SECURITY FLAGS` + 항목별 한 줄 근거.
PHI 위반이 있으면 무조건 `SECURITY FLAGS` — 해결 전까지 머지 금지.
