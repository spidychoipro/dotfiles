# 나의 Hyprland 워크플로우

> 기준: 2026-11-23. 범용 dotfiles 문서가 아니라 **지금 이 노트북을 쓰는 나**를 위한 흐름 정의.
> 근거: 내가 직접 확인한 답변(2026-11-23) + 이번 대화에서 말한 것 + 2026-08-09 런타임 관측.
> 내가 확인하지 않은 추측은 ⚠️ 표시.

---

## 1. 내 환경

- 노트북: Dell Latitude 7390 2-in-1, 단일 모니터(`eDP-1`)
- 입력: **트랙패드 주력**, 물리 마우스 보조, 키보드
- 한글: fcitx5. `한/영` 키 동작 내가 확인함 → `Hangul`, 우측 Alt, `Ctrl+Space` 유지
- 미디어 키: Dell 기술 가이드 Table 66 기준으로 **트랙 키(Fn 조합) 없음**.
  실제 있는 건 `Fn+F1`~`F4`(음소거/볼륨-/볼륨+/마이크), `Fn+↑/↓`(밝기)뿐.

---

## 2. 워크스페이스는 이렇게 쓴다

### 원칙
- 역할 라벨(`DEV/WEB/MEDIA`) **없음**. 1~10 자유롭게.
- 앱은 **열린 곳에 그대로 둔다**. 자동 배치 없음. 정리할 때만 `Super+Shift+N`으로 이동.
- **Spotify 전용 ws 없음. 음악은 지금 작업하는 ws에서 같이 듣는다.** (내가 확인 ✅)

### 내가 확인한 사용 습관 (2026-11-23, 2026-11-26 보완)
- **1번 ws = 메인 작업, 2번 ws = 보조 / 2nd 작업.** (내가 확인 ✅ 2026-11-26)
  → 예전 문서의 "2번에 터미널 많이 연다"는 표현은 부정확. 2번은 보조·두 번째 작업 공간이다.
- 예전 관측(2026-08-09)에서는 2번에 Brave + kitty가 공존했다. ⚠️ 현재도 같은지는 미확인.
- 한 ws에 동시에 띄우는 창은 **많아 봤자 4개, 그 이상은 만들지 않는다.** (내가 확인 ✅)
  → 자동 배치 재도입 기준(ws당 4~5개)에 아직 안 걸림. 위치 강제 규칙 계속 넣지 않는다.

| ws | 2026-08-09 관측 | 지금 내가 말한 것 |
|----|----------------|-------------------|
| 1 | kitty ×2 | — |
| 2 | Brave + kitty | **보조 / 2nd 작업** ✅ |
| 3 | Spotify | Spotify 전용 아님 ✅ |
| 4 | kitty | — |

→ 나는 **ws를 역할이 아니라 "그냥 작업 공간"으로 나눠 쓰는 사람**이다.

### 이동/순환 수단 (상황별로 골라 쓰기)
| 상황 | 수단 |
|---|---|
| 특정 번호로 바로 | `Super+1`~`0` |
| 트랙패드에서 넘기기 | **3손가락 좌우 스와이프** (열려 있는 ws만 왕복) |
| 물리 마우스 | `Super+휠` (같은 방식으로 순환) |
| 키보드만 쓸 때 | `Super+←` / `Super+→` (60, 61번) ⚠️ 실제 키 입력 확인 필요 |

> 트랙패드 **두 손가락 스크롤은 ws 전환이 안 된다.** Hyprland 0.56.2가 그 이벤트를
> 휠 바인드로 안 보내서 구조적으로 막힘. 대신 위 세 가지를 쓴다.

---

## 3. 하루 흐름

### 켜고 작업 시작
- 부팅 시 자동 실행: `swayosd-server`, `hyprpaper` + `waybar` + `swaync` + `hypridle`,
  `cliphist` 감시, `fcitx5`, `playerctld`. (Quickshell 없음)
- 터미널: `Super+Q` (kitty). 주로 **2번 ws**에서 많이 연다.
- 앱 실행: `Super+Space` (rofi), `Super+E`(thunar), `Super+B`(Brave),
  `Super+Shift+M`(Spotify), `Super+D`(PDF → zathura)

