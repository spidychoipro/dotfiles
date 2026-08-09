# ANALYSIS ONLY 보고서 — dotfiles 리팩터링 + Desktop Environment 설계

> 분석 기준: **실행 중인 Hyprland 0.56.0 / 설치된 바이너리 0.56.2** (Lua config = 공식 지원, v0.55부터 hyprlang deprecated). 모든 `hl.*` API는 설치 패키지의 공식 스텁 `/usr/share/hypr/stubs/hl.meta.lua`와 `src/config/lua/` 헤더, 그리고 `/usr/share/hypr/hyprland.lua`(공식 예제)로 검증했습니다.
>
> **변경된 파일 없음. git working tree clean 확인됨.**

---

## 1. Repository Overview

```
/home/hoco30/dotfiles  (branch: agent/publish-hyprland-dotfiles, 57 commits ahead of main)
├── install.sh          # 심링크 설치 스크립트 (파일 단위)
├── README.md           # 공유/마케팅 성향 문서
├── diagnose.sh         # [STALE] 오프라인 진단 (삭제된 toggle_term.sh 참조)
├── hypr/
│   ├── hyprland.lua    # 메인 Lua config (407줄, 공식 예제 템플릿 기반)
│   ├── hypridle.conf / hyprlock.conf / hyprpaper.conf / hyprlauncher.conf / hyprtoolkit.conf
│   ├── cycle_wallpaper.sh / toggle_window_layout.sh / pdf-open.sh
│   └── diagnose.sh     # [최신본] (루트의 것과 중복, 내용 상이)
├── waybar/             # config + style.css + battery.sh + bluetooth.py + mediaplayer.py + network.sh
├── rofi/config.rasi    # launcher 테마+설정
├── kitty/              # kitty.conf + current-theme.conf (Dracula)
├── zsh/zshrc           # starship, fzf, eza, zoxide
├── swaync/ swayosd/    # 알림센터 + OSD (Dracula)
├── fcitx5/             # config, hangul.conf(중복 2곳), profile, conf/
├── backgrounds/        # anime-* 20개 (gitignore됨) + 구형 비애니 이미지
├── gtk-3.0/ gtk-4.0/ gtkrc/ gtkrc-2.0/  # Dracula GTK + 데코레이션
├── kdeglobals/ Trolltech.conf/          # Qt 어두운 테마 (KDE Plasma 잔재이지만 QT_QPA_PLATFORMTHEME=kde로 실제 사용됨)
├── xsettingsd/ yad/ xfce4/ EOS-greeter.conf/ mimeapps.list/ brave/
├── starship/ fastfetch/(mumei 로고) zathura/
├── wsl/                # [LEGACY] WSL 시절 설정 (.zshrc, wsl.conf 등)
├── scripts/            # bash 학습 레슨 + plymouth 복구 툴킷
└── docs/               # 이전 리팩터링 계획서 (hyprland-dracula-persona-plan.md)
```

실제 설치 상태: `~/.config/{hypr,waybar,kitty,rofi,swaync,zathura,fcitx5,backgrounds,fastfetch}`는 **전체 디렉터리 심링크** (8/5에 수동 전환, `.config-backup-zathura-symlink-*`에 이전본 백업), `~/.config/starship.toml`은 파일 심링크. `~/.zshrc` → dotfiles/zsh/zshrc.

---

## 2. Git History (85 commits, 단일 저자 spidychoipro)

