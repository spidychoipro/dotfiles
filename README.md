# dotfiles

> **개인 설정 파일입니다.** 참고용으로 쓰세요.

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

WSL이 아닌 실제 리눅스 머신용 설정은 아직 없음

> WSL 설정과 실제 리눅스 설정은 **다릅니다.** 혼동하지 마세요.
> - WSL: `wsl/` 폴더 참고
> - 실제 리눅스: 아직 없음

## Neovim

Neovim 설정은 별도 저장소에서 관리함

👉 https://github.com/spidychoipro/neovim-config
