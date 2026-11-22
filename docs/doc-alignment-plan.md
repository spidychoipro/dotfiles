# 문서-설정 정합성 정리 계획

> 승인: 2026-11-22 (사용자: "알아서해봐") / 상태: DO
> 선행 작업: `docs/portability-plan.md` (커밋 `76b654d`)

## 목표 (success criteria — 측정 가능)

1. `HYPRLAND.md`에 현재 존재하지 않는 바인드/스크립트/모니터 이름이 0건
2. `QUICKSHELL.md`가 "현재 사용 중"이 아니라 "보류·미사용" 상태로 명시된다
3. `docs/workflow.md`의 스크래치패드 결론이 `docs/hyprland-dracula-persona-plan.md`의 최종 결정(재추가 금지)과 1개로 통일된다
4. `README.md`의 스크린샷 바인드가 실제 `PRINT`(단독)과 일치하고, 존재하지 않는 `Super+Enter` 주장이 0건
5. 실제 키바인드/외형/autostart는 변경하지 않는다 (`hyprland.lua` diff 없음)
6. 저장소 변경분 커밋 + origin 푸시, `git status` 깨끗

## 배경

이식성 패치 이후 설정은 정리됐으나 문서가 서로 다른 시대의 상태를 말하고 있다:

- `HYPRLAND.md` (2026-08-17): `eDP-1` 고정, `window_switcher.sh`, `Super+Shift+Space`,
  `Super+Shift+W`, `Super+Tab` 등 현재 없는 바인드/스크립트를 설명
- `QUICKSHELL.md`: "Phase 0~1 완료"라고 적혔으나 실제 심링크는 깨져 있고 미사용
- `docs/workflow.md`: `Super+grave` 스크래치패드 재도입을 결정했으나, 이후
  `hyprland-dracula-persona-plan.md`에서 재추가 금지·전체 삭제로 최종 확정
- `README.md`: 실제 바인드는 `PRINT` 단독인데 `Super + Print`로 표기

## 작업 목록

### 1. HYPRLAND.md 현재화
- 헤더 기준일 갱신, 모니터 섹션 자동 감지/환경변수 오버라이드 반영
- 파일 표에서 `window_switcher.sh` 제거
- 키바인드 표에서 미존재 3개(`Super+Shift+Space`, `Super+Shift+W`, `Super+Tab`) 제거
- fcitx5 설정 분리/한영 키政策 한 줄 추가

### 2. QUICKSHELL.md 상태 정정
- 문서 상단에 "보류·미사용 (analysis archive)" 명시
- "Phase 0~1 완료"를 과거 계획 기록으로 변경, 현재 상태는 심링크 깨짐·미사용으로 기재

### 3. workflow.md 충돌 해소
- §2 Scratchpad 결정: 재도입 → **최종 삭제 유지**로 덮어쓰기 (근거: persona plan)
- §7 항목 3·4도 동일 결론으로 통일
- §4 "빈 자리" 목록에서 `Super+grave` 의도적 미사용으로 표시

### 4. README 오류 정정
- `Super + Print` → `Print`

### 5. 검증 & 커밋
- `grep`으로 미존재 바인드/경로 잔존 여부 확인
- `hyprland.lua`가 변경되지 않았음을 `git diff`로 확인
- 커밋 + 푸시

## Negative Space (NSP)

### What NOT to do
- 키바인드, Dracula 색상, 애니메이션, 워크스페이스 룰 등 실제 설정은 변경하지 않는다
- 스크래치패드/드롭다운 터미널/Quickshell을 구현하거나 재추가하지 않는다
- 과거 결정의 "이력" 자체는 삭제하지 않고, 최종 결론을 덧붙여 충돌만 해소한다

### Anti-patterns
- 문서를 새로 쓰면서 실제 바인드를 추측해 기재하기 (반드시 `hyprland.lua` 기준)
- `hyprctl binds`의 `__lua`/숫자 arg를 사람이 읽을 수 있는 바인드로 오해하기
- home 루트 문서와 repo 문서를 무작정 한곳으로 이동 (이번 범위 아님)

### Out of scope
- 워크플로 인터뷰를 통한 신규 바인드 추가/제거
- `HYPRLAND.md`·`QUICKSHELL.md`를 git 저장소로 이동
- 배경 이미지, 폰트, 테마 변경
- fcitx5 설정 추가 변경

### Tech NOT to use
- 추측 기반 문서 자동 생성 스크립트
- 하드코딩된 `/home/<user>` 경로 (문서 신규 기재 시 `~` 사용)

### Boundaries
- 변경 파일: `HYPRLAND.md`, `QUICKSHELL.md`, `dotfiles/docs/workflow.md`,
  `dotfiles/README.md`, `dotfiles/docs/doc-alignment-plan.md`
- `dotfiles/hypr/hyprland.lua`는 읽기 전용 근거 자료

### Edge cases NOT handled
- README의 59개 전체 바인드 완전 문서화 (현재 22개 — 이번에는 명백한 오류만 정정)
- 다국어 문서화
- 문서 이력(git blame) 보존을 위한 별도 changelog 작성

## 롤백

백업은 `/tmp/opencode/doc-alignment-<timestamp>/`에 파일별 복사본을 둔다.
저장소 변경분은 `git revert <commit>`, home 루트 문서는 백업에서 복구.