**생성 과정:**
1. **2026-02 "Initial commit"** — WSL Arch 환경으로 시작 (LICENSE/README만)
2. **WSL 단계** — zshrc/kitty/inputrc/wsl.conf, Dracula 테마, 한글 UTF-8. 그 후 `.zshrc`를 실제 사용자와 동기화하는 반복 작업들 (7cf8634, dca3073, 15dce56)
3. **EndeavourOS 전환** — `hyprland.lua` 도입. **`4ac7253 "detach from typecraft dotfiles"`** 커밋명이 결정적: 현재 hypr 설정의 뿌리는 **typecraft dotfiles**(유튜브 채널)에서 유래. gaps/blur/border 등도 "공식 예제값"(be0fd81)으로 조정하며 진화
4. **앱별 폴더 재구성** (571c857) → `hyprland.lua`를 `hypr/`로 이동 (c04d19b)
5. **`081821e Merge PR #1 "agent/publish-hyprland-dotfiles"`** — 현재 브랜치명과 동일한 **에이전트(LLM) 생성 PR**. waybar 스크립트/rofi/bluetooth.py/mediaplayer.py/style.css 대량 추가
6. **기능 레이어링 (PR 병합 후 57커밋)** — cliphist(904810a) → swayosd(5b40dd3) → WiFi 메뉴(a24d087) → 배터리 폴링 **5회 반복**(64b8832→4849790→20d79e9→d44215e) → 배경 순환(7424cd6, Super+W) + 애니 배경 풀 교체 8회 → pdf-open/fcitx5/zathura(f10bed6) → diagnose.sh(7458f7c) → fastfetch Mumei 브랜딩(7b3f3d0)
7. **철회된 기능들**: 드롭다운 터미널(`d39564d remove: SUPER+grave dropdown terminal`), 스크래치패드/`magic` special workspace (1b7010a에서 제거), `epic-mouse-v1` 디바이스 룰 (유령, 제거됨)

**시사점:**
- 직접 작성 + 수정한 것 = 키바인드/한글 IME/실기기 보정/waybar 스크립트/테마. **외부에서 가져온 것 = hyprland.lua 기본 골격(typecraft + 공식 예제), 현재 구조**
- **방향성의 되돌림**: 스크래치패드/드롭다운을 "과거 시도 후 사용자 확정으로 제거"했음 → 이번 브리프(section 15-16)에서 scratchpad를 "핵심 workflow"로 재요청 → **이전 결정과 충돌. 승인 필요 (아래 "오픈 이슈")**
- 배터리 폴링 history가 "1초로 낮춰라(성능)" → "0.1초로 높여라(즉시성)"로 **정반대 왕복** → 현재 0.1초 폴링 상태 (성능 원칙과 충돌)

---

## 3. Hyprland Analysis (`hypr/hyprland.lua`, 407줄)

전체가 공식 예제(`/usr/share/hypr/hyprland.lua`)의 골격 그대로이고, 사용한 **모든 `hl.*` API는 v0.56 스텁에서 공식 지원 확인**됨. `hyprctl reload` = `ok`, configProvider: lua.

