# Hyprland 개인 취향 복원 플랜 (Dracula + 애니)

> 적용 대상: `/home/hoco30/dotfiles` (source of truth, `~/.config/hypr` → `/home/hoco30/dotfiles/hypr` 심링크)
> 상태: **PLAN 단계** (아무것도 수정하지 않음). Do 단계에서 아래 순서대로 적용.

---

## 목표 (success criteria — measurable)

1. **Dracula 팔레트 전면 적용 (hyprland.lua 시각 요소)**
   - `hyprctl getoption general:col.active_border` → `rgba(ff79c6ee)` / `rgba(bd93f9ee)`, `angle = 45`
   - `hyprctl getoption general:col.inactive_border` → `rgba(44475aaa)` (Dracula current-line #44475A)
   - `hyprctl getoption decoration:shadow:color` → `0xee282a36` (Dracula bg #282a36)
   - `hyprctl getoption decoration:blur:vibrancy` → `0.25` (제안값, 시각 검증 후 단일 값 조정 허용)
2. **드롭다운 터미널 완전 제거 (사용자 확정: 과거 시도 후 제거한 기능)**
   - `hyprctl binds`에 toggle_term.sh 관련 바인드 **없음**
   - `grep -rn "toggle_term\|kitty-dropdown\|special:term"` → hyprland.lua/toggle_term.sh/install.sh/diagnose.sh 포함 **0건**
   - `toggle_term.sh` 파일 삭제, `install.sh`/`diagnose.sh`의 참조 라인 제거
3. **죽은 바인딩/룰 제거 (스크래치패드 전부 삭제 — 사용자 확정)**
   - `magic`, `epic-mouse-v1`, `hyprland-run`, `dropdown-term`, `SUPER+S` 잔재 **0건** (`grep` 확인)
   - 새 바인딩 추가 없음 — 전부 제거만
4. **애니 배경화면 일원화**
   - hyprpaper + hyprlock이 **동일 이미지 파일** 사용 (hyprpaper.conf path == hyprlock.conf path)
   - `hyprctl hyprpaper listactive` 로 active 배경 확인
5. **README.md 동기화**
   - README.md:86 `Super + Enter` 행이 실제 바인딩(드롭다운 터미널)과 일치
   - "Master 레이아웃: 포커스된 창을 Master로 교체" 허위 기재 잔재 없음
6. **GDK 스케일링 단일 정책**
   - 글로벌 `hl.env("GDK_SCALE","1")` / `hl.env("GDK_DPI_SCALE","0.7")` (l.81-82) 유지
   - thunar 로컬 오버라이드(`GDK_SCALE=0.8 GDK_DPI_SCALE=0.8`, l.39) 제거 → `fileManager = "thunar"`
   - `hyprland.lua` diff에서 `GDK_*` 로컬 env 0건
7. **기존 상태 보존 확인**
   - fcitx5 한글 IME env (`XMODIFIERS`/`QT_IM_MODULE`, l.78-80) diff 변경 없음 → 한글 입력 정상 동작
   - 미커밋 5건(README.md, hyprland.lua, fcitx5/conf/, hypr/pdf-open.sh, zathura/) 그대로 보존 (커밋/롤백 없음)
8. **최종 시각 검증** — `hyprshot -m window` 스크린샷으로 Dracula 보더 그라디언트·그림자·애니 배경 확인

---

## 배경

사용자 생태계 전체가 Dracula 테마(waybar/rofi/kitty/swaync/swayosd/hyprlock/hyprtoolkit)인 반면,
`hypr/hyprland.lua`의 LOOK AND FEEL 섹션(과 일부 바인딩)은 wiki 예제 그대로 남아 있다.
bkit-analyzer 갭 분석 결과 10건 발견 (본문 참조). 또한 git 로그상
`remove: SUPER+grave dropdown terminal binding` 커밋으로 드롭다운 터미널 바인딩이 제거된 채
`toggle_term.sh`와 `dropdown-term` 윈도우 룰만 잔존 → 기능만 죽어 있는 상태.
README.md:86은 존재하지 않는 "Super+Enter = Master 전환" 바인딩을 문서화 중.

사용자 확정 사항:
- active_border = **pink→purple 그라디언트** `rgba(ff79c6ee)` → `rgba(bd93f9ee)`, angle 45
- 배경화면 = **"개쩌는 애니 이미지"** (Mumei/Hololive 팬, fastfetch 로고가 mumei.png 컷아웃) — lofi/랜드스케이프 탈피
  - 배경 소싱은 **하위 태스크**: Do 단계에서 기준 충족 후보 2-3개 제시 → 사용자 확정 후 다운로드
- **드롭다운 터미널 제외 확정** — 과거 `SUPER+grave`에 바인딩했다가 직접 제거한 전적(커밋 d39564d). "완전 아니였음" → 재추가 금지
- **스크래치패드 전부 삭제 확정** — `Super+S`/`magic`은 빈 서랍만 토글하는 죽은 키 → 전체 제거

---

## 작업 목록 (ordered)

### 작업 1: Dracula 보더 컬러 — `hypr/hyprland.lua:124-125`
- **변경내용**
  ```lua
  -- before
  active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
  inactive_border = "rgba(595959aa)",
  -- after
  active_border   = { colors = {"rgba(ff79c6ee)", "rgba(bd93f9ee)"}, angle = 45 },  -- Dracula pink #ff79c6 → purple #bd93f9
  inactive_border = "rgba(44475aaa)",                                               -- Dracula current-line #44475A
  ```
- **성공검증**
  - `hyprctl reload` → 에러/경고 없음
  - `hyprctl getoption general:col.active_border` → ff79c6ee, bd93f9ee, angle 45
  - `hyprctl getoption general:col.inactive_border` → rgba(44475aaa)
  - 스크린샷: 포커스 창 pink→purple 45° 그라디언트, 비포커스 창 current-line 색

### 작업 2: 섀도우 컬러 — `hypr/hyprland.lua:149`
- **변경내용** `color = 0xee1a1a1a` → `color = 0xee282a36` (alpha 접두어 ee 유지, 컬러만 Dracula bg로)
- **성공검증**
  - `hyprctl getoption decoration:shadow:color` → 0xee282a36
  - 스크린샷: 그림자가 검붉은 wiki 기본색(1a1a1a)이 아닌 Dracula 배경 계열로 보임
  - ⚠️ alpha 해석(AARRGGBB vs RRGGBBAA)은 시각으로 확정 — 이상하면 `rgba(282a36ee)` 문자열 폼으로 교체 (유일한 예외 허용값)

### 작업 3: blur vibrancy — `hypr/hyprland.lua:156`
- **변경내용** `vibrancy = 0.1696` → `vibrancy = 0.25` (wiki 기본값에서 미세 상향 — 애니 배경의 채도를 살림. 시각 확인 후 0.2~0.3 범위 내 단일 값 조정만 허용)
- **성공검증** `hyprctl getoption decoration:blur:vibrancy` → 0.25 + 블러 영역(waybar/rofi) 시각 확인

### 작업 4: epic-mouse-v1 디바이스 룰 제거 — `hypr/hyprland.lua:274-279`
- **변경내용** 아래 블록 전체(주석 포함) 삭제
  ```lua
  -- Example per-device config
  -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
  hl.device({
      name        = "epic-mouse-v1",
      sensitivity = -0.5,
  })
  ```
- **성공검증** `grep -n "epic-mouse" hypr/hyprland.lua` → 결과 없음; `hyprctl devices -j`에 해당 디바이스 미존재 (원래 없었으므로 기존 동작과 동일)

### 작업 5: 스크래치패드 완전 제거 (Super+S + magic) — `hypr/hyprland.lua:330-332`
- **변경내용** 아래 2줄(바인드 + 주석 바인드) 모두 삭제 — 빈 special workspace만 토글하는 죽은 키. 새 바인딩 추가 없음
  ```lua
  -- Example special workspace (scratchpad)
  hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
  --hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
  ```
- **성공검증** `grep -n "magic\|toggle_special" hypr/hyprland.lua` → 결과 없음; `hyprctl binds | grep -i "super,S"` → 없음; reload 정상

### 작업 6: 드롭다운 터미널 완전 제거 (사용자 확정 — 과거 직접 제거한 기능)
- **6a. 윈도우 룰 제거** — `hypr/hyprland.lua:426-433`
  ```lua
  hl.window_rule({
      name  = "dropdown-term",
      match = { class = "kitty-dropdown" },
      float  = true,
      pin    = true,
      move   = "0 0",
      size   = "100% 55%",
  })
  ```
- **6b. 스크립트 삭제** — `hypr/toggle_term.sh` 파일 삭제
- **6c. 참조 정리**:
  - `install.sh:18` → `toggle_term.sh` 심링크 라인 삭제
  - `diagnose.sh:73` → files 목록에서 `hypr/toggle_term.sh` 제거
  - `diagnose.sh:114` → `for script in toggle_window_layout.sh diagnose.sh` 로 수정
- **성공검증** `grep -rn "toggle_term\|kitty-dropdown\|special:term" hypr/ install.sh` → 0건; `hyprctl reload` 정상; `bash -n install.sh diagnose.sh` 문법 OK

### 작업 7: hyprland-run 윈도우 룰 제거 — `hypr/hyprland.lua:404-411`
- **변경내용** 아래 블록 삭제 (사용자가 rofi를 쓰므로 hyprland-run 클래스는 생성될 일 없음 — wiki 예제 잔재)
  ```lua
  -- Hyprland-run windowrule
  hl.window_rule({
      name  = "move-hyprland-run",
      match = { class = "hyprland-run" },
      move  = "20 monitor_h-120",
      float = true,
  })
  ```
- **성공검증** `grep -n "hyprland-run" hypr/hyprland.lua` → 결과 없음; `hyprctl reload` 정상, rofi 실행 정상

### 작업 8: GDK 스케일링 단일화 — `hypr/hyprland.lua:39`
- **변경내용** `local fileManager = "env GDK_SCALE=0.8 GDK_DPI_SCALE=0.8 thunar"` → `local fileManager = "thunar"`
  - 글로벌 env(l.81-82: GDK_SCALE=1, GDK_DPI_SCALE=0.7)는 **유지** — 단일 정책
  - `QT_SCALE_FACTOR=0.8 systemsettings`(l.305)는 **건드리지 않음** (NSP: systemsettings 스케일링 fix = out of scope)
- **성공검증** Super+E → thunar 정상 실행 (창 크기/폰트 시각 확인); `grep -n "GDK_SCALE=0.8" hypr/hyprland.lua` → 결과 없음; `hyprctl getenv GDK_SCALE` → 1
- **참고** `diagnose.sh`의 GDK 체크(l.151-153)는 셸 환경만 출력하므로 본 변경 영향 없음

### 작업 9: 애니 배경화면 일원화 — `backgrounds/` + `hypr/hyprpaper.conf` + `hypr/hyprlock.conf` + `.gitignore` (하위 태스크)
- **9a. 선정 기준 (Do 단계에서 후보 2-3개 제시 → 사용자 확정)**
  - Mumei/Hololive 애니 팬아트 우선 (fastfetch 로고와 브랜딩 일치), 일반 애니 팬아트도 OK
  - **어두운 톤** 우선 (Dracula #282a36 계열과 조화, 밝은 배경은 불가피한 경우만)
  - 16:9 비율, 세로 해상도 ≥1080p (hyprpaper fullscreen + hyprlock 품질용)
  - 저작권 각인/워터마크·가로세로 잘림 없는 원본
  - 출처 기록: 파일명에 출처 태그 또는 README/docs에 출처 기재 (개인 사용 + GitHub 미업로드 전제)
- **9b. 다운로드** → `~/dotfiles/backgrounds/anime-<이름>.<원본확장자>` (**원본 그대로, 리사이즈/변환 금지**)
  - `~/.config/backgrounds` → `~/dotfiles/backgrounds` 심링크이므로 install.sh 변경 불필요 (자동 노출)
- **9c. `hypr/hyprpaper.conf`** path 교체 (기존 절대경로 스타일 유지):
  `path = /home/hoco30/.config/backgrounds/lofiwallpaper.png` → `/home/hoco30/.config/backgrounds/anime-<이름>.<확장자>`
- **9d. `hypr/hyprlock.conf:10`** path 교체:
  `path = ~/.config/backgrounds/shaded.png` → `~/.config/backgrounds/anime-<이름>.<확장자>`
  (blur/brightness 0.55/contrast/vibrancy 등 **다른 설정은 그대로** — 하이프록 레이아웃 변경 금지)
- **9e. `.gitignore`** 추가 (fastfetch 선례 준수 — 저작권 이미지 GitHub 업로드 제외):
  `backgrounds/anime-*.png` (확장자에 따라 jpg/webp 포함)
- **성공검증**
  - `hyprctl hyprpaper reload` → `hyprctl hyprpaper listactive` 에서 새 파일 확인
  - hyprlock 재실행(다음 잠금) 시 동일 이미지 표시 — `hyprlock.conf` path와 hyprpaper.conf path 문자열 일치
  - `git status --short`에 `backgrounds/anime-*` 미추적 확인 (gitignore 동작)
  - 스크린샷으로 하이프페이퍼 + 잠금화면 시각 확인
- **NOTE**: 이미지 다운로드는 **Do 단계에서만** 수행. 이 플랜은 선정 기준/흐름만 정의함.

### 작업 10: README.md 동기화 — `README.md:86, 111` (+ 선택: l.217 구조 목록)
- **변경내용**
  - l.86 행 교체 (존재하지 않는 바인딩 정리):
    `| Super + Enter | Master 레이아웃: 포커스된 창을 Master로 교체 |` → **행 삭제 또는 "미바인딩" 기재** (실제 바인딩 없음)
  - l.111 행 교체 (스크래치패드 제거 반영):
    `| Super + S | 특수 작업공간 (스크래치패드) 토글 |` → **행 삭제** (기능 제거)
  - (선택) l.204-229 구조 섹션의 `hypr/` 목록에서 `toggle_term.sh` 제거
- **성공검증** README 바인딩 표 전체와 `hyprctl binds` 대조 — 허위 기재 없음; `grep -n "Master 레이아웃: 포커스된 창\|toggle_term\|스크래치패드" README.md` → 결과 없음

---

## Negative Space (NSP)

### What NOT to do
- **다른 앱 설정 건드리지 않음** — waybar/rofi/kitty/swaync/swayosd/hyprtoolkit/hypridle 등은 이번 작업 범위 밖 (변경 대상: `dotfiles/hypr/*`, `README.md`, `backgrounds/`, `.gitignore`, `docs/` 만)
- **레이아웃(dwindle), 키바인딩 스킴, 단축키 체계 변경 금지** — 새 바인딩 추가 없음 (이번 작업은 전부 제거/수정만)
- **초심자 편의 알리아스 추가 / 코어 커맨드 오버라이드 금지** (기존 AGENTS.md 규칙 유지)
- **fcitx5 한글 IME env 훼손 금지** — `XMODIFIERS`/`QT_IM_MODULE`/`QT_QPA_PLATFORMTHEME`(l.78-80)은 그대로
- **모니터/스케일 설정 변경 금지** — monitor `scale = 1.25`(l.29) 유지
- **hypridle/hyprlock 레이아웃 변경 금지** — hyprlock은 배경 path 교체(l.10)만
- **border/shadow/blur/animation 추가 재조정 금지** — 갭 분석 목록의 특정 값만 (작업 1-3); vibrancy는 0.2~0.3 내 단일 조정만
- **hyprland.lua의 다른 wiki 주석/블록 정리 금지** (master/scrolling/gesture/workspace-rule 주석 등) — 최소 diff

### Anti-patterns (피할 패턴)
- 대규모 리팩터·"한 번에 몰아 고치기" — 작업 1건당 `hyprctl reload` + 검증 후 다음 작업
- 기존 배경 파일(lofiwallpaper/shaded/arch-rainbow 등) **삭제 금지** — 사용 안 해도 보존
- hyprpaper.conf의 절대경로 → 상대경로 스타일 변경 금지 (최소 diff 원칙)
- hyprctl 임시 dispatch로 시험한 값을 설정에 하드코딩하고 방치
- git 히스토리 재작성, force push

### Out of scope (이번 플랜에서 제외)
- systemsettings 스케일링 fix (l.305 `QT_SCALE_FACTOR=0.8` 유지 — 별도 후속 태스크)
- waybar/rofi/swaync 재설계
- 갭 분석 목록 외 hyprland.lua 리팩터
- hypridle 타이머/절전 정책 변경
- master/scrolling 레이아웃 설정 제거 (l.219-231, 사용 안 해도 보존)
- 미사용 배경 파일 정리
- 미커밋 5건(README.md, hypr/hyprland.lua, fcitx5/conf/, hypr/pdf-open.sh, zathura/)의 **커밋 또는 되돌림** — 사용자 동의 없이 금지

### Tech / approaches NOT to use
- **ImageMagick** (`convert`/`mogrify`) 리사이즈·변환 — 원본 유지가 원칙. 16:9/해상도 미달 시 변환 대신 다른 후보를 찾음. 불가피한 경우에만 Do 단계에서 명시적으로 고지 후 사용
- **테마 관리 도구 도입 금지** (hyprtheme/pywal/matugen 등) — Dracula 값 하드코딩 유지
- **hyprland.conf 로의 전환 금지** — Lua 설정(`hl.*`) 유지
- **설정 자동생성 스크립트 금지** — 수동 수술적 편집만
- **새 종속성 설치 금지** — 예외 없음 (jq는 toggle_term.sh 제거로 필요 없어짐)

### Boundaries
- 변경 파일: `hypr/hyprland.lua`, `hypr/hyprpaper.conf`, `hypr/hyprlock.conf`, `hypr/toggle_term.sh`(삭제), `hypr/diagnose.sh`, `install.sh`, `README.md`, `.gitignore`, `backgrounds/anime-*`(신규), `docs/`(신규)
- hyprland.lua 편집: 작업 1-8의 해당 라인만, diff 최소
- 동시 변경 1건씩 → reload → 검증 (작업 9 배경은 독립적)

### Edge cases NOT handled (명시적 미처리)
- **듀얼/외장 모니터** — 현재 모니터 정의는 eDP-1 단일 (기존 구성 기준 그대로)
- **HiDPI 1.25x 외 스케일** — 미가정
- **hyprlock brightness 0.55가 애니 이미지를 과도하게 어둡게 할 가능성** — 값 조정은 out of scope (마음에 안 들면 별도 후속 태스크로)
- **배경 저작권 (Pixiv/Twitter 팬아트)** — 개인 로컬 사용 전제, GitHub 업로드는 `.gitignore`로 차단. 상업 배포 아님
- **재로그인 없이 hyprlock 즉시 반영 불가** — 다음 잠금부터 적용됨

---

## 리스크 (risk + mitigation)

| # | 리스크 | 완화 |
|---|--------|------|
| 1 | Lua 파싱 에러 → hyprctl reload 실패 | 작업 1건당 즉시 reload로 검증, 에러 시 직전 백업 복원. 편집 전 `/tmp/opencode/hyprland.lua.bak-$(date +%s)` 사본 필수 |
| 2 | hyprland.lua/README.md는 **미커밋 변경 보존 중** → git checkout으로 되돌리면 기존 작업 증발 | 편집 전 `cp` 백업 보관, 롤백은 백업 복원으로만 (git checkout 금지, NSP) |
| 3 | 마음에 드는 애니 배경(16:9, ≥1080p, 어두운 톤) 찾기 실패 | 후보 2-3개 + 사용자 확정 단계. 실패 시 기존 shaded.png 유지 후 별도 후속 태스크 |
| 4 | 하이프랜드 색상 alpha 형식 해석(AARRGGBB vs RRGGBBAA)으로 그림자/보더가 의도와 다르게 보임 | 시각 검증으로 확정, 이상 시 `rgba(...)` 문자열 폼으로 교체 (허용된 유일 예외) |
| 5 | install.sh/diagnose.sh에서 toggle_term.sh 참조 제거 누락 | grep으로 0건 검증 + `bash -n` 문법 확인 (작업 6c 성공검증) |
| 6 | thunar GDK env 제거로 창/폰트 크기 변화 | Super+E 시각 확인, 불만족 시 단일 라인 복원 (결정적 리스크 낮음) |
| 7 | Super+S/스크래치패드 제거로 사용 습관 변화 | 이미 죽은 키(빈 서랍 토글) — 실사용 없음. README에서도 제거, 키는 향후 다른 용도로 자유롭게 사용 가능 |
| 8 | 애니 배경이 밝아서 hyprlock 0.55 어둡게 + Dracula 보더와 충돌 | 선정 기준에 "어두운 톤" 포함 — 선별 단계에서 걸러냄 |

---

## 롤백 계획 (rollback)

### 사전 준비 (작업 시작 전, Do 단계 필수)
```bash
# 1) hyprland.lua / README.md 는 미커밋 변경 보존 파일 → git checkout 금지, cp 백업만
cp /home/hoco30/dotfiles/hypr/hyprland.lua /tmp/opencode/hyprland.lua.bak-$(date +%s)
cp /home/hoco30/dotfiles/README.md        /tmp/opencode/README.md.bak-$(date +%s)
# 2) 클린(커밋된) 파일은 git 롤백 가능
#    hypr/hyprpaper.conf, hypr/hyprlock.conf, .gitignore
```

### 단계별 롤백
| 대상 | 롤백 방법 |
|------|-----------|
| hyprland.lua (작업 1-8) | `cp /tmp/opencode/hyprland.lua.bak-* hypr/hyprland.lua` → `hyprctl reload` |
| README.md (작업 10) | `cp /tmp/opencode/README.md.bak-* README.md` |
| toggle_term.sh + install.sh + diagnose.sh (작업 6) | 모두 git tracked — `git checkout -- hypr/toggle_term.sh install.sh hypr/diagnose.sh` |
| hyprpaper.conf / hyprlock.conf | `git checkout -- hypr/hyprpaper.conf hypr/hyprlock.conf` → `hyprctl hyprpaper reload` |
| .gitignore | `git checkout -- .gitignore` |
| 새 배경 파일 (작업 9) | `rm ~/dotfiles/backgrounds/anime-*` (원본은 출처에서 재다운로드 가능) |

### 리로드 명령
```bash
hyprctl reload              # hyprland.lua 적용
hyprctl hyprpaper reload    # hyprpaper.conf 재적용
# hyprlock: 설정은 다음 잠금 실행 시 적용 (라이브 리로드 없음)
```

### 롤백 후 확인
- `hyprctl getoption general:col.active_border` → 원래 값(`33ccffee`/`00ff99ee`) 복귀 확인
- `hyprctl binds | grep -i return` → 원래 없던 바인드 제거 확인
- 한글 입력(한/영 전환) 정상 확인
- 기존 미커밋 변경(README.md, hyprland.lua, fcitx5/conf/, hypr/pdf-open.sh, zathura/)이 롤백으로 소실되지 않았는지 `git status` 로 대조 — **소실 시 절대 안 됨**

---

## 부록: 갭 분석 매핑 (bkit-analyzer → 작업)

| 갭 | hyprland.lua 위치 | 작업 번호 |
|----|-------------------|-----------|
| 1. active_border 오프 팔레트 | l.124 | 작업 1 |
| 2. inactive_border 비-Dracula | l.125 | 작업 1 |
| 3. shadow 0xee1a1a1a | l.149 | 작업 2 |
| 4. vibrancy 0.1696 (wiki 기본) | l.156 | 작업 3 |
| 5. epic-mouse-v1 디바이스 룰 (유령) | l.276-279 | 작업 4 |
| 6. magic 스크래치패드 (빈 서랍만 토글하는 죽은 키) | l.330-332 | 작업 5 (완전 제거) |
| 7. dropdown-term 룰 + toggle_term.sh 잔존 (사용자 직접 제거한 기능) | l.426-433 + toggle_term.sh | 작업 6 (완전 제거, install/diagnose 참조 포함) |
| 8. GDK/QT 스케일 3중 불일치 | l.39, 81-82, 305 | 작업 8 (QT는 범위 밖 유지) |
| 9. hyprpaper vs hyprlock 배경 분리 | hyprpaper.conf / hyprlock.conf | 작업 9 |
| 10. README:86 허위 바인딩 문서화 | README.md:86 | 작업 10 |
