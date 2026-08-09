# Hyprland Workflow 설계 문서

> 상태: **설계 초안 (Phase 2)** — 코드 변경 없음. 결론은 내리지 않았으며, 확정이 필요한 항목은 "사용자 결정 필요"로 표시.
> 기준점: Phase 0 snapshot (`~/dotfiles-phase0-snapshot-20260809-231006`), Phase 1 종료 시점의 runtime.

---

## 0. 이 문서의 근거 데이터 (2026-08-09 런타임)

`hyprctl clients -j` 관측 결과 (Phase 1 종료 시점):

| ws | class | floating | 비고 |
|----|-------|----------|------|
| 1 | kitty | false | 2개 |
| 2 | brave-browser | false | |
| 2 | kitty | false | Brave와 같은 ws |
| 3 | Spotify | false | |
| 4 | kitty | false | |

- 사용 중인 workspace: **1~4 (4개)**, 전부 tiled, fullscreen 없음
- special workspace: 없음
- layout: dwindle (기본)

git 기록상 과거 특수 workspace/드롭다운 이력:
- `904810a` 드롭다운 터미널 추가 (Super+grave) → `d39564d` **바인딩 제거**
- `1b7010a` 스크래치패드/`magic` special workspace 제거 (문서 기록)
- → 스크래치패드 계열은 **한 차례 도입 후 두 차례 제거된 이력**이 있음

---

## 1. Workspace 철학

### ✅ 결정 (2026-08-09, 사용자 확정 — B안)

| ws | 역할 | 예상 앱 |
|----|------|---------|
| 1 | DEV | kitty (Neovim, Python, 터미널 작업) |
| 2 | WEB | Brave (검색, 문서, 온라인 자료) |
| 3 | GENERAL | Thunar, Obsidian, PDF(zathura), 일반 GUI |
| 4 | MEDIA | Spotify 등 미디어 |
| 5~10 | 자유 | 역할 밖/임시/오버플로 (자동 배치 대상 아님) |

- 현재 사용 패턴을 억지로 3개로 압축하지 않는다.
- 이번 결정은 **역할 정의만 확정**한 것이며, 자동 배치 규칙·앱별 workspace 고정은 아직 결정하지 않는다 (항목 3·5 참고).
- 이 결정의 근거가 된 분석은 아래와 같다.

### 분석 근거 (결정 과정)

**관측 근거로 확인된 사실:**
1. 현재 **4개 workspace를 사용 중** (ws1~4) — 3역할 모델은 사용 영역 축소.
2. ws2에 **kitty와 brave-browser 공존** — 웹 작업 중 터미널을 같이 쓰는 패턴이 실재.
3. ws3에 **Spotify(미디어)** 존재 — 미디어가 GENERAL과 분리될 필요가 있음을 뒷받침.
4. kitty는 DEV/WEB 어디에도 존재 가능한 다목적 앱 — 자동 배치 대상으로는 별도 논의 필요.

**B안 선택 이유:**
- 실사용 4ws와 일치, Spotify를 GENERAL에서 분리해 상시 미디어가 작업 공간을 오염하지 않음.
- ws5~10을 "자유"로 명시해 역할 밖 창(예외/임시)이 들어갈 곳 확보.
- 행동 변화 최소화.

**유의점 (확정 후에도 남는 것):**
- 역할은 현재 상태로는 "라벨"에 불과 — 실제 효력은 자동 배치(§3)와 연동될 때 생김.
- 자동 배치를 도입하지 않으면 역할 정의는 사용자 습관 지침 역할만 함.

### ✅ 미디어(MEDIA) 정의 (2026-08-09, 사용자 확정 — A안)

- MEDIA(ws4)는 **현재 Spotify 전용**으로 정의한다.
- Spotify는 ws4(MEDIA)에 배치한다.
- **tiled 기본 유지** (현재 실사용과 일치).
- 영상 등 다른 미디어 앱은 지금 규칙에 포함하지 않는다 — 향후 실제 사용 시 runtime class 확인 후 별도 결정.
- fullscreen은 기존 `Super+F`를 그대로 사용.
- 이 결정은 역할 정의만 확정한 것이며, **Spotify 자동 배치 규칙/window rule 코드는 아직 작성하지 않는다** (항목 3·5에서 논의).