| 섹션 | 현재 내용 | 평가 | 근거 |
|---|---|---|---|
| **MONITOR** (25-30) | eDP-1, preferred, scale 1.25 | **KEEP** | 실기기 확인 (1920x1080@60, scale 1.25) |
| **PROGRAMS** (38-40) | kitty / thunar / rofi -show drun | **KEEP** | thunar는 이미 GDK 오버라이드 제거됨 (정리 완료) |
| **AUTOSTART** (56-63) | swayosd-server, hyprpaper+waybar+swaync+hypridle, cliphist watcher, fcitx5, **Brave crash state sed hack** | **KEEP(조건부)** | Brave sed hack(l.61)은 실기기 workaround. 인라인이라 가독성 낮음 → 스크립트 분리 CHANGE 후보 |
| **ENV** (74-82) | XCURSOR/HYPRCURSOR 24, fcitx IME env 3종, GDK_SCALE=1/GDK_DPI_SCALE=0.7 | **KEEP** | IME env는 한글 필수. GDK 보정은 실기기 검증됨 (기록상 고생 끝에 확정된 값) |
| **PERMISSIONS** (100-108) | 전부 주석 처리 | **REMOVE(주석 정리)** | 죽은 코드. permission은 첫 실행시만 적용 |
| **LOOK AND FEEL** (116-163) | Dracula 보더 그라디언트, gaps 5/20, rounding 10, shadow, blur(3/1/0.25) | **KEEP** | 이전 계획서에서 확정된 Dracula 브랜딩 복원 결과 |
| **Curves/Animations** (166-192) | 기본 5개 + 커스텀 smooth/gentle/easy(spring) + 애니 15개 (workspaces slidevert 등) | **CHANGE** | workspace slidevert + popin은 화려하지만 성능 비용. 실사용 후 트리밍 |
| **Workspace rules 주석** (197-210) | 전부 주석 | **REMOVE** | 죽은 코드 |
| **Layouts** (213-231) | dwindle(preserve_split) + master + **scrolling** | **CHANGE** | `scrolling`은 실제 사용 안 함 (dwindle↔master 토글만). master는 토글 스크립트가 참조하므로 유지 |
| **MISC** (237-243) | force_default_wallpaper=-1, disable logo, disable splash | **KEEP** | splash는 실제 오류 원인이었음(878a63b) |
| **INPUT** (250-273) | us 레이아웃, follow_mouse 1, touchpad 자연스크롤 + tap lrm, 3손가락 제스처 | **KEEP** | 한글은 fcitx5가 담당 (kb_layout us가 정상). 제스처는 공식 hl.gesture |
| **KEYBINDS** (279-344) | Super+Q/C/M/E/V/F/Space/P, Print/Shift+S/Alt+L/Shift+T/I/B/W/Shift+M/D, HJKL focus/swap, 1-0 워크스페이스, 마우스 드래그, 미디어키(swayosd/playerctl) | **KEEP**(재구성) | 키 충돌 없음. 단 workspace=10개가 "개수만" 존재, 의미 없음 |
| **WINDOW RULES** (356-405) | suppress-maximize(전역), fix-xwayland-drags, waybar-blur(layer), **fcitx-pseudo(class ^fcitx$)** , rofi-dracula | **CHANGE** | `fcitx-pseudo`는 실기기 `hyprctl clients`에 매칭 창 0건 → **죽은 룰** (추측성 클래스). suppress-maximize 전역 매칭(`.*`)은 의도 재확인 필요 |

**핵심 발견 — 이전 계획서와의 검증 일치**: docs/hyprland-dracula-persona-plan.md가 계획한 작업 1-9 (Dracula 보더/섀도우/vibrancy, 죽은 룰 제거, GDK 단일화, 배경 일원화)는 **이미 커밋으로 반영 완료**됨. 현재 hyprland.lua에는 해당 계획의 성과가 남아 있고, 계획서가 제거하려던 잔재(epic-mouse, magic, dropdown, hyprland-run)도 실제로 없음.

---

## 4. Other Configuration Analysis

### hypridle.conf (14줄) — **KEEP**
300초 잠금 → 600초 절전. 공식 `.conf` 형식 그대로, 동작 검증됨. listener 2개만으로 단순·명확.

### hyprlock.conf (81줄) — **KEEP + CHANGE(경미)**
Dracula 시계/날짜/입력창. l.47-56 **"Status word" label이 `text = ` 빈 값 = 죽은 요소** → REMOVE. 배경 경로는 `~` 스타일. 잠금 직후 적용되는 구조.

### hyprpaper.conf (6줄) — **KEEP + CHANGE(경미)**
`path = /home/hoco30/.config/backgrounds/...` **하드코딩 절대경로**. cycle_wallpaper.sh가 이 **tracked 파일을 sed로 직접 수정** → git이 매번 dirty해지고, 커밋으로 동기화하는 구조 (caf28f7이 그 사례). 변경 안전성 낮음.

### hyprlauncher.conf / hyprtoolkit.conf — **KEEP(보류)**
설치 패키지에 공식 샘플/문서가 안 딸려 있어 키 검증 불가. **hyprlauncher 데몬은 실행 중**(pid 확인)이지만 launcher는 rofi임 → 용도 모호. 드문 사용이므로 당분간 유지 후 사용자 결정.

### waybar/config (97줄) — **CHANGE (검증된 문제 3건)**
- **`disable-scroll`/`warp-on-scroll`**: waybar 0.15.0 man(waybar-hyprland-workspaces(5)) 공식 옵션 목록에 **없음** → undocumented option (원칙 위반). `all-outputs`/`active-only`는 존재 확인.
- **`battery.sh`가 0.1초 무한 폴링 + `restart-interval`(스크립트가 안 죽으므로 무의미)** → 지속 CPU 소모. 역사적으로 "0.1초가 busy-loop"라며 1초로 내렸다가 즉시성 때문에 되돌린 상태. → CHANGE 후보 (공식 `battery` 모듈 + udev 이벤트, 또는 폴링 간격 현실화)
- 모듈 구성은 합리적 (workspaces | media | idle/cpu/battery/pulse/network/bt/tray/clock). **KEEP** 코어, CPU/성능 부분만 CHANGE.

