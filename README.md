# 🧛 dotfiles — Hyprland + Dracula Desktop

> spidychoipro의 Hyprland / EndeavourOS 데스크탑 환경을 그대로 가져다 쓰세요!

![Hyprland](https://img.shields.io/badge/WM-Hyprland-ff79c6)
![Theme](https://img.shields.io/badge/Theme-Dracula-bd93f9)
![OS](https://img.shields.io/badge/OS-EndeavourOS-50fa7b)

---

## 🚀 1초 설치

터미널만 열 수 있다면 누구나!

```bash
git clone https://github.com/spidychoipro/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

끝입니다. 진짜 끝이에요.  
`install.sh`가 설정 파일들을 심볼릭 링크로 자동 연결해 줍니다.

**설치 후** `hyprctl reload` 하거나 **재로그인** 하면 적용됩니다.

---

## 📋 설치 전 준비물

아래 프로그램이 설치되어 있어야 해요:

| 필요한 것 | 왜 필요하냐면... |
|-----------|----------------|
| **Hyprland** | 윈도우 매니저 본체 |
| **kitty** | 터미널 (없으면 `$TERMINAL`로 fallback) |
| **waybar** | 상단 상태바 |
| **rofi** | 앱 실행기 (`Super+Space`) |
| **swaync** | 🔔 알림 센터 (Dracula 스타일) |
| **cliphist** | 📋 클립보드 히스토리 (`Super + V`) |
| **swayosd** | 🔊 볼륨/밝기 OSD |
| **fcitx5** | 한글 입력 |
| **hyprlock + hypridle** | 잠금화면 + 자동 절전 |
| **hyprpaper** | 배경화면 |
| **starship** | 예쁜 터미널 프롬프트 |
| **Brave** | 기본 브라우저 |

> 💡 **꼭 다 있을 필요는 없어요.** 없으면 해당 기능만 동작하지 않을 뿐, 나머지는 잘 작동합니다.

---

## 🎨 이렇게 생겼어요

```
┌─────────────────────────────────────────────┐
│        01:02    24°C          07/30  │  ← Waybar
├─────────────────────────────────────────────┤
│                                             │
│         ┌──────────────────────┐            │
│         │                      │            │
│         │                      │            │
│         │                      │            │
│         │        kitty         │            │
│         │                      │            │
│         │                      │            │
│         └──────────────────────┘            │
│                                             │
│                                           │
│   Brave                                  fcitx5│
└─────────────────────────────────────────────┘
```

- 🎨 **Dracula** 컬러 (`#282A36` 배경, `#FF79C6` 포인트, `#BD93F9` 강조)
- 🔠 **JetBrainsMono Nerd Font** + **Noto Sans CJK KR**
- 🪟 **Master/Dwindle** 레이아웃 자유 전환
- 🖱️ **트랙패드** 자연스크롤 + 3손가락 제스처

---

## ⌨️ 키보드 단축키

### 기본 조작

| 키 | 기능 |
|---|---|
| `Super + Q` | 터미널 열기 |
| `Super + C` | 창 닫기 |
| `Super + Enter` | Master 레이아웃: 포커스된 창을 Master로 교체 |
| `Super + F` | 전체화면 (토글) |
| `Super + V` | **클립보드 히스토리** (cliphist → rofi로 검색/붙여넣기) |
| `Super + P` | Pseudo 타일링 전환 |

### 창 이동 (VIM 스타일)

| 키 | 기능 |
|---|---|
| `Super + h/j/k/l` | 포커스를 ←↓↑→ 로 이동 |
| `Super + Shift + h/j/k/l` | 창 위치를 ←↓↑→ 로 교체 (**swap**) |

### 레이아웃 전환

| 키 | 기능 |
|---|---|
| `Super + Shift + T` | **Dwindle** ↔ **Master** 레이아웃 전환 |
| `Super + Shift + T` 후 `Super + h/j/k/l` | Master 레이아웃에서 자유롭게 창 배치 |

### 작업공간

| 키 | 기능 |
|---|---|
| `Super + 1~0` | 작업공간 1~10 이동 |
| `Super + Shift + 1~0` | 창을 작업공간 1~10으로 이동 |
| `Super + S` | 특수 작업공간 (스크래치패드) 토글 |

### 실행 / 시스템

| 키 | 기능 |
|---|---|
| `Super + Space` | **Rofi** 앱 실행기 |
| `Super + E` | 파일 관리자 |
| `Super + I` | 시스템 설정 |
| `Super + B` | Brave 브라우저 |
| `Super + M` | 시스템 종료 메뉴 |
| `Super + Alt + L` | **잠금화면** |
| `Super + Print` | 현재 창 스크린샷 |
| `Super + Shift + S` | 영역 선택 스크린샷 |

### 트랙패드 제스처

| 제스처 | 기능 |
|---|---|
| 세 손가락 좌우 스와이프 | 작업공간 이동 |
| 두 손가락 스크롤 | 자연스크롤 |
| 탭 | 왼쪽 클릭 |
| 두 손가락 탭 | 오른쪽 클릭 |

---

## 🛡️ 잠금화면 (hyprlock)

```
        ●   ← 분홍색 잠금 표시
     14:30   ← 큰 시계
  Monday, July 30   ← 날짜

   [비밀번호 입력]   ← 둥근 입력창
```

- 어두운 Dracula 배경 + 블러
- 5분 자동 잠금 → 10분 자동 절전
- `Super + Alt + L`로 수동 잠금

---

## 📋 클립보드 히스토리 (cliphist)

`Super + V`를 누르면 Rofi로 클립보드 히스토리가 뜹니다.  
방금 복사한 거, 몇 분 전에 복사한 거까지 검색해서 골라 붙여넣기 가능.

```
설치: sudo pacman -S cliphist
```

## 🔔 알림 센터 (swaync)

알림이 오면 오른쪽 상단에 **340px 미니멀 Dracula 카드**가 뜹니다.  
마우스를 오른쪽 상단 끝으로 밀면 알림 센터 패널이 열립니다.

### 알림 센터 구성

```
┌──────────────────────────────┐
│  Notifications      [Clear]  │  ← 제목 + 전체 삭제
│──────────────────────────────│
│  ● Silent                    │  ← 방해금지 토글
│──────────────────────────────│
│    Brave                   │  ← 앱별 그룹
│  페이지가 로드되었습니다      │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│    kitty                   │
│  명령 실행 완료               │
│                              │
│        ↑ 드래그 가능          │
└──────────────────────────────┘
```

### 주요 기능

| 기능 | 설명 |
|---|---|
| 알림 그룹화 | 같은 앱 알림은 자동으로 묶임 |
| 방해금지 모드 | `Silent` 토글 버튼으로 알림 일시 차단 |
| 전체 삭제 | `Clear` 버튼으로 모든 알림 한 번에 제거 |
| 자동 사라짐 | 일반 6초 / 낮음 3초 후 자동 종료 |

### 커스터마이징

- 설정 파일: `~/.config/swaync/config.json`
- 스타일: `~/.config/swaync/style.css` (Dracula 기본 적용)
- 너비/높이, 위치, 색상, 투명도 모두 자유롭게 수정 가능

---

## 🧩 구성 파일 구조

```
dotfiles/
├── install.sh              ← 🚀 설치 스크립트 (이거만 실행!)
├── backgrounds/            ← 배경화면 이미지
├── hypr/                   ← Hyprland 핵심 설정
│   ├── hyprland.lua        ← 메인 (Lua 설정)
│   ├── hypridle.conf       ← 자동 잠금/절전
│   ├── hyprlock.conf       ← 잠금화면 디자인
│   ├── hyprpaper.conf      ← 배경화면
│   ├── hyprlauncher.conf   ← Hyprlauncher (참고용)
│   ├── hyprtoolkit.conf    ← Hyprtoolkit Dracula 테마
│   ├── toggle_window_layout.sh ← 레이아웃 전환 스크립트
│   └── diagnose.sh             ← ⚕️ 오프라인 시스템 진단 스크립트
├── swaync/                 ← 알림 센터 (Dracula 미니멀 340px)
│   ├── config.json         ← 설정
│   └── style.css           ← Dracula 스타일
├── kitty/                  ← 터미널 (Dracula)
├── rofi/                   ← 앱 실행기 (Dracula)
├── waybar/                 ← 상태바
├── starship/               ← 터미널 프롬프트
├── zsh/                    ← Zsh 설정
├── fcitx5/                 ← 한글 입력기
└── brave/                  ← Brave 스케일링 보정
```

---

## 🤲 수동 설치 (백업 + 복사 방식)

install.sh가 부담스럽다면 직접 복사할 수도 있어요.  
기존 설정은 자동으로 백업됩니다.

```bash
cd ~
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles

# 백업 + 복사 한 방에!
backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
for app in hypr waybar rofi swaync; do
  [ -e "$HOME/.config/$app" ] && mv "$HOME/.config/$app" "$backup_dir/"
done

mkdir -p ~/.config
cp -a hypr waybar rofi swaync ~/.config/
hyprctl reload
```

> 이전 설정은 `~/.config-backup-20240730-xxxxxx` 폴더에 안전하게 보관됩니다.

---

## ❓ 자주 묻는 질문

**Q: Hyprland가 뭔가요?**  
Wayland 위에서 동작하는 가볍고 예쁜 윈도우 매니저예요.

**Q: 한글 입력이 안 돼요**  
`fcitx5-configtool` 실행해서 Addons > Wayland 지원이 켜져 있는지 확인하세요.  
한/영 전환은 **Hangul 키** 또는 **Ctrl+Space**입니다.

**Q: 1.25x 스케일링이 안 맞아요**  
모니터 설정(`hyprland.lua`의 `monitor` 줄)에서 `@1.25x` 부분을  
자신의 모니터에 맞게 수정하세요.

**Q: 배경화면이 안 보여요**  
`~/.config/backgrounds/` 폴더에 이미지 파일이 있는지 확인하세요.  
없으면 hyprpaper가 실행되지 않습니다.

**Q: `./install.sh` 실행 권한이 없다고 나와요**  
```bash
chmod +x ~/dotfiles/install.sh
```

---

##  Neovim 설정

함께 쓰는 Neovim 설정입니다. 아래 순서대로 따라 하면 끝.

```bash
# 1. Neovim 저장소에서 리눅스 설정을 가져오기
git clone https://github.com/spidychoipro/neovim-config.git ~/.config/nvim

# 2. Treesitter CLI 설치 (문법 강조 + 코드 분석용)
sudo pacman -S tree-sitter-cli

# 3. Neovim 실행 → 자동 플러그인 설치
nvim
```

> Treesitter CLI가 없으면 문법 하이라이팅이 안 되거나 속도가 느릴 수 있어요.

---

## 📝 기타

- 라이선스: [MIT](LICENSE)

---

⭐ 마음에 드셨다면 Star를 눌러주세요!
