#!/bin/bash
p=$(find "$HOME/문서" "$HOME/다운로드" "$HOME/프로젝트" -iname "*.pdf" -type f 2>/dev/null)
if [ -z "$p" ]; then
  hyprctl notify 2 3000 "rgb(6272a4)" "PDF가 없습니다: 문서/다운로드/프로젝트에 넣어주세요"
  zathura
else
  f=$(printf "%s\n" "$p" | rofi -dmenu -p PDF) && [ -n "$f" ] && zathura "$f"
fi