### waybar/network.sh (76줄) — **REMOVE(수리) 최우선 — 실제 버그**
l.58: `PASSWORD=$($ROFI_BIN -dmenu -password ...` — **변수명이 깨진 채 하드코딩**됨. `bash -n`은 통과하지만 실행 시 "command not found" → **비밀번호 프롬프트가 절대 안 뜸 = 보안 WiFi 연결 불가**. 이전 커밋(ff25d80, 389e2da)에서 패스워드 프롬프트를 고치려던 흔적. 유일한 실사용 브레이킹 버그.

### waybar/battery.sh / bluetooth.py / mediaplayer.py — **CHANGE / KEEP / KEEP**
battery.sh: 위 참조. bluetooth.py: rfkill/bluetoothctl 정상. mediaplayer.py: `wcwidth` 파이썬 모듈 설치 확인됨(동작).

### waybar/style.css — **KEEP**
Dracula 플로팅 바, 모듈별 색상 클래스 모두 사용됨. 깔끔.

### rofi/config.rasi — **CHANGE**
rofi 2.0.0: `-dump-config` 기준 공식 옵션은 **`modes`** 인데 설정은 구형 **`modi`** 사용 (deprecated). 나머지 테마(`window/inputbar/listview/element`)는 유효. `transparency: "real"`도 rofi 2.0에서 유효 여부 재확인 대상.

### kitty.conf — **KEEP**
`background_opacity 0.85` + Hyprland blur 연동. 공식 옵션만 사용. Dracula include.

### zsh/zshrc — **KEEP + CHANGE(경미)**
l.30 `alias ls='ls --color=auto'`가 l.48 `alias ls='eza ...'`로 덮어써짐 — **죽은 줄** REMOVE. 하드코딩 `/home/hoco30/.local/bin` PATH. 나머지(compinit, fzf --zsh, zoxide, CORRECT)는 공식 방식.

### install.sh — **CHANGE(후순위, Phase 10)**
- **실제 설치 상태와 불일치**: 실제는 디렉터리 심링크, 스크립트는 파일 단위 + **swayosd 미연결** (진단 스크립트가 `~/.config/swayosd/config.toml` 검사하는데 설치 안 함)
- backup/idempotency/에러처리 부족 (ln -sf만으로 덮어씀)
- fcitx5를 디렉터리 심링크하면 런타임이 repo를 오염 (아래)

### diagnose.sh (중복 2개) — **REMOVE(중복 해소)**
루트 `diagnose.sh`는 **삭제된 `toggle_term.sh`를 참조** (STALE), `hypr/diagnose.sh`는 **없는 `waybar/config.jsonc`를 참조** (파일명은 `config`). 둘 다 수리 또는 단일화 필요.

### fcitx5/ — **CHANGE**
`hangul.conf`가 **루트와 conf/ 두 곳에 중복**. 디렉터리 심링크 상태라 fcitx5가 런타임에 `profile`, `conf/hangul.conf`, `conf/cached_layouts`(94KB, gitignore)를 **repo 안에 직접 기록** → repo 오염 구조. install.sh는 `config`만 링크 → **설치 스크립트와 실기기 상태 이중 구조**.

### swaync / swayosd / zathura / brave / starship / fastfetch / gtk-3.0 — **KEEP**
모두 공식 형식, Dracula 일관. `swaync/config.json`에 `$schema` 참조 포함(공식 방식).

### kdeglobals / Trolltech.conf / xsettingsd — **KEEP(설명 필요)**
Plasma 잔재처럼 보이지만, `QT_QPA_PLATFORMTHEME=kde`(hyprland.lua:80) 때문에 Qt 앱 어두운 테마에 **실제 사용 중**. 무단 삭제 시 Qt 앱이 밝은 기본 테마로 회귀. GTK는 `gtkrc`/`gtk-3.0`+xsettingsd 경로.