---

## 2. Scratchpad

### ✅ 결정 (2026-08-09, 사용자 확정 — D안)

**재도입한다. 단, 특수 workspace 방식(A)으로만 구현한다.**
- 과거 제거된 dropdown 방식(B)은 재도입하지 않는다.
- **역할 한정**:
  - GUI 작업 중 잠깐 필요한 명령어 실행
  - 일회성/짧은 작업
  - 일반 개발용 터미널을 대체하지 않음
  - DEV/WEB/GENERAL/MEDIA workspace의 터미널을 대체하지 않음
  - 장시간 사용하는 터미널은 기존 workspace에서 사용
- **일반 터미널 workflow와 Scratchpad workflow를 명확히 분리**
- **검증 규칙 (D안)**:
  - 실사용하면서 실사용 가치 확인
  - 사용 빈도가 낮거나 기존 workspace 터미널로 충분하면 제거
  - 일정 기간 실사용 후 유지 여부 재판단
  - "일단 넣었으니 유지"하지 않는다
- **미결정**: 키 (항목 4에서 결정), 구현 시점 (설계 확정 후)

### 분석 근거 (결정 과정)

**배경/이력**: 과거 드롭다운 터미널(Super+grave, `d39564d` 제거)과 `magic` special workspace(`1b7010a` 제거)가 도입→제거됨. 재도입은 이전 확정(제거)과 충돌하므로 검증 규칙을 병기.

**과거 dropdown vs 특수 workspace 방식 비교**

| 항목 | 과거 dropdown | 특수 workspace 방식 (채택) |
|------|--------------|--------------------------|
| 구현 | window rule(float/pin/move/size) + `toggle_term.sh` | `toggle_special` 내장 + (구현 시) 전용 rule |
| 창 수 | 1개 가정 | 여러 창 가능, 내용 유지 |
| 현재 ws 영향 | 같은 ws 안에서 오버레이로 덮음 | 현재 ws를 건드리지 않고 별도 공간 |
| 리스크 | 특수 ws 내용이 계속 남아 "숨은 창" | 열어놓고 잊으면 특수 ws에 창이 쌓임 |

**장단점**: 장점 — "빠른 명령용 임시 공간"으로 고정되면 ws 순회에 포함되지 않아 집중 유지에 유리. 단점 — 사용 빈도가 낮으면 dead key + 숨은 창 부작용 (과거 `magic` 전례). 빈도는 관측 기간 기록이 없어 실사용 검증 필요 → 이것이 D안 검증 규칙의 근거.

### ✅ 키 결정 (2026-08-09, 사용자 확정 — Super+grave)

- Scratchpad 토글 키: **`Super+grave` (`Super+`` `)**
- 의미 정리:
  - `Super+Q` = 일반 터미널
  - `Super+grave` = 임시/빠른 작업용 Scratchpad
  - Scratchpad는 일반 개발 터미널을 대체하지 않음
- **Super+S는 사용하지 않는다** — 과거 `magic` special workspace에서 쓰였고 현재 workflow와 혼동 가능.
- **Super+T도 사용하지 않는다** — Super+Q와 terminal 의미가 겹치고, Shift+T(레이아웃 전환) 바인드와 가까워 혼동 가능.
- 이 단계에서는 **키만 확정** — 실제 keybind/scratchpad 코드는 아직 수정하지 않음 (구현은 설계 확정 후).

---

## 3. 자동 배치 (window rule) — 후보 분석

> 원칙: window class는 **runtime `hyprctl clients -j` 관측만** 근거로 한다. 미관측 앱은 "미확인"으로 명시.

### ✅ 결정 (2026-08-09, 사용자 확정 — 항목 5)

| 앱 | class | 배치 | 상태 |
|----|-------|------|------|
| Brave | `brave-browser` (확인) | **WEB(2) 자동 배치** | ✅ 확정 |
| Spotify | `Spotify` (확인) | **MEDIA(4) 자동 배치** | ✅ 확정 |
| kitty | `kitty` (확인) | **자동 배치 안 함** (다목적) | ✅ 확정 |
| Thunar / Obsidian / Zathura / Pavucontrol | 미확인 | **지금은 안 함** — 실행해 class 확인 후 별도 결정 | ⏸ 관측 대기 |
| Rofi | 일시 창 | **자동 배치 안 함** | ✅ 확정 |

