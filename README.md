# dotfiles

> spidychoipro의 Hyprland + EndeavourOS 설정

## 1 click install

```bash
cd ~
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh`가 자동으로:
- hypr 설정 복사
- Waybar와 Rofi 설정 복사
- fcitx5 한글 설정 복사
- kitty 설정 복사
- zsh 설정 복사
- zsh를 기본 셸로 변경

**설치 후 재로그인 또는 `hyprctl reload`**

---

## 내 환경

| 항목 | 값 |
|------|------|
| 배포판 | EndeavourOS |
| WM | Hyprland (Wayland) |
| 디스플레이 | 1920x1080 @ 1.25x scale |
| 터미널 | kitty |
| 브라우저 | Brave |
| 한글 입력기 | Fcitx5 (Wayland native) |

## 폴더 구조

```
dotfiles/
├── install.sh              # 설치 스크립트
├── backgrounds/            # 배경화면
├── brave/                  # Brave flags (스케일링 보정)
├── fcitx5/                 # Fcitx5 한글 설정
├── hypr/                   # Hyprland 설정
│   ├── hyprland.lua        # 메인 설정
│   ├── hypridle.conf       # 절전
│   ├── hyprlock.conf       # 잠금화면
│   ├── hyprpaper.conf      # 배경화면
│   ├── hyprlauncher.conf   # Hyprlauncher 설정
│   └── hyprtoolkit.conf    # Dracula 테마
├── kitty/                  # Kitty 터미널 (Dracula)
├── rofi/                   # Rofi 앱 런처 (Dracula 미니멀 테마)
├── starship/               # Starship prompt
├── waybar/                 # Waybar 상태바와 모듈 스크립트
└── zsh/                    # Zsh 설정
```

## 수동 설치 (복사 방식)

심볼릭 링크 대신 파일을 직접 복사하고 싶다면 아래 블록 전체를 그대로 붙여넣으세요.
기존 설정은 `~/.config-backup-날짜` 폴더에 백업됩니다.

```bash
cd ~
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles

backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
for app in hypr waybar rofi; do
  [ -e "$HOME/.config/$app" ] && mv "$HOME/.config/$app" "$backup_dir/"
done

mkdir -p ~/.config
cp -a hypr ~/.config/
cp -a waybar ~/.config/
cp -a rofi ~/.config/
hyprctl reload
```

Rofi는 `Super + Space`로 열며, `Ctrl-j` / `Ctrl-k`로 결과를 이동하고 `Enter`로 실행합니다.

## 주요 설정

### 한글 입력 (Fcitx5 + Wayland)

- `GTK_IM_MODULE` 미설정 → Wayland text-input-v3 프로토콜 사용
- `QT_IM_MODULE=fcitx` → Qt 앱은 IM module로 동작
- 한/영 키: **Hangul** 키, **Ctrl+Space**
- 문제 발생 시: `fcitx5-configtool`에서 Addons > Wayland 활성화 확인

### 창 간격 (Gaps)

- `gaps_in = 20, gaps_out = 40`

### 모니터 스케일 보정 (1.25x)

| 앱 | 방법 |
|------|--------|
| Brave | `brave-flags.conf`에 `--force-device-scale-factor=0.8` |
| Thunar | 실행 명령: `env GDK_SCALE=0.8 GDK_DPI_SCALE=0.8 thunar` |

---

기타: [Neovim config](https://github.com/spidychoipro/neovim-config)
