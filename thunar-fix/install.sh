#!/usr/bin/env bash
# Thunar 다크모드/렌더링 통합 수정 스크립트
# 증상: 파일명 안 보임 · 주소창 라이트모드 · 사이드바 항목 누락/깨짐 · 아이콘 깨짐
# 사용법: bash install.sh [--dry-run]
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

GTK_THEME="Dracula"
ICON_THEME="breeze-dark"

run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        eval "$@"
    fi
}

echo "=== Thunar 다크모드 통합 수정 시작 ==="

# ── 0. 사전 확인 ──────────────────────────────────────────────
command -v gsettings >/dev/null || { echo "오류: gsettings 없음 (GLib 필요)"; exit 1; }

if [[ -d "/usr/share/themes/$GTK_THEME" ]]; then
    echo "[OK] 테마 설치됨: $GTK_THEME"
else
    echo "경고: /usr/share/themes/$GTK_THEME 없음 — 다른 테마로 진행하면 라이트 폴백 발생"
    echo "      Dracula 설치 권장: https://github.com/dracula/gtk"
fi
if [[ -d "/usr/share/icons/$ICON_THEME" ]]; then
    echo "[OK] 아이콘 테마 설치됨: $ICON_THEME"
else
    echo "경고: 아이콘 테마 $ICON_THEME 없음"
fi

# ── 1. gvfs 설치 (사이드바 휴지통·장치·네트워크 + 쓰레기 기능) ──
if pacman -Q gvfs &>/dev/null; then
    echo "[OK] gvfs 이미 설치됨"
else
    echo "[수정] gvfs 설치..."
    run "sudo pacman -S --needed --noconfirm gvfs"
fi

# ── 2. dconf 테마 수정 (settings.ini보다 우선되므로 반드시 여기 설정) ──
#    미설치 테마명이 있으면 GTK가 조용히 라이트 기본값으로 폴백함 → 파일명·주소창 라이트모드 버그
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "''")
echo "현재 dconf gtk-theme: $CURRENT_THEME"
run "gsettings set org.gnome.desktop.interface gtk-theme '$GTK_THEME'"
run "gsettings set org.gnome.desktop.interface icon-theme '$ICON_THEME'"

# ── 3. 깨진 thunar.css 애니메이션 무력화 ─────────────────────
#    opacity:0 + CSS 애니메이션이 GTK3에서 실행 실패하면 파일뷰/사이드바가 영구 안 보임
patch_gtk_css() {
    local dir="$HOME/.config/$1"
    local f="$dir/gtk.css"
    [[ -f "$f" ]] || { echo "[SKIP] $f 없음"; return; }
    if grep -q "disabled: GTK3 animation bug" "$f"; then
        echo "[OK] $f 이미 정상"
        return
    fi
    if grep -qE "^\s*@import\s+[\"']thunar\.css[\"']" "$f" || grep -q "@define-color theme_selected_fg_color @primary" "$f"; then
        local bak="$f.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$f" "$bak"
        echo "[수정] $f (백업: $(basename "$bak"))"
        # 1) thunar.css import 주석 처리
        sed -i -E "s|^([[:space:]]*)@import([[:space:]]+[\"']thunar\.css[\"'];)|\1/* \2 */ /* disabled: GTK3 animation bug (see dotfiles/thunar-fix) */|" "$f"
        # 2) 정의되지 않은 @primary 참조 수정 (CSS 파서 에러 유발)
        sed -i "s|@define-color theme_selected_fg_color @primary;|@define-color theme_selected_fg_color #f8f8f2;|" "$f"
    else
        echo "[OK] $f 이미 정상"
    fi
}
patch_gtk_css "gtk-3.0"
patch_gtk_css "gtk-4.0"

# ── 4. 완료 ──────────────────────────────────────────────────
echo ""
if [[ $DRY_RUN -eq 1 ]]; then
    echo "=== dry-run 완료 (실제 변경 없음) ==="
else
    echo "=== 완료! ==="
    echo "확인: Super+E 로 Thunar 실행 → 다크모드·파일명·사이드바 전부 정상인지 확인"
    echo "실행 중인 Thunar는 재시작해야 적용됩니다: pkill -x Thunar"
fi
