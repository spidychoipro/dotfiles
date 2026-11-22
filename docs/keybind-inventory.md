# 키바인드 인벤토리 (현재 59개)

> 기준: `hypr/hyprland.lua`, 2026-11-22. **검토용 목록 — 아직 바인드를 바꾸지 않았다.**
> 사용법: 번호로 "쓰는 것 / 안 쓰는 것 / 바꾸고 싶은 것"을 알려주세요.
> 예) `1~8, 18~25, 50~59 쓰고 / 13,16,17 삭제 / 9는 Super+Shift+P로 변경`

## 결정된 정책 (이번 확인 반영)

- **창 전환**: `Super+h/j/k/l` + 워크스페이스 이동으로 충분. 새 바인드(MRU/rofi 스위처) 없음.
- **워크스페이스**: 역할 라벨 없이 1~10 자유 사용. 자동 배치 없음, 앱은 열린 곳에 유지.
- **스크래치패드/드롭다운/Quickshell**: 없음, 재추가 금지.

---

## 1. 기본 (8개)

| # | 키 | 동작 |
|---|----|------|
| 1 | `Super+Q` | 터미널(kitty) 열기 |
| 2 | `Super+C` | 창 닫기 |
| 3 | `Super+M` | 세션 종료 (`hyprshutdown` → fallback exit) |
| 4 | `Super+E` | 파일 관리자(thunar) |
| 5 | `Super+V` | 클립보드 히스토리 (cliphist → rofi → 붙여넣기) |
| 6 | `Super+F` | 전체화면 토글 |
| 7 | `Super+Space` | 앱 러너 (rofi drun) |
| 8 | `Super+P` | 의사 타일링(pseudo) 토글 |

## 2. 캡처 / 시스템 / 앱 (9개)

| # | 키 | 동작 |
|---|----|------|
| 9 | `Print` | 현재 창 캡처 (hyprshot -m window) |
| 10 | `Super+Shift+S` | 영역 캡처 (hyprshot -m region) |
| 11 | `Super+Alt+L` | 잠금화면 (hyprlock) |
| 12 | `Super+Shift+T` | 레이아웃 전환 (dwindle ↔ master) |
| 13 | `Super+I` | 시스템 설정 (QT_SCALE_FACTOR=0.8) |
| 14 | `Super+B` | Brave 실행 |
| 15 | `Super+W` | 배경화면 순환 |
| 16 | `Super+Shift+M` | Spotify 실행 |
| 17 | `Super+D` | PDF 열기 (rofi 선택 → zathura) |

## 3. 포커스 / 창 스왑 (8개)

| # | 키 | 동작 |
|---|----|------|
| 18 | `Super+H` | 포커스 ← |
| 19 | `Super+J` | 포커스 ↓ |
| 20 | `Super+K` | 포커스 ↑ |
| 21 | `Super+L` | 포커스 → |
| 22 | `Super+Shift+H` | 창 스왑 ← |
| 23 | `Super+Shift+J` | 창 스왑 ↓ |
| 24 | `Super+Shift+K` | 창 스왑 ↑ |
| 25 | `Super+Shift+L` | 창 스왑 → |

## 4. 워크스페이스 (20개)

| # | 키 | 동작 |
|---|----|------|
| 26~35 | `Super+1` ~ `Super+0` | 해당 워크스페이스로 이동 (`0` = ws10) |
| 36~45 | `Super+Shift+1` ~ `Super+Shift+0` | 현재 창을 해당 워크스페이스로 이동 |

## 5. 마우스 (4개)

| # | 키 | 동작 |
|---|----|------|
| 46 | `Super+휠 다운` | 다음 워크스페이스 |
| 47 | `Super+휠 업` | 이전 워크스페이스 |
| 48 | `Super+좌클릭 드래그` | 창 이동 |
| 49 | `Super+우클릭 드래그` | 창 크기 조절 |

## 6. 트랙패드 제스처 (바인드 아님)

| 동작 | 확인 방법 |
|------|-----------|
| 3손가락 좌우 스와이프 | **열려 있는 워크스페이스만 순환** (1↔2 왕복, 빈 3번 안 생김) |

> `Super+휠`이 트랙패드에서 불편하면 이 제스처를 쓰면 된다.
> `gestures.workspace_swipe_create_new = false` + `workspace_swipe_forever = true` 로
> 마지막 워크스페이스에서 처음으로 돌아오게 고쳤다.
> 키보드 대안이 필요하면 `Super+←/→`가 현재 비어 있다 (아직 바인드 안 함).

## 7. 멀티미디어 (10개, 잠금화면에서도 동작)

> 물리 키는 Dell 기술 가이드(Table 66, Latitude 7290/7390 Hot Key combinations) 기준.
> 50~55번만 이 노트북에서 실제로 누를 수 있다.
> keysym을 직접 확인: 터미널에서 `xkbcli interactive-wayland -1` 실행 후 키를 누르면
> `XF86AudioNext`처럼 출력된다.

| # | 물리 키 | keysym | 동작 | 확인 방법 |
|---|---------|--------|------|-----------|
| 50 | `Fn+F3` (스피커+) | `XF86AudioRaiseVolume` | 볼륨 업 (2%씩) | 화면에 swayosd OSD |
| 51 | `Fn+F2` (스피커-) | `XF86AudioLowerVolume` | 볼륨 다운 (2%씩) | 화면에 swayosd OSD |
| 52 | `Fn+F1` (스피커X) | `XF86AudioMute` | 음소거 | 화면에 swayosd OSD |
| 53 | `Fn+F4` (마이크X) | `XF86AudioMicMute` | 마이크 음소거 | 화면에 swayosd OSD |
| 54 | `Fn+↑` | `XF86MonBrightnessUp` | 밝기 업 | 화면 밝기 변화 |
| 55 | `Fn+↓` | `XF86MonBrightnessDown` | 밝기 다운 | 화면 밝기 변화 |
| 56 | **없음** | `XF86AudioNext` | 다음 트랙 | 이 노트북에 물리 키 없음 |
| 57 | **없음** | `XF86AudioPause` | 일시정지 | 이 노트북에 물리 키 없음 |
| 58 | **없음** | `XF86AudioPlay` | 재생 | 이 노트북에 물리 키 없음 |
| 59 | **없음** | `XF86AudioPrev` | 이전 트랙 | 이 노트북에 물리 키 없음 |

> **56~59번은 누를 키가 없다.** Dell 기술 가이드의 Latitude 7390 Hot Key 표에는
> 재생/일시정지/이전/다음 곡에 해당하는 Fn 조합이 없다. udev hwdb의
> `KEYBOARD_KEY_81~84=playpause/stopcd/previoussong/nextsong` 은 **다른 Dell 모델의 전면 패널 버튼**
> 용 일반 매핑이라 이 모델에는 해당 키가 없다. 외부 Dell 키보드/독을 물리면 동작할 수는 있다.
>
> 설령 키가 있어도 `playerctl`을 쓰므로 **재생 중인 플레이어(Spotify 등)가 없으면 아무 일도 안 일어난다.**
> 56~59번을 실제로 쓰고 싶으면 `Super+Shift+←/→` 같은 누를 수 있는 조합으로 바꿔야 한다.

---

## 참고

- 총개수는 `hyprctl binds | grep -c '^bind'` (= 59)와 일치해야 한다.
- 바인드 추가/제거 후에는 이 문서와 `README.md`의 키바인드 표를 함께 갱신한다.
- 한글 입력 전환(`한/영`, 우측 Alt, `Ctrl+Space`)은 Hyprland 바인드가 아니라 fcitx5 설정이라 이 목록에 없다.
