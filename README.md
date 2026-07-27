# dotfiles

> **이 설정은 개인 맞춤 설정입니다.** 그대로 복사하면 의도한 대로 작동하지 않을 수 있으니, 참고용으로만 활용하세요.

## 환경 정보

- **실제 리눅스 설정은 EndeavourOS Hyprland 환경에서 진행되었습니다.**
- ArchLinux 기반 배포에서도 문제 없이 사용 가능할 것으로 예상됩니다.
- WSL 환경과 실제 리눅스(bare metal) 설정은 **다릅니다.** 혼동하지 마세요.

## WSL 설정

WSL Arch Linux 환경 설정 파일들

| 파일 | 용도 |
|------|------|
| `wsl/.zshrc` | WSL 전용 zsh 설정 (Dracula 테마, 플러그인 등) |
| `wsl/.inputrc` | readline 설정 (UTF-8 지원) |
| `wsl/setup.sh` | WSL 초기 셋업 스크립트 |
| `wsl/wsl.conf` | WSL 환경 설정 (드라이브 마운트, 기본 유저 등) |

### WSL Setup 스크립트

```bash
bash setup.sh
```

설치되는 것들:
- zsh + zsh-autosuggestions + zsh-syntax-highlighting (Dracula theme)
- neovim, python, nodejs
- 한국어 UTF-8 로케일

## 실제 리눅스 (bare metal) 설정

### Hyprland

EndeavourOS Hyprland 환경 기반 설정

### File Manager

- Thunar 사용
- Thunar에서 "여기에서 터미널 열기"가 안 될 경우:
  1. `exo` 설치
  2. `thumbler` 설치

## Neovim

Neovim 설정은 별도 저장소에서 관리함

👉 https://github.com/spidychoipro/neovim-config