- 이 결정은 **배치 대상만 확정**한 것 — window rule 코드는 아직 작성하지 않음 (설계 확정 후).
- 규칙 작성 시 point: Brave/Spotify 모두 시작/실행 시 해당 ws로 이동. kitty는 현재 동작(열린 ws에 유지) 그대로.

### ✅ 관측 기록 (2026-08-09, 항목 6 절차 C — 실제 실행 + `hyprctl clients -j`)

| 앱 | 실행 방법 | runtime class (initialClass) | 판정 |
|----|-----------|------------------------------|------|
| Thunar | `thunar` 실행 | `thunar` (`thunar`) | GENERAL(3) |
| Zathura | `zathura` 실행 | `org.pwmt.zathura` (`org.pwmt.zathura`) | GENERAL(3) |
| Pavucontrol | `pavucontrol` 실행 | `org.pulseaudio.pavucontrol` (`org.pulseaudio.pavucontrol`) | floating |
| Obsidian | 실행 안 함 (관측 대상 제외) | — | — |

- 관측 후 세 창은 닫아 작업공간을 원상 복구함.
- 위 판정(Thunar/Zathura→GENERAL(3), Pavucontrol→floating)은 확정된 배치 기준이며, **window rule 코드는 아직 작성하지 않음** — 설계 확정 후 작성.

### ✅ 2026-08-10 장기 결정 — 자동 배치 위치 강제 제거 (실사용 파악 결과)

**배경**: 자동 배치 규칙(Brave→2, Spotify→4, Thunar→3, Zathura→3)을 적용했으나, 실사용 질문 파악 결과 사용자 흐름과 정면 충돌(앱이 "지금 있는 ws"에 열리길 원함)이 확인됨.

**결정**: **위치 강제 규칙 4개를 모두 제거**한다.
- 앱은 열린 위치(현재 ws)에 유지된다.
- ws 모델(1=DEV 2=WEB 3=GENERAL 4=MEDIA)은 **라벨로 유지** — 조직화는 `Super+Shift+N`(창 이동)이 담당.
- **Pavucontrol floating만 유지** — 위치 이동이 아닌 "현재 ws에서 떠 있는 창" 처리라 흐름과 무관.
- kitty는 계속 자동 배치 제외.
- 규칙 재도입 기준: ws당 창 4~5개로 늘거나, ws별 분리 사용 습관이 생겼을 때(데이터로 확인 후).

**장기 근거**: 단일 모니터·4ws·창 1~2개 환경에서 고정 배치의 이점(위치 예측)은 미미하고, 실행 시 컨텍스트 스위치 비용이 매일 발생 → 제거가 장기적으로 유리. 이 결정은 영구적이지 않으며 조건 충족 시 재도입.

### 관측/근거 현황 (결정 이력)

| 앱 | class (관측?) | 배치 후보 | 근거 |
|----|--------------|-----------|------|
| kitty | `kitty` — **확인됨** (ws1·2·4) | DEV? WEB? | 여러 ws에 존재, 단일 고정 배치 시 **오분류 위험** (개발/일반/웹 겸용) |
| Brave | `brave-browser` — **확인됨** (ws2) | WEB(2) | 강한 후보. 단 현재 ws2에 kitty와 공존 중 → Brave만 강제 이동하면 기존 패턴 깨짐 |
| Spotify | `Spotify` — **확인됨** (ws3) | (미디어 전용 ws?) | 요청 목록에 없으나 runtime에서 실존하는 유일한 미디어 앱 — 배치 설계 시 정의 필요 |
| Thunar | `thunar` — **확인됨** (관측 기록 참고) | GENERAL(3) | class `thunar` 확인됨 |
| Obsidian | **제외됨** (사용/설정 근거 없음) | — | 사용하게 되면 그때 class 확인 후 추가 |
| Zathura | `org.pwmt.zathura` — **확인됨** (관측 기록 참고) | GENERAL(3) | class 확인됨 |
| Rofi | **미확인 as window** (루너는 실행 즉시 닫힘) | 배치 무의미 | `rofi-dracula` rule(`^rofi$`)은 기존 설정에 있음. dmenu로 쓰일 때 일시 창 → floating 처리 여부만 논의 가능 |
| Pavucontrol | `org.pulseaudio.pavucontrol` — **확인됨** (관측 기록 참고) | utility → floating | class 확인됨 |

