# dotfiles

> **이 설정은 spidychoipro의 개인 설정입니다.**
> 사용하는 기기, 해상도, 모니터 스케일, 키보드 레이아웃 등이 다르면 그대로 적용하면 의도대로 작동하지 않을 수 있습니다.
> 참고용으로 보고自己的 환경에 맞게 수정해서 쓰세요.

## 내 환경 정보

| 항목 | 값 |
|------|------|
| 배포판 | EndeavourOS (Arch 기반) |
| DE/WM | Hyprland (Wayland) |
| 노트북 | Dell Latitude 7390 |
| 해상도 | 1920x1080 |
| 모니터 스케일 | 1.25 |
| 터미널 | kitty |
| 브라우저 | Brave |
| 파일 매니저 | Thunar |

---

## 폴더 구조

```
dotfiles/
├── brave/                  # Brave 브라우저 설정
│   ├── brave-flags.conf    # 브라우저 플래그 (스케일링 보정 등)
│   └── install-brave-graceful-shutdown.sh
├── fcitx5/                 # FCITX5 한글 입력기 설정
│   └── config              # 한/영 키 매핑
├── hypr/                   # Hyprland 설정
│   └── hyprland.lua
├── kitty/                  # Kitty 터미널 설정 (Dracula 테마)
│   ├── kitty.conf
│   └── current-theme.conf
├── wsl/                    # WSL 전용 설정
│   ├── .zshrc
│   ├── .inputrc
│   ├── setup.sh
│   └── wsl.conf
└── zsh/                    # zsh 설정 (clear 스크롤백 fix 포함)
    └── zshrc
```

---

## WSL 설치 가이드

### 사전 요구사항

- Windows 10/11
- PowerShell (관리자 권한)

### 1단계: WSL + Arch Linux 설치

PowerShell을 **관리자 권한**으로 열고:

```powershell
# WSL 설치
wsl --install

# 재부팅 후, Microsoft Store에서 "Arch Linux" 검색 후 설치
```

Microsoft Store에서 Arch Linux를 열면 유저 이름과 비밀번호를 설정하라는 메시지가 나옵니다.

### 2단계: 기본 패키지 설치

```bash
# 시스템 업데이트
sudo pacman -Syu

# 필요한 것들 설치
sudo pacman -S git curl zsh neovim python nodejs
```

### 3단계: 이 dotfiles 적용

```bash
# 저장소 클론
cd ~
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles

# zsh 설정 복사
cp zsh/zshrc ~/.zshrc
cp wsl/.inputrc ~/.inputrc

# 기본 셸을 zsh로 변경
chsh -s /usr/bin/zsh
```

### 4단계: zsh 플러그인 설치 (선택)

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 5단계: 완료

터미널을 닫고 다시 열면 끝입니다.

---

## 실제 리눅스 (Hyprland) 설치 가이드

### 사전 요구사항

- x86_64 PC (노트북 또는 데스크톱)
- 인터넷 연결
- USB 또는 DVD (부팅용)

### 1단계: EndeavourOS 설치

1. https://endeavouros.com 에서 ISO 다운로드
2. Rufus (Windows) 또는 `dd` (Linux)로 USB에 굽기
3. USB로 부팅 → 화면 안내에 따라 설치
4. 설치 시 **Hyprland** 옵션 선택

### 2단계: 필수 앱 설치

터미널(kitty)에서:

```bash
# Brave 브라우저
sudo pacman -S brave-bin

# Thunar (파일 매니저)
sudo pacman -S thunar exo

# 기타
sudo pacman -S fcitx5 playerctl brightnessctl hyprshot hypridle
```

### 3단계: 이 dotfiles 적용

```bash
# 저장소 클론
cd ~
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles

# Hyprland 설정 복사
mkdir -p ~/.config/hypr
cp hypr/hyprland.lua ~/.config/hypr/hyprland.lua

# Brave 설정 복사
cp brave/brave-flags.conf ~/.config/brave-flags.conf

# Kitty 설정 복사
mkdir -p ~/.config/kitty
cp kitty/kitty.conf ~/.config/kitty/kitty.conf
cp kitty/current-theme.conf ~/.config/kitty/current-theme.conf

# FCITX5 설정 복사
mkdir -p ~/.config/fcitx5
cp fcitx5/config ~/.config/fcitx5/config

# zsh 설정 복사
cp zsh/zshrc ~/.zshrc

# 기본 셸을 zsh로 변경
chsh -s /usr/bin/zsh
```

### 4단계: Hyprland 재시작

```bash
# 설정 리로드 (로그인 상태에서)
hyprctl reload

# 또는 로그아웃 후 다시 로그인
```

---

## Wayland Fractional Scaling 보정

내 모니터 스케일이 `1.25`인데, 이로 인해 Brave나 Thunar 같은 앱의 UI가 이중으로 스케일링되어 아주 크게 보이는 문제가 있었습니다.

### 원리

```
보정 전: 브라우저(1.25x) × 컴포저(1.25x) = 1.56x (매우 큼)
보정 후: 브라우저(0.8x) × 컴포저(1.25x) = 1.0x  (정상)
```

### Brave 보정

`~/.config/brave-flags.conf`에 추가:

```
--force-device-scale-factor=0.8
```

### Thunar 보정

Hyprland 설정에서 Thunar 실행 명령어에 환경변수 추가:

```
env GDK_SCALE=0.8 GDK_DPI_SCALE=0.8 thunar
```

### 주의사항

- `xdg-open` 등 시스템이 브라우저를 직접 실행하면 플래그가 적용되지 않습니다.
- 전역 환경변수로 설정하면 모든 경우에 적용됩니다.
- **모니터 스케일이 1.0이면 이 보정이 필요 없습니다.**

---

## Kitty 테마 (Dracula)

[Dracula](https://draculatheme.com/kitty) 테마 적용 + 커스텀 설정:

- **글꼴**: JetBrainsMono Nerd Font 11pt
- **테마**: Dracula (보라-녹색 계열)
- **투명도**: 92% + `background_opacity`
- **탭 바**: 하단 powerline 스타일
- **커서**: beam (I-beam) 스타일
- **여백**: `window_padding_width 8`

테마 변경하려면:

```bash
kitty +kitten themes
```

---

## FCITX5 한글 설정

### 한/영 키가 안 될 때

`~/.config/fcitx5/config`에서 `TriggerKeys`에 `Hangul` 추가:

```
[Hotkey/TriggerKeys]
0=Control+space
1=Zenkaku_Hankaku
2=Alt+Alt_R
3=Hangul
```

변경 후 fcitx5 재시작:

```bash
fcitx5 -r -d
```

---

## zsh clear 스크롤백 fix

`clear` 명령어가 화면만 지우고 스크롤백이 남아서 위로 스크롤하면 이전 출력이 보이는 문제:

```bash
alias clear='clear && printf "\\033[3J"'
```

`\033[3J`가 스크롤백 버퍼를 함께 초기화합니다.

---

## Neovim

별도 저장소에서 관리합니다:

👉 https://github.com/spidychoipro/neovim-config
