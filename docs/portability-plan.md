# dotfiles 이식성 패치 계획

> 승인일: 2026-11-22 / 상태: DO 진행 중
> 백업: `/tmp/opencode/portability-20261122-204650`

## 목표 (success criteria — 측정 가능)

1. `grep -rn '/home/<user>' <dotfiles>` 결과가 문서(`docs/`) 외에는 0건
2. `grep -rn 'eDP-1'` 결과가 문서 외에는 0건
3. `install.sh`를 이 머신에서 두 번 연속 실행해도 자기참조 심링크가 생기지 않고 `hyprctl configerrors`가 비어 있음
4. 새 사용자명(`testuser`)으로 치환한 임시 복사본에서 `bash -n` 및 경로 해석 테스트 통과
5. fcitx5 런타임이 dotfiles를 덮어쓰지 않음 — `git status`에 `fcitx5/conf/hangul.conf`가 나타나지 않음
6. 한/영 키 전환 동작 유지 (`fcitx5-remote -n` = `hangul`, Shift 단독 토글 제거)
7. 커밋 + origin 푸시 완료

## 배경

현재 설정은 단일 머신(hoco30-latitude7390)에 맞춰 하드코딩돼 있어 다른 머신에 clone 후 `install.sh`만 실행하면 다음이 깨진다:
- 사용자 경로 3개, 모니터 이름 3개
- `install.sh`가 fcitx5 설정의 `config`만 심링크 → 한글 입력기 미구성
- `pdf-open.sh`, `current-wallpaper`, swayosd 설정 누락
- 배경 이미지(`backgrounds/anime-*`)는 gitignore → clone 시 없음
- 실행 중인 fcitx5가 `~/.config/fcitx5` 폴더 심링크를 통해 tracked 파일을 지속적으로 덮어씀

## 작업 목록

### 1. 경로/모니터 이식성
- `hypr/hyprland.lua`: `output = ""` 와일드카드 + `HYPR_MONITOR` / `HYPR_MONITOR_SCALE` 환경변수 오버라이드
- `hypr/hyprpaper.conf`: `monitor = ` (fallback), `path = ~/.config/hypr/current-wallpaper`
- `hypr/cycle_wallpaper.sh`: `hyprctl monitors`에서 첫 출력 이름 동적 추출
- `zsh/zshrc`: `$HOME/.local/bin`
- `swayosd/config.toml`: `@CONFIG_DIR@` 템플릿 → install.sh가 절대경로로 렌더

### 2. install.sh 재작성
- `link_dir()` / `link_file()` 헬퍼로 idempotent 심링크
- 설정 디렉터리는 폴더째 심링크 (현재 머신 구조와 일치, 누락 파일 자동 포함)
- `current-wallpaper`가 없으면 사용 가능한 배경 중 첫 파일로 자동 생성
- fcitx5는 **실제 디렉터리 + 복사본**으로 분리 ( 런타임 저장이 dotfiles에 닿지 않게 )
- swayosd config.toml은 템플릿에서 렌더, style.css는 심링크
- `thunar-fix` 및 `chsh`는 기존 동작 유지

### 3. 한/영 키 동작
- `fcitx5/config`: `[Hotkey/AltTriggerKeys]`의 `Shift_L` 제거 (윈도우 한글 IME와 동일하게 한/영 키·우측 Alt만 토글)
- `Hangul` / `Alt+Alt_R` 트리거는 유지

### 4. 문서
- `README.md`: 다른 머신 설치section — 배경 이미지 별도 복사 안내, 환경변수 오버라이드, 요구 Hyprland 버전 명시
- `docs/portability-plan.md`: 본 문서

### 5. 검증 & 커밋
- `bash -n`, `hyprctl configerrors`, `hyprctl monitors`, `hyprctl hyprpaper listactive`
- `fcitx5-remote -n`, fcitx5 mtime 안정성 확인
- `git status`, 커밋, 푸시

## Negative Space (NSP)

### What NOT to do
- 키바인드, 애니메이션, Dracula 색상, 레이아웃, 워크스페이스 규칙은 변경하지 않는다
- hypridle/hyprlock/waybar/rofi/swaync 설정 값은 건드리지 않는다 (경로·모니터 관련 hanya)
- 배경 이미지 파일 자체를 추가/삭제/변환하지 않는다
- fcitx5의 `Hangul`, `Alt+Alt_R` 트리거 키는 제거하지 않는다
- 새 의존성(pkg, 스크립트, 도구)을 설치하지 않는다

### Anti-patterns
- `sed -i`로 tracked 파일을 런타임에 수정 (과거 cycle_wallpaper.sh 문제 재발 금지)
- `install.sh`에서 무조건 `rm -rf` 후 심링크 — 기존 사용자 설정 파괴
- 환경변수 오버라이드를 하드코딩 기본값으로 되돌리기
- 한 번에 몰아서 수정 후 검증 없이 커밋

### Out of scope
- Quickshell 마이그레이션 (깨진 심링크는 그대로 유지, 이번 패치에서 건드리지 않음)
- 멀티모니터 레이아웃/위치 세부 정책 (와일드카드 적용만)
- 다른 배포판 패키지 설치 스크립트 작성
- `Super+Space`와 fcitx5 그룹 전환키 충돌 해결 (그룹이 1개라 무영향)

### Tech NOT to use
- 하드코딩 `/home/<user>` (문서 외)
- hyprpaper 모니터 이름 고정
- fcitx5 설정의 폴더째 심링크

### Boundaries
- 변경 파일: `hypr/hyprland.lua`, `hypr/hyprpaper.conf`, `hypr/cycle_wallpaper.sh`, `zsh/zshrc`, `swayosd/config.toml`, `fcitx5/config`, `install.sh`, `README.md`, `docs/portability-plan.md`
- 1 작업 단위마다 검증 후 다음 단계

### Edge cases NOT handled
- 완전한 듀얼 모니터 자동 배치 (와일드카드가 전부 같은 scale을 적용)
- hyprpaper fallback이 아닌 모니터별 다른 배경
- 배경 이미지 저작권/라이선스 정리
- X11 세션

## 롤백

백업 디렉터리 `/tmp/opencode/portability-20261122-204650`에서 파일별 복구.
fcitx5 심링크 복구: `rm -rf ~/.config/fcitx5 && ln -s ~/dotfiles/fcitx5 ~/.config/fcitx5` 후 `fcitx5-remote -r`.
hyprpaper/hyprland 복구 후 `hyprctl reload`, `hyprctl hyprpaper reload`.
git revert는 커밋 후 사용.
