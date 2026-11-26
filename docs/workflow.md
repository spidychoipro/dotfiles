# Hyprland Workflow 설계 문서

> 상태: **최종 결정 반영 (2026-11-23)** — 아래 결정사항은 실제로 설정에 반영됨.
> historical 분석 섹션은 결정 과정 기록으로만 남긴다. §7 요약표가 현재 기준.
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

### ✅ 최종 결정 (2026-11-22, 사용자 확정 — 자유 사용)

**워크스페이스는 역할별로 나누지 않는다. 1~10을 자유롭게 쓰고, 앱은 열린 곳에 그대로 둔다.**
- 2026-08-09에는 `1=DEV, 2=WEB, 3=GENERAL, 4=MEDIA` 라벨안(B안)을 확정했으나,
  실제 사용에서 kitty와 Brave가 같은 ws에 공존하는 등 역할 분리가 맞지 않아 철회했다.
- 자동 배치/고정 규칙은 없다 (§3의 2026-08-10 장기 결정과 동일).
- `Super+N` 이동, `Super+Shift+N` 창 이동, `Super+휠` 순환 체계를 유지한다.
- 순환 보강(2026-11-23): 3손가락 가로 스와이프와 `Super+←/→`도 **열려 있는 ws만 순환**한다.
  (`workspace_swipe_create_new=false`, `workspace_swipe_forever=true`, `Super+휠`은 실제 마우스 전용.
  트랙패드 2손가락 스크롤은 Hyprland가 휠 바인드로 전달하지 않아 동작하지 않는다.)
- 아래 분석은 당시 검토 기록으로만 남긴다.

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

### ⛔ 미디어 전용 워크스페이스 정의 철회 (최종)

- 2026-08-09에는 `MEDIA(ws4)=Spotify 전용`으로 정의했으나, 워크스페이스 자유 사용 결정에 따라 철회됐다.
- Spotify 포함 모든 앱은 열린 ws에 그대로 둔다. 전체화면은 `Super+F` 유지.

---

## 2. Scratchpad

### ✅ 최종 결정 (이후 확정 — 삭제 유지)

**재도입하지 않는다. 스크래치패드·드롭다운 터미널 모두 현재 설정에 없다.**
- 2026-08-09에는 `Super+grave` 특수 workspace 방식 재도입(D안)을 결정했으나,
  이후 `docs/hyprland-dracula-persona-plan.md`에서 **드롭다운 터미널 재추가 금지,
  스크래치패드 전부 삭제**로 최종 확정됐다.
- 현재 `hyprland.lua`에는 `grave`, `toggle_special`, `magic` 관련 바인드/룰이 없다.
- 아래 분석 근거는 당시 검토 기록으로만 남긴다.

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

### ⛔ 키 결정 철회 (최종 — 미사용)

- 2026-08-09에는 `Super+grave`로 확정했으나 **최종적으로 채택하지 않았다.**
- 현재 `Super+grave`는 아무 바인드도 없는 빈 키이며, 재추가 금지 대상이다.
- `Super+S`, `Super+T`도 마찬가지로 사용하지 않는다.

---

## 3. 자동 배치 (window rule) — 후보 분석

> 원칙: window class는 **runtime `hyprctl clients -j` 관측만** 근거로 한다. 미관측 앱은 "미확인"으로 명시.
>
> 최종(2026-11-22): 워크스페이스 역할 라벨 자체를 쓰지 않기로 했다. 아래 "✅ 확정" 행은 과거 안이며,
> 현재 유효한 규칙은 **위치 강제 없음 + Pavucontrol floating만 유지**다.

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
- 워크스페이스 역할 라벨은 **두지 않는다** — 조직화는 `Super+Shift+N`(창 이동)이 담당.
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
| **ws 스크롤** | `Super+mouse_down/up` | ws e+1 / e-1 (실제 마우스 휠만) |
| **ws 순환 (키보드)** | `Super+←` / `Super+→` | ws e-1 / e+1, 열려 있는 ws만 왕복 |
| **ws 순환 (트랙패드)** | 3손가락 가로 스와이프 | 열려 있는 ws만 왕복, 빈 ws 안 생김 |
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
- `Super+A`, `Super+G`, `Super+N` 등 빈 자리가 일부 있음 (검증은 `hyprctl binds` 기준). `Super+R`는 분할 전환(66번)으로 사용 중.
  `Super+grave`는 재추가 금지로 **의도적 미사용**. 당시 Phase에서는 신규 bind를 추가하지 않았으나,
  이후 트랙패드 휠 미지원 대안으로 `Super+←/→`(60, 61번)가 사용자 요청으로 추가됨.
  절전 깨우기 `Space`(65번), 분할 방향 전환 `Super+R`(66번)도 이후 요청으로 추가됨.
- 한글 입력(fcitx5)의 Hangul 키와 Super 조합 간 충돌은 현재 없음.

---

## 5. UI와 workflow의 우선순위

