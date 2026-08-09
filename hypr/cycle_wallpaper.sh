#!/usr/bin/env bash
# Super+W — anime-* 배경 순환 (심링크 방식: tracked 설정 파일을 수정하지 않음)
# hyprpaper.conf / hyprlock.conf는 고정 경로 ~/.config/hypr/current-wallpaper 를 참조

BG_DIR="$HOME/dotfiles/backgrounds"
SYMLINK="$HOME/.config/hypr/current-wallpaper"
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

ln -sfn "$wp" "$SYMLINK"

hyprctl hyprpaper wallpaper "eDP-1,$wp"

hyprctl notify 1 2500 "rgb(bd93f9)" "배경: $name"