### wsl/ — **REMOVE 후보**
WSL 전용 레거시(.inputrc, wsl.conf, setup.sh). 현 머신(EndeavourOS 네이티브)에 무관. git history에 남으므로 삭제 안전.

### backgrounds/ — **KEEP**
anime-* 20종(gitignore), 구형 7종(arch-rainbow 등, 미사용). 게임 무관. 순환 풀은 유지하되 구형 비애니 7종은 Phase 9에서 정리 후보.

---

## 5. KEEP / CHANGE / REMOVE / NEW 요약

**KEEP (현재 가치 있음)**
- hyprland.lua: monitor/env/IME/gaps/Dracula 컬러/blur/shadow/keybind 코어/misc/gesture/touchpad
- hypridle.conf, hyprlock.conf(죽은 label 제외), hyprpaper.conf(경로 정리 후)
- waybar: 모듈 구성 + style.css + bluetooth.py + mediaplayer.py
- kitty, rofi 테마(키는 수정), zathura, swaync, swayosd, starship, fastfetch, fcitx5 설정값, gtk-3.0, kdeglobals+Trolltech+xsettingsd
- scripts/(학습+복구), backgrounds/(anime 풀)

**CHANGE (목적 좋음, 수정 필요)**
- waybar/config: `disable-scroll`/`warp-on-scroll` 제거 (undocumented)
- waybar/battery.sh: 0.1초 폴링 → 공식 battery 모듈 또는 합리적 폴링
- waybar/network.sh l.58: **깨진 변수 수리 (우선순위 1)**
- rofi: `modi` → `modes`
- hyprland.lua: scrolling 레이아웃 제거, fcitx-pseudo 룰 검증, Brave sed → 스크립트 분리, dead 주석 정리
- fcitx5: 중복 파일, 디렉터리 심링크 정책
- diagnose.sh 2개 단일화
- zshrc: 죽은 ls alias
- hyprlock.conf: 빈 label 제거

**REMOVE**
- wsl/ (레거시), 루트 diagnose.sh(중복), dead 주석 블록들, 구형 배경 비애니 이미지(Phase 9), hyprland-run/magic/dropdown 잔재(이미 없음 — 확인만)

**NEW**
- **Scratchpad terminal** (special workspace, `Super + `` ` ``) — 단, **이전 확정(재추가 금지)과 충돌 → 승인 필요**
- **Workspace 지정 정책** (1=DEV, 2=WEB, 3=GENERAL + 자동 배치 window rules)
- Lua module 구조 (core/workflow/appearance)
- 네이밍된 workspace + waybar format 연동
- (선택) 공식 검증용 `waybar -c <config>` 커스텀 실행 확인 절차

---

## 6. Current Workflow (현재 설정이 전제하는 것)

- **런처 중심 일반 데스크톱**: Super+Space → rofi, 모든 앱을 수동으로 띄움
- **워크스페이스 철학 없음**: 1~10이 "개수로만" 존재, 현재 1번만 사용 중. 특정 앱→워크스페이스 자동 배치 규칙 없음
- **마우스 병행**: Super+LMB/RMB 드래그/리사이즈, 마우스휠 워크스페이스 전환
- **시각 중심**: 배경 순환(Super+W), splash 제거, Dracula 브랜딩, Mumei fastfetch → "Dracula+애니"가 정체성
- **멀티미디어**: waybar 중앙에 미디어, Super+Shift+M 스포티파이
- **한글 입력**: fcitx5 (Hangul 키)
- 개발/공부/웹이 **같은 공간**에 섞임, scratchpad 없음

## 7. Target Workflow (지향 방향)