### 분석
- **자동 배치가 확실히 유용한 경우**: Brave→WEB처럼 "역할이 명확하고 한 ws에 고정"되는 앱.
- **위험한 경우**: kitty처럼 다목적 앱 — 모든 kitty를 DEV로 보내면 웹 작업 중 연 kitty가 DEV로 튀어 혼란.
- **미관측 앱은 정의 불가**: Thunar/Obsidian/Zathura/Pavucontrol은 사용 시도 후 class를 확인해야 자동 배치를 설계할 수 있음.
- utility 계열(pavucontrol, blueman-manager 등)은 ws 이동보다 **floating 유지**가 workflow에 유리한지 검토 대상.

### 잠정 방향 → 결정 반영
- 배치할 앱은 "클래스 1개 = ws 1개"가 명확한 것부터 — **Brave(2)·Spotify(4) 확정**.
- 다목적 앱(kitty)은 자동 배치 제외 — **확정**.
- 미확인 앱들(Thunar/Obsidian/Zathura/Pavucontrol)은 **실사용 후 class 확인 → 별도 결정** — 진행 대기 (항목 6).

---

## 4. Keybind 철학

전제: 현재 Super 기반 체계를 유지. bind 추가/변경 없이 **분류만** 한다.

### workflow와 직접 연결되는 bind (현행 그대로)
| 분류 | bind | 대상 |
|------|------|------|
| **Terminal** | `Super+Q` | kitty (기본 터미널) |
| **Launcher** | `Super+space` | rofi (drun) |
| **Workspace 이동** | `Super+0-9` | ws 1-10 |
| **Workspace 간 창 이동** | `Super+Shift+0-9` | 현재 창 → ws N |
| **ws 스크롤** | `Super+mouse_down/up` | ws e+1 / e-1 |
| **Layout 전환** | `Super+Shift+t` | dwindle ↔ master (toggle_window_layout.sh) |
| **Pseudo tiling** | `Super+P` | toggle pseudo |
| **Fullscreen** | `Super+F` | toggle fullscreen |
| **Lock** | `Super+Alt+l` | hyprlock |
| **Screenshot** | `PRINT` / `Super+Shift+S` | hyprshot window / region |
| **Close** | `Super+C` | 창 닫기 |
| **Focus/swap** | `Super+hjkl` / `Super+Shift+hjkl` | 방향 포커스/스왑 |

### 앱 실행 (보조)
`Super+E`(thunar), `Super+b`(brave), `Super+Shift+M`(spotify), `Super+D`(pdf-open), `Super+V`(cliphist), `Super+I`(systemsettings), `Super+W`(배경 순환), `Super+M`(종료)

### 관찰
- workspace 이동/창 이동/포커스/스왑/레이아웃은 **완결된 체계** — 추가·변경 불필요.
- `Super+grave` 포함 **빈 자리가 일부 있음**: grave, Super+R, Super+A, Super+G, Super+N 등 (검증은 `hyprctl binds` 기준). 다만 신규 bind는 이 Phase에서 추가하지 않음.
- 한글 입력(fcitx5)의 Hangul 키와 Super 조합 간 충돌은 현재 없음.

---

## 5. UI와 workflow의 우선순위

### 분석
- 현재 dotfiles의 정체성은 **시각적 요소**(Dracula, 애니 배경 20종 순환, 애니메이션)가 지배적이고, workflow 레이어는 공식 예제 골격 그대로(비교적 제네릭)인 상태.
- workflow 설계는 appearance와 독립적: 배치/ws/키 논리는 색·배경·애니메이션 값과 결합하지 않음 → **순서상 workflow를 먼저 확정하고 appearance를 그 위에 얹는 구조가 자연스럽다**.
- 단, 역방향 영향도 있음: (a) workspace 전환 애니메이션(workspaces leaf, speed 2.5)은 잦은 ws 이동 시 체감 속도에 영향 → workflow(빈번한 ws 전환)가 appearance(애니메이션 속도/끄기)에 제약을 줄 수 있음. (b) 배경 순환/브랜딩은 workflow와 무관해도 사용자 만족도에 기여 → "성능상 제거" 같은 결론은 아님.
- **결론**: "workflow가 먼저, appearance는 그 위"를 원칙으로 하되, appearance 무결정 삭제·최소화를 주장하지 않는다. workflow 변경 시 그 안에서 appearance 조정(예: 애니메이션 속도)을 별도 결정 항목으로 둔다.

