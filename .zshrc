# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Prompt
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# Enable colored completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# Key bindings for Unicode/UTF-8 input
bindkey -e

# Korean UTF-8 support
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