1. **워크스페이스 = 역할 분리**: `1 DEV`(kitty+neovim+python), `2 WEB`(Brave), `3 GENERAL`(파일관리/문서/Obsidian)
2. **Scratchpad**: Super+`로 상시 토글 가능한 특수 워크스페이스 터미널 (빠른 명령/한 번 쓰기용)
3. **자동 배치**: window rule로 kitty→DEV, Brave→WEB, 특정 유틸→floating, scratchpad 터미널→special
4. **키보드 우선**: 기존 Super 기반 체계 유지, 충돌 없음 확인
5. **UI 최소화**: waybar 모듈 중 실제 쓰는 것만, 성능 과소모(0.1초 폴링) 제거
6. **Dracula는 위에 얹히는 것**: workflow가 먼저, 색/애니메이션은 조정 대상

---

## 8. Problems ("내 것 같지 않다"의 구조적 원인)

1. **hyprland.lua가 공식 예제 골격 그대로** — "MY PROGRAMS/LOOK AND FEEL" 주석까지 예제 템플릿. 개인 workflow를 표현하는 구조 아님
2. **워크스페이스가 빈 껍데기** — 의미 없는 10개, 자동 배치 없음
3. **스크래치패드가 없고**, 이전 결정(제거 확정)이 현재 요구(핵심 workflow)와 충돌
4. **정체성이 시각에 집중** (배경 20종 순환/애니 브랜딩), workflow 레이어는 제네릭
5. **기능이 레이어로 누적** — cliphist/wifi/배터리/배경 등 57커밋이 일관 설계 없이 축적 (배터리 폴링 5회 왕복이 대표)
6. **실제 상태 ≠ 저장소 상태** — install.sh는 파일 단위, 실기기는 디렉터리 심링크, swayosd 미연결
7. **tracked 파일이 런타임에 오염** — fcitx5 디렉터리, cycle_wallpaper.sh의 sed
8. **undocumented/deprecated 옵션** — waybar scroll 옵션, rofi `modi`
9. **하드코딩 /home/hoco30** — hyprpaper.conf, cycle_wallpaper.sh, zshrc PATH, pdf-open.sh
10. **실제 버그 1건** — network.sh 비밀번호 프롬프트 변수 깨짐
11. **레거시/중복** — wsl/, diagnose.sh 2개, fcitx5 중복, 죽은 주석

---

## 9. Proposed Architecture

분석 결과를 반영한 구조 (공식 `require()` 메커니즘 사용 — 상대경로, `.lua` 생략, 모듈별 분리 스코프):

```
hypr/
├── hyprland.lua            # entry: require로 조립 (50줄 미만)
├── core/
│   ├── monitor.lua         # eDP-1 설정
│   ├── input.lua           # 키보드/터치패드/제스처
│   ├── environment.lua     # env vars (fcitx, GDK, cursor)
│   └── autostart.lua       # hyprland.start 핸들러 (Brave hack 분리 포함)
├── workflow/
│   ├── keybinds.lua        # 전체 바인드 (스크래치패드 포함)
│   ├── workspaces.lua      # 1=DEV 2=WEB 3=GENERAL + rule 연동
│   ├── windows.lua         # window/layer rules
│   └── scratchpad.lua      # special workspace 정의 (승인 시)
├── appearance/
│   ├── theme.lua           # Dracula 팔레트 공유 테이블
│   ├── decoration.lua      # border/blur/shadow/gaps
│   └── animation.lua       # 커브 + 애니메이션
├── hypridle.conf           # 그대로 (.conf)
├── hyprlock.conf           # 죽은 label만 정리 (.conf)
├── hyprpaper.conf          # 경로 정책 정리 (.conf)
├── hyprlauncher.conf       # 그대로 (.conf)
├── hyprtoolkit.conf        # 그대로 (.conf)
└── *.sh                    # cycle_wallpaper / toggle_layout / pdf-open (경로 포터블화)
```

- 주의: `require` 모듈 분리는 **Phase 7에서만** 수행 (미리 분리하지 않음)
- `core/workflow/appearance` 구분은 사용자 예시 구조를 수용한 것이며, 내용은 분석에 근거
- 기존 `.conf` 파일은 그대로 유지 (원칙 #10 준수)

---

## 10. Phase Plan

### Phase 0 — 현재 상태 보존
- **목표**: 작업 시작 전 rollback 기준점 확보
- **변경**: 파일 없음. `/tmp/opencode/`에 hyprland.lua·waybar/config·README·install.sh 등 사본 + `hyprctl reload` 동작 확인 + 현재 배경/바인드/모니터 스냅샷 기록
- **완료조건**: git status clean + reload ok + 스냅샷 존재

### Phase 1 — 현재 configuration 분석·정리 (동작 변화 없음)
- **목표**: dead 주석/주석처리된 예제 블록(permission, workspace-rule, epic-mouse 주석) 제거. 죽은 `fcitx-pseudo` 룰 검증·제거. `scrolling` 레이아웃 블록 제거(master는 유지)
- **완료조건**: `hyprctl reload` ok, `hyprctl binds/clients` 불변, diff 최소

### Phase 2 — Workflow 설계 문서화
- **목표**: `docs/workflow.md` 작성 — 앱 분류(KEEP: kitty/nvim/brave/thunar/obsidian, floating 유틸, scratchpad 적합군). 코드 변경 없음
- **근거**: 분석 기반, 게임 제외

### Phase 3 — Workspace 설계 (코드는 Phase 6/7에서)
- **목표**: 1=DEV, 2=WEB, 3=GENERAL 확정 (사용자 승인 필수). 게임 ws 없음
- **완료조건**: 문서화 + 승인. hyprland.lua는 10개→3개 논리 정의로 (바인드 루프는 유지)

### Phase 4 — Keybind 설계
- **목표**: 기존 바인드 유지, 충돌 점검(`hyprctl binds`와 대조). **Super+` 추가(승인 시)**. README 키맵과 불일치 재확인
- **위험**: Super+`가 다른 것과 충돌 여부 — 확인 후 배정

### Phase 5 — Scratchpad 설계 (**승인 필요**, 이전 확정과 충돌)
- **목표**: 공식 API `hl.dsp.workspace.toggle_special("scratch")` + `hl.dsp.window.move({ workspace = "special:scratch" })` + window_rule(float+size)로 구현. 비공식 hack 없음
- **근거**: hl.meta.lua에 `dsp.workspace.toggle_special`/`dsp.window.move` 공식 존재 확인 완료
- **위험/rollback**: 단일 커밋, 제거 시 이전 상태로 복원
- **완료조건**: Super+` 토글 왕복 동작, special workspace가 waybar에 표시