### 분석
- 현재 dotfiles의 정체성은 **시각적 요소**(Dracula, 애니 배경 20종 순환, 애니메이션)가 지배적이고, workflow 레이어는 공식 예제 골격 그대로(비교적 제네릭)인 상태.
- workflow 설계는 appearance와 독립적: 배치/ws/키 논리는 색·배경·애니메이션 값과 결합하지 않음 → **순서상 workflow를 먼저 확정하고 appearance를 그 위에 얹는 구조가 자연스럽다**.
- 단, 역방향 영향도 있음: (a) workspace 전환 애니메이션은 잦은 ws 이동 시 체감 속도에 영향 → workflow(빈번한 ws 전환)가 appearance(애니메이션 속도/끄기)에 제약을 줄 수 있음. (b) 배경 순환/브랜딩은 workflow와 무관해도 사용자 만족도에 기여 → "성능상 제거" 같은 결론은 아님.
- **결론**: "workflow가 먼저, appearance는 그 위"를 원칙으로 하되, appearance 무결정 삭제·최소화를 주장하지 않는다. workflow 변경 시 그 안에서 appearance 조정(예: 애니메이션 속도)을 별도 결정 항목으로 둔다.

### ✅ 결정 반영됨 (§7 항목 7)
- ws 전환 애니메이션: 유지하되 **speed 2.5 → 6으로 상향** (workspaces/workspacesIn/workspacesOut 모두).
- blur: 현재 `size=3, passes=1` 유지 — 성능 문제 관측 시에만 축소.
- 미사용 leaf `fadeLayersIn`/`fadeLayersOut` 비활성화. Dracula·배경 순환·focus border·opacity 1.0은 유지.

---

## 6. Known Issues

1. **`cycle_wallpaper.sh` tracked 파일 오염 — ✅ 해결됨 (심링크 방식, §7 항목 8 적용)**
   - 과거에는 `sed -i`로 `hypr/hyprpaper.conf`와 `hypr/hyprlock.conf`의 `path`를 직접 교체해
     `git status`가 dirty해졌다.
   - 현재는 두 설정 파일이 고정 경로 `~/.config/hypr/current-wallpaper`를 가리키고,
     스크립트는 이 **심링크만** 재지정한다. tracked 설정 파일은 변경되지 않는다.
   - 상태 인덱스는 `~/.cache/hypr-wallpaper-idx`에 저장된다.
2. (참고) 하드코딩 `/home/hoco30` 경로가 hyprpaper.conf·cycle_wallpaper.sh 등에 존재 — Known Issues로 기록만.

---

## 7. 사용자 결정 필요 항목 요약

| # | 항목 | 상태 |
|---|------|------|
| 1 | Workspace 모델 | ✅ 최종: 역할 라벨 없음, 1~10 자유 사용 (2026-11-22) |
| 2 | 미디어(Spotify) workspace | ⛔ 철회: 전용 ws 없음, 열린 곳에서 사용 |
| 3 | Scratchpad 재도입 — 당초 D안 결정은 이후 철회됨 | ⛔ 최종: 삭제 유지, 재추가 금지 |
| 4 | Scratchpad 키 (`Super+grave`) | ⛔ 최종: 미사용 (바인드 없음) |
| 5 | 자동 배치 대상 — Brave→WEB(2)·Spotify→MEDIA(4) 확정, kitty·Rofi 제외, 미관측 4종 대기 | ✅ 결정됨 → **위치 강제 미적용**(2026-08-10 장기 결정) |
| 6 | 미관측 앱 class 확인 — ✅ 관측 완료: Thunar=`thunar`→GENERAL, Zathura=`org.pwmt.zathura`→GENERAL, Pavucontrol=`org.pulseaudio.pavucontrol`→floating. Obsidian 제외. 규칙 코드는 미작성 | ✅ 결정됨 → **Pavucontrol floating만 적용**(위치 강제 없음) |
| 7 | appearance(애니메이션/배경) 조정 여부 — ✅ 결정: ① ws 전환 애니메이션 **속도 상향**(애니 유지, 응답성 개선) ② blur/성능 **조건부**(성능 문제 관측 시에만 축소) ③ 미사용 animation leaf **축소**(핵심 유지). 유지: Dracula·배경 순환·focus border·opacity 1.0 | ✅ 결정됨 |
| 8 | cycle_wallpaper.sh tracked 파일 오염 해결 — **심링크 방식 적용 완료**. hyprpaper.conf·hyprlock.conf의 path가 `~/.config/hypr/current-wallpaper`를 가리키고, 순환 시 심링크만 재지정 → tracked 파일 수정 없음. 인덱스는 `~/.cache/hypr-wallpaper-idx`. | ✅ 구현 완료 |
| 9 | hyprlock.conf "Status word" label 블록 — ✅ 결정: **제거 유지 + 커밋** (commit `d8b485c`). wallpaper path는 HEAD로 원복해 커밋 오염 제외 | ✅ 결정됨 (커밋 d8b485c) |
| 10 | 절전 재개 시 wake 키가 비밀번호 칸에 들어가는 문제 + hyprlock 사망 화면 — 원인은 600초 리스너의 `pkill`이었다. 절전 직전에 `~/.cache/hypr-wake-space.flag`를 만들고 재개 1초 뒤 지우는 방식으로 변경. hyprlock은 죽이지 않고, 플래그가 있을 때 첫 `Space`만 소비한다(평상시 타이핑은 그대로). | ✅ 구현 완료, 실제 keypress 확인 완료 (2026-11-26) |
