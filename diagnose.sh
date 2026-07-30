#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
header() { echo -e "\n${BOLD}$1${NC}"; echo "──────────────────────"; }

HYPR="$HOME/.config/hypr"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# ─── System ──────────────────────────────────────────────
header "System"
echo "  Host:  $(uname -n)"
echo "  OS:    $(. /etc/os-release 2>/dev/null && echo "$NAME $VERSION_ID" || echo "unknown")"
echo "  Kernel: $(uname -r)"
echo "  DE:    ${XDG_CURRENT_DESKTOP:-none}"
echo "  Session: ${HYPRLAND_INSTANCE_SIGNATURE:-not in Hyprland}"

# ─── Essentials (offline) ────────────────────────────────
header "Essential Packages"

packages=(
  hyprland hyprlock hypridle hyprpaper
  kitty waybar swaync rofi
  swayosd
  cliphist wl-clipboard brightnessctl
  fcitx5 fcitx5-hangul
  starship
  pipewire pipewire-pulse wireplumber
  noto-fonts-cjk ttf-jetbrains-mono-nerd
)

for pkg in "${packages[@]}"; do
  if pacman -Qi "$pkg" &>/dev/null 2>&1; then
    pass "$pkg"
  else
    warn "$pkg (not installed)"
  fi
done

# ─── XDG Directories ──────────────────────────────────────
header "Config Directories"

dirs=(hypr swaync swayosd kitty waybar rofi fcitx5 backgrounds)
for d in "${dirs[@]}"; do
  if [ -d "$HOME/.config/$d" ]; then
    pass "$HOME/.config/$d"
  else
    fail "$HOME/.config/$d (missing)"
  fi
done

# ─── Config Files & Symlinks ─────────────────────────────
header "Config Files"

files=(
  hypr/hyprland.lua
  hypr/hypridle.conf
  hypr/hyprlock.conf
  hypr/hyprpaper.conf
  hypr/hyprlauncher.conf
  hypr/hyprtoolkit.conf
  hypr/toggle_window_layout.sh
  hypr/toggle_term.sh
  swaync/config.json
  swaync/style.css
  swayosd/config.toml
  swayosd/style.css
  kitty/kitty.conf
  kitty/current-theme.conf
  waybar/config.jsonc
  waybar/style.css
  rofi/config.rasi
  starship.toml
  brave-flags.conf
)

for f in "${files[@]}"; do
  target="$HOME/.config/$f"
  if [ -L "$target" ]; then
    link=$(readlink "$target")
    if [ "$link" = "$DOTFILES/$f" ] || [ "$link" = "$DOTFILES/${f#hypr/}" ]; then
      pass "$f (→ dotfiles)"
    else
      warn "$f (symlink → $link)"
    fi
  elif [ -f "$target" ]; then
    pass "$f (direct file)"
  else
    fail "$f (not found)"
  fi
done

# Additional check: starship.toml lives directly in $CONFIG
if [ -L "$HOME/.config/starship.toml" ]; then
  link=$(readlink "$HOME/.config/starship.toml")
  [ "$link" = "$DOTFILES/starship/starship.toml" ] && pass "starship.toml (→ dotfiles)" || warn "starship.toml (→ $link)"
elif [ -f "$HOME/.config/starship.toml" ]; then
  pass "starship.toml"
fi

# ─── Script Permissions ──────────────────────────────────
header "Script Permissions"

for script in toggle_window_layout.sh toggle_term.sh diagnose.sh; do
  f="$HYPR/$script"
  if [ -f "$f" ]; then
    [ -x "$f" ] && pass "$script (+x)" || warn "$script (missing +x)"
  fi
done

if [ -f "$DOTFILES/diagnose.sh" ]; then
  [ -x "$DOTFILES/diagnose.sh" ] || warn "diagnose.sh in dotfiles (missing +x)"
fi

# ─── Running Processes ───────────────────────────────────
header "Running Processes"

procs=(Hyprland hyprlock hypridle waybar swaync swayosd-server fcitx5)
for p in "${procs[@]}"; do
  if pgrep -x "$p" &>/dev/null; then
    pass "$p"
  else
    warn "$p (not running)"
  fi
done

if pgrep -f "wl-paste.*cliphist" &>/dev/null; then
  pass "wl-paste (cliphist watcher)"
else
  warn "wl-paste/cliphist watcher (not running)"
fi

# ─── Environment ─────────────────────────────────────────
header "Environment"

for var in XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP XCURSOR_SIZE HYPRLAND_INSTANCE_SIGNATURE; do
  val="${!var:-}"
  [ -n "$val" ] && pass "$var=$val" || warn "$var (unset)"
done

for var in GDK_SCALE GDK_DPI_SCALE; do
  val="${!var:-}"
  [ -n "$val" ] && info "$var=$val" || info "$var (unset)"
done

# ─── Dotfiles Git Status ─────────────────────────────────
header "Dotfiles Repo"

if [ -d "$DOTFILES/.git" ]; then
  cd "$DOTFILES"
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  pass "branch: $branch"
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    warn "uncommitted changes:"
    git status --short 2>/dev/null | while IFS= read -r line; do echo "    $line"; done
  else
    pass "working tree clean"
  fi
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
  [ "$ahead" -gt 0 ] && warn "$ahead commit(s) ahead of remote" || pass "up to date with remote"
  [ "$behind" -gt 0 ] && warn "$behind commit(s) behind remote"
else
  warn "not a git repository"
fi

# ─── Network-independent Summary ─────────────────────────
header "Summary"
total=0
issues=0

for pkg in "${packages[@]}"; do
  total=$((total + 1))
  pacman -Qi "$pkg" &>/dev/null 2>&1 || issues=$((issues + 1))
done

echo "  Packages: $((total - issues))/$total installed"
echo "  Network:  offline-safe (no external calls)"
echo ""
echo -e "${BOLD}Tip:${NC} Run ${CYAN}sudo pacman -S --needed <package>${NC} for missing packages"
echo "     All checks are local — no internet required."
