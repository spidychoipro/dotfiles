# Created by newuser for 5.9.2

# 141번(보라색), 212번(분홍색) 드라큘라 시그니처 프롬프트
PROMPT="[%F{141}%n%f@%F{141}%m%f %F{212}%1~%f]$ "

# Korean UTF-8 support (기본은 한글, 에러 메시지만 영어로!)
export LANG=ko_KR.UTF-8
export LC_MESSAGES=en_US.UTF-8

# ==========================================
# [Zsh 자동완성 및 비주얼 메뉴판 최적화]
# ==========================================

# 1. 메뉴판 모듈 로드
zmodload zsh/complist

# 2. 자동완성 상세 규칙 설정
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={a-zA-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=0

# 3. 자동완성 엔진 가동
autoload -Uz compinit
compinit -i

# 4. 메뉴 옵션 켜기 및 ls 색상 켜기
setopt AUTO_MENU
setopt CORRECT
setopt CORRECT_ALL
alias ls='ls --color=auto'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ==========================================
# [외부 플러그인 및 테마 로드]
# ==========================================

# 자동제안 플러그인 먼저 로드
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


# ★ [핵심] 공식 가이드 지침: zsh-syntax-highlighting 로드 "직전"에 Dracula 테마 로드
if [ -f ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.sh ]; then
  source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.sh
fi

# 구문 강조 플러그인 최종 로드
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==========================================
# [Neovim WSL 환경 설정]
# ==========================================

unalias nvim 2>/dev/null
nvim() {
  command /usr/bin/nvim \
    --cmd 'luafile /mnt/c/Users/swpar/AppData/Local/nvim/lua/utils/wsl-terminal.lua' \
    "$@"
}