### 작업 중 (창/레이아웃)
- 포커스 이동 `Super+h/j/k/l`, 창 스왑 `Super+Shift+h/j/k/l`
- 레이아웃 전환 `Super+Shift+T` (dwindle ↔ master). **상황에 따라 둘 다 쓴다** ✅ (2026-11-26)
- **분할 방향 전환 `Super+R`** — 두 창이 위/아래면 좌/우로, 좌/우면 위/아래로.
  dwindle이든 master든 현재 레이아웃을 자동 판별해서 동작한다 ✅ (2026-11-26)
- 전체화면 `Super+F`, 의사 타일링 `Super+P`, 창 닫기 `Super+C`
- 클립보드 `Super+V`, 배경 순환 `Super+W`

### 소리 / 미디어 ← 내가 뽑은 가장 부족했던 영역 (2026-11-23)
- 볼륨: `Fn+F2`/`Fn+F3`, **2% 단위** (swayosd OSD). 실측 10→12→10 + 체감도 괜찮음 확인 ✅ (2026-11-26)
- 음소거 `Fn+F1`, 마이크 `Fn+F4`, 밝기 `Fn+↑/↓`
- **트랙 제어는 이 노트북에 물리 키가 없어서 누를 수 있는 조합으로 새로 넣었다:**

| 키 | 동작 | 번호 |
|---|---|---|
| `Super+Shift+←` | 이전 트랙 | 62 |
| `Super+Shift+→` | 다음 트랙 | 63 |
| `Super+Shift+Space` | 재생 / 일시정지 | 64 |

→ `swayosd-client --playerctl`을 써서 OSD가 뜨고, 플레이어가 안 켜져 있어도
에러 없이 조용히 끝난다(실측 rc=0). 음악은 작업 ws에서 같이 틀어놓고
트랙만 위 키로 넘기면 된다. ⚠️ 실제 키 입력 테스트는 아직 안 함.

**플레이어 대상은 `auto` 유지 (고정하지 않음).**
`swayosd 0.3.2` 소스(`src/actions/mpris.rs`) 기준:
- `playerctld`가 실행 중이면 그 목록의 첫 번째 플레이어를 쓴다.
- `playerctld`는 **가장 최근에 활성화된 플레이어를 맨 앞에 둔다.**
- 없으면 `find_active()` = 실제 재생 중인 플레이어로 폴백.

⚠️ 2026-11-26까지 `playerctld`가 **실제로는 실행되지 않고 있었는데 문서만 실행 중이라고 돼 있었다.**
그 상태에선 두 플레이어가 동시 재생 중이면 이름순으로 Brave가 잡혀 Spotify를 못 조작했다.
hyprland autostart에 `playerctld daemon`을 추가해 문서대로 동작하게 고쳤다.
waybar 미디어 위젯·클릭/스크롤·키바인드가 `waybar/media.sh`라는 **한 스크립트**를 공유한다.
단순히 `playerctld`의 기본 대상만 쓰면 그 플레이어가 일시정지이고 다른 플레이어가 재생 중일 때
엉뚱한 쪽을 조작하게 되므로, **재생 중인 플레이어를 우선**하고 없으면 기본 대상(최근 활성)으로 폴백한다.
화면에 보이는 곡 = 키/마우스로 조작되는 곡이 항상 일치한다.

→ Spotify를 틀면 Spotify, Brave 유튜브를 틀면 Brave를 제어한다.
`--player spotify`로 고정하면 Brave 소리를 조작할 수 없게 되므로 유지한다.

#### Spotify 패치 업데이트 (2026-11-26)
- 설치는 AUR `spotify` + SpotX-Bash 패치(무료 계정 기본).
- Spotify를 업데이트하면 패치가 덮어써지므로, `spotx-update.sh`로 재패치한다.
- 기본은 `--check`(상태만 출력)이고, `--apply`에서 SpotX가 지원하는 버전까지만
  `yay -S`로 올린 뒤 SpotX를 다시 실행한다. 지원보다 높은 AUR 버전은 건너뛴다.