### Phase 6 — Window rules
- **목표**: **실기기 클래스 확인 후** (`hyprctl clients -j`) kitty→DEV, brave→WEB, zathura/obsidian/pavucontrol/rofi→floating 등 자동 배치. 추측 클래스 금지
- **완료조건**: 앱 실행 시 지정 워크스페이스 자동 진입 확인

### Phase 7 — Lua module 분리
- **목표**: hyprland.lua를 core/workflow/appearance 모듈로 `require` 분리 (구조는 §9)
- **근거**: 공식 예제 "You can (and should!!) split", `require` 상대경로·별도 스코프 공식 지원
- **위험**: require 경로 오류 → reload 실패. 1모듈씩 분리→reload→검증
- **완료조건**: reload ok, 바인드/옵션 수 불변, 각 모듈 역할 명확

### Phase 8 — Waybar 정리
- **목표**: `disable-scroll`/`warp-on-scroll` 제거(undocumented), battery 0.1초 폴링 개선(공식 `battery` 모듈 또는 현실적 폴링 — 실사용 확인 후), **network.sh l.58 버그 수리**
- **완료조건**: waybar 실행 로그에 에러 0건, WiFi 보안 연결 실제 성공, CPU 유휴 상승 없음

### Phase 9 — Appearance 정리
- **목표**: hyprlock 빈 label 제거, 구형 배경 정리(승인 시), 애니메이션 속도/블러 성능 측정 후 불필요 효과 제거, hyprpaper 경로 포터블화
- **위험**: 시각 변화 → 스크린샷 비교

### Phase 10 — install.sh 정리 (후순위)
- **목표**: 실제 상태(디렉터리 심링크 방식)와 일치, swayosd 추가, backup/에러처리, 포터블 경로($HOME 기반). fcitx5 런타임 오염 정책(디렉터리 심링크 유지 or 설치본 분리) 결정
- **완료조건**: 임시 디렉터리에 dry-run으로 심링크 검증