### 사용자 결정 필요
- 애니메이션/배경 등 appearance 요소를 workflow 우선으로 조정할지, 현행 유지할지

---

## 6. Known Issues (확인된 repository 문제 — 해결 안 함)

1. **`cycle_wallpaper.sh`가 git tracked 설정을 런타임에 직접 수정**
   - `sed -i`로 `hypr/hyprpaper.conf`와 `hypr/hyprlock.conf`의 `path` 라인을 교체 (Super+W 실행 시).
   - 두 파일은 `~/.config/hypr` → `dotfiles/hypr` 심링크 경유이므로 **tracked 파일이 변경**됨 → `git status`가 dirty해지고, 커밋 시 배경 파일명이 의도와 무관하게 포함될 수 있음.
   - Phase 1에서 실제로 관측됨 (23:15 SUPER+W 실행으로 두 파일의 path 변경, hyprlock.conf diff 오염).
   - 후보 개선 방향(미적용): wallpaper 상태를 tracked 파일 밖으로 분리 / 런타임 적용만 하고 설정 파일은 건드리지 않기 / mutable 파일을 .gitignore / 전용 상태 파일 + reload.
2. (참고) 하드코딩 `/home/hoco30` 경로가 hyprpaper.conf·cycle_wallpaper.sh 등에 존재 — Known Issues로 기록만.

---

## 7. 사용자 결정 필요 항목 요약

| # | 항목 | 상태 |
|---|------|------|
| 1 | Workspace 모델: 1=DEV 2=WEB 3=GENERAL 4=MEDIA, 5~10 자유 | ✅ 결정됨 (B안) |
| 2 | 미디어(Spotify) workspace 정의 — MEDIA(ws4) Spotify 전용, tiled 유지, 영상 등은 관측 후 추가 | ✅ 결정됨 (A안) |
| 3 | Scratchpad 재도입 — ✅ 결정 (D안): 특수 workspace 방식, 역할 한정, 검증 규칙, 키=Super+grave | ✅ 결정됨 |
| 4 | Scratchpad 키 | ✅ 결정됨 (Super+grave) |
| 5 | 자동 배치 대상 — Brave→WEB(2)·Spotify→MEDIA(4) 확정, kitty·Rofi 제외, 미관측 4종 대기 | ✅ 결정됨 → **위치 강제 미적용**(2026-08-10 장기 결정) |
| 6 | 미관측 앱 class 확인 — ✅ 관측 완료: Thunar=`thunar`→GENERAL, Zathura=`org.pwmt.zathura`→GENERAL, Pavucontrol=`org.pulseaudio.pavucontrol`→floating. Obsidian 제외. 규칙 코드는 미작성 | ✅ 결정됨 → **Pavucontrol floating만 적용**(위치 강제 없음) |
| 7 | appearance(애니메이션/배경) 조정 여부 — ✅ 결정: ① ws 전환 애니메이션 **속도 상향**(애니 유지, 응답성 개선) ② blur/성능 **조건부**(성능 문제 관측 시에만 축소) ③ 미사용 animation leaf **축소**(핵심 유지). 유지: Dracula·배경 순환·focus border·opacity 1.0 | ✅ 결정됨 |
| 8 | cycle_wallpaper.sh tracked 파일 오염 해결 — ✅ 결정: **심링크 방식**. hyprpaper.conf·hyprlock.conf의 path를 고정 심링크(예: `~/.config/hypr/current-wallpaper`)로 지정, 순환 시 심링크만 재지정 → tracked 파일 수정 없음. | ✅ 결정됨 |
| 9 | hyprlock.conf "Status word" label 블록 — ✅ 결정: **제거 유지 + 커밋** (commit `d8b485c`). wallpaper path는 HEAD로 원복해 커밋 오염 제외 | ✅ 결정됨 (커밋 d8b485c) |
