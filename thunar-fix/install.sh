#!/usr/bin/env bash
# Thunar 다크모드/렌더링 통합 수정 스크립트 (진단 기반)
# 증상: 파일명 안 보임 · 주소창 라이트모드 · 사이드바 항목 누락/깨짐 · 아이콘 깨짐
#
# 사용법:
#   bash install.sh            진단 후 문제된 것만 수정
#   bash install.sh --check    진단만 수행 (수정 없음)
#   bash install.sh --dry-run  수정할 내용만 미리보기
set -euo pipefail

MODE="fix"       # fix | check | dryrun
case "${1:-}" in
    --check)   MODE="check" ;;
    --dry-run) MODE="dryrun" ;;
    "")        ;;
    *) echo "알 수 없는 옵션: $1 (사용법: --check, --dry-run)"; exit 2 ;;
esac

GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
FIXES=()   # 적용이 필요한 수정 목록

say()  { echo "$*"; }
flag() { FIXES+=("$1"); say "  [문제] $*"; }
ok()   { say "  [정상] $*"; }

apply() {
    case $MODE in
        check)  say "  [수정 필요] $*" ;;
        dryrun) say "  [dry-run] $*" ;;
        fix)    eval "$*" ;;
    esac
}

# 설정값 우선순위: settings.ini 선언값(설치됨) > 설치된 폴백 후보 > 유지
resolve_theme() { # $1=ini키  $2...=폴백후보들
    local key="$1"; shift
    local declared=""
    [[ -f $GTK3_INI ]] && declared=$(sed -n "s/^$key=//p" "$GTK3_INI" | head -1)
    local candidate
    for candidate in $declared "$@"; do
        [[ -z $candidate ]] && continue
        if [[ -d "/usr/share/themes/$candidate" || -d "/usr/share/icons/$candidate" ]]; then
            echo "$candidate"; return
        fi
    done
    echo ""  # 설치된 테마 없음
}

echo "=== Thunar 진단 시작 ==="

# ── 진단 1. gvfs (사이드바 휴지통·장치·네트워크) ──────────────
if pacman -Q gvfs &>/dev/null; then
    ok "gvfs 설치됨"
else
    flag "gvfs 미설치 → 사이드바 누락/쓰레기 기능 없음"
    NEED_GVFS=1
fi

# ── 진단 2. dconf gtk-theme ──────────────────────────────────
#    dconf가 settings.ini보다 우선되며, 미설치 테마명이면 GTK가 라이트 폴백함
CUR_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
TARGET_THEME=$(resolve_theme "gtk-theme-name" "Dracula")
if [[ -n $TARGET_THEME ]]; then
    if [[ -d "/usr/share/themes/$CUR_THEME" ]]; then
        ok "gtk-theme='$CUR_THEME' (설치됨)"
    else
        flag "gtk-theme='$CUR_THEME' 미설치 테마 → 라이트 폴백 발생"
        NEED_THEME="$TARGET_THEME"
    fi
else
    say "  [경고] 설치된 GTK 테마를 못 찾음 — 테마 수동 설치 필요 (/usr/share/themes)"
fi

# ── 진단 3. dconf icon-theme ─────────────────────────────────
CUR_ICON=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
TARGET_ICON=$(resolve_theme "gtk-icon-theme-name" "breeze-dark")
if [[ -n $TARGET_ICON ]]; then
    if [[ -d "/usr/share/icons/$CUR_ICON" ]]; then
        ok "icon-theme='$CUR_ICON' (설치됨)"
    else
        flag "icon-theme='$CUR_ICON' 미설치 → 아이콘 깨짐"
        NEED_ICON="$TARGET_ICON"
    fi
else
    say "  [경고] 설치된 아이콘 테마를 못 찾음"
fi

# ── 진단 4/5. 사용자 gtk.css (thunar.css 애니메이션 버그, @primary) ──
#    opacity:0 + fade-in 애니메이션이 GTK3에서 실패하면 파일뷰/사이드바 고착
check_gtk_css() {
    local f="$HOME/.config/$1/gtk.css"
    if [[ ! -f $f ]]; then
        ok "$f 없음 (패치 불필요)"; return
    fi
    local need=0
    grep -qE "^\s*@import\s+[\"']thunar\.css[\"']" "$f" && { flag "$1/gtk.css: thunar.css import 활성 → 애니메이션 버그 위험"; need=1; }
    grep -q "@define-color theme_selected_fg_color @primary" "$f" && { flag "$1/gtk.css: 미정의 @primary 참조 → CSS 파서 에러"; need=1; }
    if (( need )); then
        NEED_CSS+=("$1")
    else
        ok "$f 정상"
    fi
}
NEED_CSS=()
check_gtk_css "gtk-3.0"
check_gtk_css "gtk-4.0"

# ── 결과 요약 ────────────────────────────────────────────────
echo ""
if [[ ${#FIXES[@]} -eq 0 ]]; then
    say "=== 모두 정상 — 수정 불필요 ==="
    exit 0
fi

say "발견된 문제 ${#FIXES[@]}건:"
printf '  - %s\n' "${FIXES[@]}"
echo ""

if [[ $MODE == "check" ]]; then
    say "=== 진단 완료 (--check: 수정은 하지 않음) ==="
    exit 1   # 문제 있음을 종료코드로 전달 (스크립트 연동용)
fi

say "=== 해당 사항만 수정 중... ==="

[[ -n ${NEED_GVFS:-} ]] && apply "sudo pacman -S --needed --noconfirm gvfs"
[[ -n ${NEED_THEME:-} ]] && apply "gsettings set org.gnome.desktop.interface gtk-theme '$NEED_THEME'"
[[ -n ${NEED_ICON:-}  ]] && apply "gsettings set org.gnome.desktop.interface icon-theme '$NEED_ICON'"

patch_gtk_css() {
    local dir="$1"
    local f="$HOME/.config/$dir/gtk.css"
    local bak="$f.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$f" "$bak"
    apply "true  # 백업 생성: $bak"
    sed -i -E "s|^([[:space:]]*)@import([[:space:]]+[\"']thunar\.css[\"'];)|\1/* @import \2 -- disabled: GTK3 animation bug (see dotfiles/thunar-fix) */|" "$f"
    sed -i "s|@define-color theme_selected_fg_color @primary;|@define-color theme_selected_fg_color #f8f8f2;|" "$f"
    say "  [수정 완료] $f"
}
for d in "${NEED_CSS[@]:-}"; do
    [[ -n $d ]] && patch_gtk_css "$d"
done

echo ""
say "=== 완료! 실행 중인 Thunar는 재시작: pkill -x Thunar ==="