### Phase 11 — 실사용 테스트
- **목표**: 최소 1주 실사용. 바인드/워크스페이스/스크래치패드/자동배치 피드백. WM 교체 판단 자료 수집

### Phase 12 — README 및 최종 정리
- **목표**: workflow 철학(키보드 중심/워크스페이스 역할/스크래치패드/공식 방식 우선/Dracula는 시각 아이덴티티) 중심 README 재작성. diagnose.sh 단일화, 레거시(wsl/ 등) 정리 승인
- **완료조건**: README 키맵이 `hyprctl binds`와 100% 일치, git log가 기능 단위로 깔끔

**각 Phase 종료 시**: `hyprctl reload`(또는 해당 프로그램 검증) → 검증 → 기능 단위 commit → 다음 Phase. 예: `refactor(hypr): split lua into modules`, `feat(hypr): add scratchpad workflow`.

---

## 오픈 이슈 (승인 필요)

1. **스크래치패드 재도입** — docs/hyprland-dracula-persona-plan.md l.52-53에 "드롭다운 터미널 제외 확정 (과거 직접 제거, 재추가 금지)", l.53 "스크래치패드 전부 삭제 확정"이 기록되어 있으나, 이번 브리프(§15-16)는 scratchpad를 핵심 workflow로 요청합니다. **어느 쪽을 따를지 결정 필요.** (권장: 새 special workspace 기반 scratchpad는 과거 `Super+` dropdown과 구현이 다르므로, Phase 5에서 별도 시도 후 실사용 판단)
2. **워크스페이스 3개 체계** (§14) — 1=DEV/2=WEB/3=GENERAL 확정 여부
3. **배터리 모듈 정책** — 즉시성(0.1초 폴링) vs 성능. 공식 `battery` 모듈로 갈지 결정
4. **hyprlauncher** — 데몬 실행 중이지만 rofi가 launcher. 유지/제거 결정

---

## 최종 판단 (§29)

**"현재 repository를 유지하면서 Hyprland를 재설계하는 것이 WM을 교체하는 것보다 합리적이다." — 예.**

근거:
- **Repository**: 85커밋의 실사용 검증된 설정이 `agent/publish-hyprland-dotfiles` 브랜치에 온전히 있고, git history가 WSL→EndeavourOS→Hyprland로의 실사용 진화 그 자체. 폐기 시 검증된 한글 IME·스케일 보정·테마·스크립트가 모두 소실
- **Git history**: typecraft 유래라도 이후 57커밋의 실기기 보정(Dracula 브랜딩, 배터리, wifi, 배경, 진단)이 누적됨. 이건 다른 dotfiles에 없는 개인 데이터
- **Configuration**: 문제는 WM 모델이 아니라 (a) 공식 예제 골격 유지, (b) 워크스페이스/스크래치패드 부재, (c) 옵션/스크립트 오류, (d) 성능 과소모 — 전부 리팩터링으로 해결 가능
- **Workflow**: 요구 기능(특수 워크스페이스, window rule 자동배치, 제스처, 모듈 분리)이 **현재 버전에서 전부 공식 지원 확인됨** (stubs 파일 검증)
- **공식 문서**: v0.56에서 Lua가 공식 config 언어이고 설치된 예제가 현재 설정과 동일 골격 → 마이그레이션 리스크가 사실상 0. WM 교체는 이 장점을 전부 버리는 것
- **성능**: battery 0.1초 폴링 등 문제는 config 수준이며 Hyprland 컴포저 수준의 부하 아님

**결론**: Hyprland(현 버전, Lua)를 workflow 중심으로 재설계하고 실사용 결과를 재평가하는 것이 합리적. Phase 11 실사용 이후에만 WM 비교 판단.

---

보고는 여기까지입니다. **파일은 하나도 수정하지 않았습니다.** 승인해 주시면 Phase 0부터 한 단계씩 진행하겠습니다. 특히 **오픈 이슈 1(스크래치패드 재도입)**에 대한 결정을 먼저 부탁드립니다.
