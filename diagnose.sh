#!/usr/bin/env bash
# Hyprland dotfiles 시스템 진단 스크립트 (offline-safe)
# 사용법: bash diagnose.sh
# 종료코드: 0=정상, 1=경고/문제 있음
set -euo pipefail

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0; WARN=0; FAIL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN+1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
info() { echo -e "  ${CYAN}→${NC} $1"; }
header() { echo -e "\n${BOLD}$1${NC}"; echo "──────────────────────"; }

HYPR="$HOME/.config/hypr"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# ─── System ──────────────────────────────────────────────
header "System"
echo "  Host:  $(uname -n)"
echo "  OS:    $( ( . /etc/os-release 2>/dev/null; echo "${NAME:-unknown} ${VERSION_ID:-}"; ) | xargs)"
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
  thunar gvfs
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
  swaync/config.json
  swaync/style.css
  swayosd/config.toml
  swayosd/style.css
  kitty/kitty.conf
  kitty/current-theme.conf
  waybar/config
  waybar/style.css
  rofi/config.rasi
  brave-flags.conf
)

# 참고: starship.toml은 $CONFIG 루트에 심mlink되므로 아래 별도 체크에서 다룸

for f in "${files[@]}"; do
  target="$HOME/.config/$f"
  if [ -L "$target" ]; then
    link=$(readlink "$target")
    if [ "$link" = "$DOTFILES/$f" ] || [ "$link" = "$DOTFILES/${f#hypr/}" ] || [ "$link" = "$DOTFILES/brave/$f" ]; then
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

# ─── GTK Theme Health ─────────────────────────────────────
# dconf 값이 settings.ini보다 우선하며, 미설치 테마명이면 GTK가 라이트 폴백함
# → 파일명 안 보임·주소창 라이트모드 등의 근본 원인 (자세한 것: dotfiles/thunar-fix/)
header "GTK Theme Health"

check_theme_dir() { # $1=dconf값  $2=검색루트
  [ -d "$2/$1" ]
}

if command -v gsettings >/dev/null; then
  # 1) dconf gtk-theme
  cur_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || true)
  ini_theme=$(sed -n 's/^gtk-theme-name=//p' "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null | head -1)
  if [ -z "$cur_theme" ]; then
    warn "dconf gtk-theme 읽기 실패"
  elif check_theme_dir "$cur_theme" "/usr/share/themes" || check_theme_dir "$cur_theme" "$HOME/.themes"; then
    pass "gtk-theme='$cur_theme' (installed)"
  else
    fail "gtk-theme='$cur_theme' NOT installed → light-mode fallback! (fix: gsettings set org.gnome.desktop.interface gtk-theme '<설치된테마>')"
  fi
  # settings.ini와 불일치는 정보성으로만 (둘 다 정상 설치 상태면 무해)
  if [ -n "$ini_theme" ] && [ "$ini_theme" != "$cur_theme" ]; then
    if check_theme_dir "$ini_theme" "/usr/share/themes"; then
      info "settings.ini declares '$ini_theme' but dconf has '$cur_theme' (dconf wins — OK if intentional)"
    fi
  fi

  # 2) dconf icon-theme
  cur_icon=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'" || true)
  if [ -z "$cur_icon" ]; then
    warn "dconf icon-theme 읽기 실패"
  elif [ -d "/usr/share/icons/$cur_icon" ] || [ -d "$HOME/.local/share/icons/$cur_icon" ]; then
    pass "icon-theme='$cur_icon' (installed)"
  else
    fail "icon-theme='$cur_icon' NOT installed → broken icons (fix: gsettings set org.gnome.desktop.interface icon-theme '<설치된아이콘테마>')"
  fi

  # 3) 사용자 gtk.css의 위험 패턴 (thunar.css 애니메이션 버그, 미정의 @primary)
  for gd in gtk-3.0 gtk-4.0; do
    f="$HOME/.config/$gd/gtk.css"
    [ -f "$f" ] || continue
    bad=0
    if grep -qE '^[[:space:]]*@import[[:space:]]+["'"'"']thunar\.css["'"'"']' "$f"; then
      fail "$gd/gtk.css: live '@import thunar.css' → opacity animation can leave UI invisible (fix: bash \$DOTFILES/thunar-fix/install.sh)"
      bad=1
    fi
    if grep -q "@define-color theme_selected_fg_color @primary" "$f"; then
      fail "$gd/gtk.css: undefined @primary color → CSS parser error (fix: bash \$DOTFILES/thunar-fix/install.sh)"
      bad=1
    fi
    [ $bad -eq 0 ] && pass "$gd/gtk.css clean"
  done
else
  warn "gsettings 없음 — GTK 테마 진단 생략"
fi

# ─── Script Permissions ──────────────────────────────────
header "Script Permissions"

for script in toggle_window_layout.sh diagnose.sh; do
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
  elif [ "$p" = "hyprlock" ]; then
    info "$p (only runs when locked)"
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
  [ -n "$val" ] && info "$var=$val" || info "$var (unset — set in hyprland.lua, only active inside Hyprland)"
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

# ─── Summary ──────────────────────────────────────────────
header "Summary"
echo "  ✓ pass: $PASS   ⚠ warn: $WARN   ✗ fail: $FAIL"
echo "  Network: offline-safe (no external calls)"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${BOLD}Result:${NC} ${RED}$FAIL개 문제 발견${NC} — 위 ✗ 항목 참고"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo -e "${BOLD}Result:${NC} ${YELLOW}경고 $WARN건${NC} — 필요 시 조치"
  exit 1
else
  echo -e "${BOLD}Result:${NC} ${GREEN}모두 정상${NC}"
  exit 0
fi
