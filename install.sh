#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "dotfiles 설치 시작... (source: $DOTFILES, config: $CONFIG)"

# 이미 올바르게 연결돼 있으면 아무것도 하지 않는다.
# 상위 디렉터리 자체가 dotfiles 쪽 심링크인 경우도 같은 파일로 해석되어 건너뛴다.
link_file() {
    local src="$1" dst="$2"
    [ -e "$src" ] || { echo "  ! 없음: $src"; return 0; }
    mkdir -p "$(dirname "$dst")"
    if [ "$(readlink -f "$dst" 2>/dev/null || true)" = "$(readlink -f "$src")" ]; then
        return 0
    fi
    rm -f "$dst"
    ln -s "$src" "$dst"
}

# 설정 디렉터리는 통째로 심링크해 누락 파일이 없도록 한다.
# 기존 실제 디렉터리가 비어 있으면 교체, 내용이 있으면 사용자 데이터 보호를 위해 유지.
link_dir() {
    local src="$1" dst="$2"
    [ -d "$src" ] || { echo "  ! 없음: $src"; return 0; }
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        if [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then return 0; fi
        rm -f "$dst"
    elif [ -d "$dst" ]; then
        if [ -z "$(ls -A "$dst")" ]; then
            rmdir "$dst"
        else
            echo "  ! 기존 디렉터리 유지 (비어 있지 않음): $dst"
            return 0
        fi
    fi
    ln -s "$src" "$dst"
}

# ─── 설정 디렉터리 ───────────────────────────────────────
for d in hypr swaync kitty waybar rofi fastfetch backgrounds zathura; do
    link_dir "$DOTFILES/$d" "$CONFIG/$d"
done

# ─── 개별 파일 ───────────────────────────────────────────
link_file "$DOTFILES/zsh/zshrc"               "$HOME/.zshrc"
link_file "$DOTFILES/starship/starship.toml"  "$CONFIG/starship.toml"
link_file "$DOTFILES/brave/brave-flags.conf"  "$CONFIG/brave-flags.conf"
link_file "$DOTFILES/gtkrc"                   "$CONFIG/gtkrc"
link_file "$DOTFILES/gtkrc-2.0"               "$CONFIG/gtkrc-2.0"
link_file "$DOTFILES/Trolltech.conf"          "$CONFIG/Trolltech.conf"
link_file "$DOTFILES/EOS-greeter.conf"        "$CONFIG/EOS-greeter.conf"
link_file "$DOTFILES/mimeapps.list"           "$CONFIG/mimeapps.list"
link_file "$DOTFILES/xsettingsd/xsettingsd.conf" "$CONFIG/xsettingsd/xsettingsd.conf"
link_file "$DOTFILES/yad/settings.conf"       "$CONFIG/yad/settings.conf"

# ─── 배경 심링크 ─────────────────────────────────────────
# current-wallpaper는 gitignore 대상이므로 clone 후에는 없다.
if [ ! -e "$CONFIG/hypr/current-wallpaper" ]; then
    first_wp=$(find "$DOTFILES/backgrounds" -maxdepth 1 -type f \
        \( -name 'anime-*' -o -name '*.png' -o -name '*.jpg' -o -name '*.webp' \) \
        2>/dev/null | sort | head -1)
    if [ -n "$first_wp" ]; then
        ln -sfn "$first_wp" "$CONFIG/hypr/current-wallpaper"
        echo "  → 기본 배경 지정: $(basename "$first_wp")"
    else
        echo "  ! 배경 파일이 없음 — ~/dotfiles/backgrounds/ 에 이미지를 넣어주세요"
    fi
fi

# ─── fcitx5 (한글 입력) ──────────────────────────────────
# 실행 중인 fcitx5가 conf/hangul.conf를 저장할 때 tracked 파일이 덮어써지는 것을 막기 위해
# fcitx5 설정은 실제 디렉터리 + 복사본으로 분리한다.
if [ -L "$CONFIG/fcitx5" ]; then
    rm -f "$CONFIG/fcitx5"
fi
mkdir -p "$CONFIG/fcitx5/conf"
for f in config profile classicui.conf hangul.conf notifications.conf; do
    [ -f "$DOTFILES/fcitx5/$f" ] && cp -f "$DOTFILES/fcitx5/$f" "$CONFIG/fcitx5/$f"
done
for f in hangul.conf notifications.conf; do
    [ -f "$DOTFILES/fcitx5/conf/$f" ] && cp -f "$DOTFILES/fcitx5/conf/$f" "$CONFIG/fcitx5/conf/$f"
done
# fcitx5/conf/hangul.conf를 수정했다면 install.sh 재실행 후 fcitx5-remote -r 필요

# ─── swayosd ─────────────────────────────────────────────
# swayosd는 TOML의 ~ 를 확장하지 않으므로 설치 시 절대경로로 렌더한다.
mkdir -p "$CONFIG/swayosd"
if [ -f "$DOTFILES/swayosd/config.toml" ]; then
    sed "s|@CONFIG_DIR@|$CONFIG|g" "$DOTFILES/swayosd/config.toml" > "$CONFIG/swayosd/config.toml"
fi
link_file "$DOTFILES/swayosd/style.css" "$CONFIG/swayosd/style.css"

# ─── 셸 ──────────────────────────────────────────────────
[ "$SHELL" != "/usr/bin/zsh" ] && chsh -s /usr/bin/zsh && echo "shell changed to zsh, re-login required"

# ─── Thunar 다크모드/렌더링 수정 ────────────────────────
bash "$DOTFILES/thunar-fix/install.sh" || echo "thunar-fix 실패 — 수동 실행: bash $DOTFILES/thunar-fix/install.sh"

echo "done!"
echo "적용: hyprctl reload"
echo "      pkill -x hyprpaper && setsid hyprpaper >/dev/null 2>&1 &   # hyprpaper.conf 재읽기"
echo "      fcitx5-remote -r && fcitx5-remote -s hangul                # 한글 입력기 재활성화"
echo "참고: backgrounds/anime-* 는 gitignore라 clone에는 포함되지 않습니다. 별도 복사 필요."
