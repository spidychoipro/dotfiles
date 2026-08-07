#!/usr/bin/env bash
# Super+W — anime-* 배경 순환 (hyprpaper 즉시 적용 + hyprpaper/hyprlock.conf 동기화)

BG_DIR="$HOME/dotfiles/backgrounds"
STATE="$HOME/.cache/hypr-wallpaper-idx"

mapfile -t wps < <(find "$BG_DIR" -maxdepth 1 -type f -name "anime-*" | sort)
if [ "${#wps[@]}" -lt 2 ]; then
    hyprctl notify 2 3000 "rgb(ff5555)" "배경 순환 불가: backgrounds/anime-* 파일이 1개 이하"
    exit 0
fi

idx=$(cat "$STATE" 2>/dev/null || echo 0)
idx=$(( (idx + 1) % ${#wps[@]} ))
echo "$idx" > "$STATE"

wp="${wps[$idx]}"
name="$(basename "$wp")"

hyprctl hyprpaper wallpaper "eDP-1,$wp"

sed -i "s|path = /home/hoco30/.config/backgrounds/anime-.*|path = /home/hoco30/.config/backgrounds/$name|" "$HOME/.config/hypr/hyprpaper.conf"
sed -i "s|path = ~/.config/backgrounds/anime-.*|path = ~/.config/backgrounds/$name|" "$HOME/.config/hypr/hyprlock.conf"

hyprctl notify 1 2500 "rgb(bd93f9)" "배경: $name"
