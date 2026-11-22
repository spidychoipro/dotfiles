# 나의 Hyprland 워크플로우

> 기준: 2026-11-23. 범용 dotfiles 문서가 아니라 **지금 이 노트북을 쓰는 나**를 위한 흐름 정의.
> 근거: 이번 대화에서 내가 말한 것 + `docs/workflow.md`의 런타임 관측 기록.
> 확실치 않은 항목은 ⚠️ 표시.

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
- Spotify 전용 ws도 없음. 음악은 지금 작업하는 ws에서 같이 듣는다.

### 실제 관측된 패턴 (2026-08-09, 현재도 유사 ⚠️)
| ws | 열려 있던 것 |
|----|--------------|
| 1 | kitty ×2 |
| 2 | Brave + kitty (같은 ws에 공존 — 역할 분리 안 맞는다는 근거) |
| 3 | Spotify |
| 4 | kitty |

→ 즉 나는 **ws를 역할이 아니라 "그냥 작업 공간"으로 나눠 쓰는 사람**이다.

### 이동/순환 수단 (상황별로 골라 쓰기)
| 상황 | 수단 |
|---|---|
| 특정 번호로 바로 | `Super+1`~`0` |
| 트랙패드에서 넘기기 | **3손가락 좌우 스와이프** (열려 있는 ws만 왕복) |
| 물리 마우스 | `Super+휠` (같은 방식으로 순환) |
| 키보드만 쓸 때 | `Super+←` / `Super+→` (60, 61번) |

> 트랙패드 **두 손가락 스크롤은 ws 전환이 안 된다.** Hyprland 0.56.2가 그 이벤트를
> 휠 바인드로 안 보내서 구조적으로 막힘. 대신 위 세 가지를 쓴다.

---

## 3. 하루 흐름

### 켜고 작업 시작
- 부팅 시 자동 실행: `swayosd-server`, `hyprpaper` + `waybar` + `swaync` + `hypridle`,
  `cliphist` 감시, `fcitx5`. (Quickshell 없음)
- 터미널: `Super+Q` (kitty)
- 앱 실행: `Super+Space` (rofi), `Super+E`(thunar), `Super+B`(Brave),
  `Super+Shift+M`(Spotify), `Super+D`(PDF → zathura)

### 작업 중 (창/레이아웃)
- 포커스 이동 `Super+h/j/k/l`, 창 스왑 `Super+Shift+h/j/k/l`
- 레이아웃 전환 `Super+Shift+T` (dwindle ↔ master)
- 전체화면 `Super+F`, 의사 타일링 `Super+P`, 창 닫기 `Super+C`
- 클립보드 `Super+V`, 배경 순환 `Super+W`

### 소리/화면
- 볼륨: `Fn+F2`/`Fn+F3`, **2% 단위** (OSD에 swayosd). 실측 10→12→10 확인.
- 음소거 `Fn+F1`, 마이크 `Fn+F4`, 밝기 `Fn+↑/↓`
- ⚠️ 미디어 트랙 제어(다음/이전/재생)는 이 노트북에 누를 키가 없음.
  Spotify는 켜서 듣고, 트랙 이동은 플레이어 UI로 해야 함.

### 마무리
- 캡처: `Print`(창), `Super+Shift+S`(영역)
- 잠금: `Super+Alt+L`
- 종료 메뉴: `Super+M`

---

## 4. 의도적으로 넣지 않은 것 (넣지 말 것)

| 항목 | 이유 |
|---|---|
| 스크래치패드 / 드롭다운 터미널 / `Super+grave` | 두 번 도입했다가 두 번 제거. 숨은 창 생김 |
| Quickshell | 보류·미사용 확정 |
| 워크스페이스 역할 라벨 + 자동 배치 | 실사용(kitty+Brave 공존)과 충돌 |
| MRU(`Super+Tab`) / rofi 창 스위처 | `Super+h/j/k/l` + ws 이동으로 충분 |
| 트랙패드 2손가락 스크롤로 ws 전환 | Hyprland가 바인드로 안 전달 |

---

## 5. 아직 내가 결정/확인할 것

1. `Super+←/→` 실제 키 입력으로 1↔2 왕복 확인 (바인드 등록은 확인됨)
2. 56~59번(누를 키 없는 미디어 바인드): 삭제 vs `Super+Shift+←/→` 등으로 교체
3. 61개 바인드 중 keep/change/delete 표시 → `docs/keybind-inventory.md` 번호로 지정
4. 볼륨 2% 스텝 체감 확인
5. 실제 두 번째 머신에 설치해 보기 (가짜 홈 시뮬레이션은 통과했음)

---

## 6. 문제 생기면

```bash
bash ~/dotfiles/diagnose.sh          # 현재 68 pass / 0 warn / 0 fail
hyprctl configerrors                 # 설정 파싱 오류
hyprctl getoption gestures:workspace_swipe_create_new
hyprctl getoption gestures:workspace_swipe_forever
hyprctl binds | grep -c '^bind'      # 현재 61개
```

변경 사항은 `agent/publish-hyprland-dotfiles`에 커밋 후 `main`으로 머지해서
GitHub 기본 브랜치에도 반영한다.
