#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
CONFIG="$HOME/.config"

echo "dotfiles 설치 시작..."

mkdir -p "$CONFIG/hypr" "$CONFIG/swaync" "$CONFIG/fcitx5" "$CONFIG/kitty" "$CONFIG/rofi" "$CONFIG/waybar" "$CONFIG/backgrounds" "$CONFIG/fastfetch" "$CONFIG/xsettingsd" "$CONFIG/yad"

ln -sf "$DOTFILES/hypr/hyprland.lua"       "$CONFIG/hypr/hyprland.lua"
ln -sf "$DOTFILES/hypr/hypridle.conf"       "$CONFIG/hypr/hypridle.conf"
ln -sf "$DOTFILES/hypr/hyprlock.conf"       "$CONFIG/hypr/hyprlock.conf"
ln -sf "$DOTFILES/hypr/hyprpaper.conf"      "$CONFIG/hypr/hyprpaper.conf"
ln -sf "$DOTFILES/hypr/hyprlauncher.conf"   "$CONFIG/hypr/hyprlauncher.conf"
ln -sf "$DOTFILES/hypr/hyprtoolkit.conf"    "$CONFIG/hypr/hyprtoolkit.conf"
ln -sf "$DOTFILES/hypr/toggle_window_layout.sh" "$CONFIG/hypr/toggle_window_layout.sh"
ln -sf "$DOTFILES/hypr/toggle_term.sh"           "$CONFIG/hypr/toggle_term.sh"
ln -sf "$DOTFILES/swaync/config.json"       "$CONFIG/swaync/config.json"
ln -sf "$DOTFILES/swaync/style.css"         "$CONFIG/swaync/style.css"
ln -sf "$DOTFILES/backgrounds"/*            "$CONFIG/backgrounds/"
ln -sf "$DOTFILES/fcitx5/config"            "$CONFIG/fcitx5/config"
ln -sf "$DOTFILES/kitty/kitty.conf"         "$CONFIG/kitty/kitty.conf"
ln -sf "$DOTFILES/kitty/current-theme.conf" "$CONFIG/kitty/current-theme.conf"
ln -sf "$DOTFILES/waybar"/*                 "$CONFIG/waybar/"
ln -sf "$DOTFILES/rofi/config.rasi"         "$CONFIG/rofi/config.rasi"
ln -sf "$DOTFILES/fastfetch"/*              "$CONFIG/fastfetch/"
ln -sf "$DOTFILES/zsh/zshrc"               "$HOME/.zshrc"
ln -sf "$DOTFILES/starship/starship.toml"   "$CONFIG/starship.toml" 2>/dev/null || true
ln -sf "$DOTFILES/brave/brave-flags.conf"   "$CONFIG/brave-flags.conf" 2>/dev/null || true
ln -sf "$DOTFILES/gtkrc"                    "$CONFIG/gtkrc"
ln -sf "$DOTFILES/gtkrc-2.0"                "$CONFIG/gtkrc-2.0"
ln -sf "$DOTFILES/Trolltech.conf"           "$CONFIG/Trolltech.conf"
ln -sf "$DOTFILES/EOS-greeter.conf"         "$CONFIG/EOS-greeter.conf"
ln -sf "$DOTFILES/mimeapps.list"            "$CONFIG/mimeapps.list"
ln -sf "$DOTFILES/xsettingsd/xsettingsd.conf" "$CONFIG/xsettingsd/xsettingsd.conf"
ln -sf "$DOTFILES/yad/settings.conf"        "$CONFIG/yad/settings.conf"

[ "$SHELL" != "/usr/bin/zsh" ] && chsh -s /usr/bin/zsh && echo "shell changed to zsh, re-login required"

echo "done! run: hyprctl reload"