- Spotify가 실행 중이면 중단된다. 종료한 뒤 실행할 것. Premium이면 `--premium`.
- SpotX가 sudo 암호를 요청할 수 있어 실제 터미널에서 실행해야 한다.
- 업그레이드 후 옛 백업이 새 클라이언트와 안 맞아 패치가 거부되면,
  스크립트가 백업을 `~/.local/share/spotx-update/backups/`로 옮기고 새 백업을 만들게 한다 (2026-11-26 수정).

### 마무리
- 캡처: `Print`(창), `Super+Shift+S`(영역)
- 잠금: `Super+Alt+L`
- 절전 후 깨울 때 누른 `Space`가 비밀번호로 들어가던 문제 수정 (2026-11-26):
  600초 리스너가 절전 직전에 `~/.cache/hypr-wake-space.flag`를 만들고,
  재개 1초 뒤 백그라운드가 지운다. 그 첫 `Space`만 소비하고,
  평상시·비밀번호 타이핑 중 `Space`는 그대로 전달된다.
  hyprlock을 죽이지 않으므로 "lockscreen app died" 화면도 재발하지 않는다.
  ✅ 실제 절전/재개 후 `Space`로 깨웠을 때 비밀번호 칸이 비어 있음 확인 완료 (2026-11-26).
- 종료 메뉴: `Super+M`

---

## 4. 의도적으로 넣지 않은 것 (넣지 말 것)

| 항목 | 이유 |
|---|---|
| 스크래치패드 / 드롭다운 터미널 / `Super+grave` | 두 번 도입했다가 두 번 제거. 숨은 창 생김 |
| Quickshell | 보류·미사용 확정 |
| 워크스페이스 역할 라벨 + 자동 배치 | 실사용(2번 터미널 + Brave 공존)과 충돌 |
| MRU(`Super+Tab`) / rofi 창 스위처 | `Super+h/j/k/l` + ws 이동으로 충분 |
| 트랙패드 2손가락 스크롤로 ws 전환 | Hyprland가 바인드로 안 전달 |

---

## 5. 아직 내가 확인할 것

1. `Super+←/→` 실제 키 입력으로 1↔2 왕복 (바인드 등록은 확인됨)
2. `Super+Shift+←/→/Space` 실제 키 입력으로 트랙 제어 + OSD 확인 — 아직 실제 재생으로 안 써봄 (2026-11-26)
3. 66개 바인드 중 keep/change/delete 표시 → `docs/keybind-inventory.md` 번호로 지정
4. 볼륨 2% 스텝 체감 확인 → 완료 ✅ (2026-11-26, 2% 괜찮음)
5. 실제 두 번째 머신에 설치해 보기 (가짜 홈 시뮬레이션은 통과했음)
6. 화면 공유 필요 여부 미확정 ⚠️. 지금은 `xdg-desktop-portal-hyprland`가 없어서
   포털 화면 공유/녹화는 동작하지 않는다. 과거 발열 기억이 있어 일단 넣지 않았다.
   로컬 캡처(`Print`, `Super+Shift+S`)는 `hyprshot`로 정상 동작한다.
   필요해지면 `sudo pacman -S xdg-desktop-portal-hyprland` (grim/slurp는 이미 설치됨).

> 참고: 56~59번(물리 키 없는 XF86 트랙 바인드)은 **삭제하지 않고 유지**했다.
> 외부 Dell 키보드/독을 물리면 동작할 수 있기 때문이고, 실제로 누를 수 있는
> 대안은 62~64번으로 이미 넣었기 때문이다.

---

## 6. 문제 생기면

```bash
bash ~/dotfiles/diagnose.sh          # 현재 80 pass / 0 warn / 0 fail
hyprctl configerrors                 # 설정 파싱 오류
hyprctl getoption gestures:workspace_swipe_create_new
hyprctl getoption gestures:workspace_swipe_forever
hyprctl binds | grep -c '^bind'      # 현재 66개
```

변경 사항은 `agent/publish-hyprland-dotfiles`에 커밋 후 `main`으로 머지해서
GitHub 기본 브랜치에도 반영한다.
