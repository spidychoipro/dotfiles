#!/usr/bin/env bash
# AUR spotify를 SpotX-Bash가 지원하는 버전까지만 올리고, SpotX 패치를 다시 적용한다.
# 기본은 상태 확인만 한다. 실제 변경은 --apply (확인 프롬프트, --yes로 생략).
set -euo pipefail

PKG="spotify"
CLIENT_ROOT="${SPOTX_CLIENT_ROOT:-/opt/spotify}"
README_URL="${SPOTX_README_URL:-https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/README.md}"
PATCH_URL="${SPOTX_PATCH_URL:-https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh}"
PACMAN_BIN="${SPOTX_PACMAN:-pacman}"
YAY_BIN="${SPOTX_YAY:-yay}"
CURL_BIN="${SPOTX_CURL:-curl}"

MODE=check
PREMIUM=0
YES=0

usage() {
    cat <<'EOF'
사용법: spotx-update.sh [옵션]

옵션:
  --check       상태만 확인하고 끝낸다 (기본)
  --apply       실제로 업그레이드 + SpotX 재패치
  --premium     Premium 계정용 SpotX 패치 (-p) 사용 (기본: 무료용)
  --yes         --apply 확인 프롬프트 생략
  -h, --help    이 도움말

환경 변수 (고급):
  SPOTX_SUPPORTED_VERSION  SpotX 지원 버전을 직접 지정 (네트워크 없이 확인할 때)
  SPOTX_CLIENT_ROOT        Spotify 클라이언트 경로 (기본 /opt/spotify)
  SPOTX_PACMAN / SPOTX_YAY / SPOTX_CURL  사용할 명령 경로
EOF
}

die()  { printf '❌ %s\n' "$*" >&2; exit 1; }
warn() { printf '⚠️  %s\n' "$*" >&2; }

while (($#)); do
    case "$1" in
        --check)   MODE=check ;;
        --apply)   MODE=apply ;;
        --premium) PREMIUM=1 ;;
        --yes)     YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "알 수 없는 옵션: $1 (--help 참고)" ;;
    esac
    shift
done

# 1:1.2.96.518-2 / 1.3.10.2586.g81a118... → 1.2.96.518 / 1.3.10.2586
normalized_version() {
    local v="$1"
    v="${v%%[+-]*}"       # pkgrel / metadata 제거
    v="${v#*:}"           # epoch 제거
    v="${v%%.g*}"         # SpotX git hash 제거
    printf '%s' "$v"
}

ver_gt() {
    local a b max
    a="$(normalized_version "$1")"
    b="$(normalized_version "$2")"
    [ "$a" != "$b" ] || return 1
    max="$(printf '%s\n%s\n' "$a" "$b" | LC_ALL=C sort -V | tail -n1)"
    [ "$max" = "$a" ]
}

installed_version() {
    "$PACMAN_BIN" -Q "$PKG" 2>/dev/null | awk 'NR == 1 {print $2}'
}

aur_version() {
    "$YAY_BIN" -Si "$PKG" 2>/dev/null | awk -F':' '$1 ~ /^Version[[:space:]]*$/ {
        v = $2
        for (i = 3; i <= NF; i++) v = v ":" $i
        sub(/^[[:space:]]*/, "", v)
        print v
    }'
}

supported_version() {
    local tmp raw
    if [ -n "${SPOTX_SUPPORTED_VERSION:-}" ]; then
        printf '%s' "$SPOTX_SUPPORTED_VERSION"
        return 0
    fi
    tmp="$(mktemp)"
    if ! "$CURL_BIN" -fsSL --max-time 20 "$README_URL" -o "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    raw="$(grep -m1 'Latest supported version:' "$tmp" \
           | sed -E 's|.*</strong>[[:space:]]*||; s|<[^>]*>||g' \
           | tr -d '[:space:]' || true)"
    rm -f "$tmp"
    [ -n "$raw" ] || return 1
    printf '%s' "$raw"
}

command -v "$PACMAN_BIN" >/dev/null 2>&1 || die "$PACMAN_BIN 실행 파일을 찾지 못했습니다."
command -v "$YAY_BIN"    >/dev/null 2>&1 || die "$YAY_BIN 실행 파일을 찾지 못했습니다."
command -v "$CURL_BIN"   >/dev/null 2>&1 || die "$CURL_BIN 실행 파일을 찾지 못했습니다."

installed="$(installed_version)"
[ -n "$installed" ] || die "$PKG 패키지가 설치돼 있지 않습니다."
aur="$(aur_version)"
[ -n "$aur" ] || die "$YAY_BIN -Si $PKG 에서 버전을 읽지 못했습니다. (네트워크 확인)"
supported="$(supported_version)" \
    || die "SpotX-Bash 지원 버전을 읽지 못했습니다. (네트워크 확인 또는 SPOTX_SUPPORTED_VERSION 지정)"

inst_n="$(normalized_version "$installed")"
aur_n="$(normalized_version "$aur")"
sup_n="$(normalized_version "$supported")"

printf '설치됨      : %s\n' "$installed"
printf 'AUR 최신    : %s\n' "$aur"
printf 'SpotX 지원  : %s\n' "$supported"
printf '\n'

if ver_gt "$aur_n" "$sup_n"; then
    warn "AUR 최신($aur_n)이 SpotX 지원 버전($sup_n)보다 높습니다."
    printf '업그레이드하지 않고 종료합니다. SpotX가 새 버전을 지원할 때까지 기다리세요.\n'
    exit 0
fi

need_upgrade=0
if ver_gt "$aur_n" "$inst_n"; then
    need_upgrade=1
fi

# 업그레이드하면 패치가 사라지므로 반드시 다시 적용한다.
need_patch=0
if [ "$need_upgrade" -eq 1 ] \
   || [ ! -f "$CLIENT_ROOT/Apps/xpui.bak" ] \
   || [ ! -f "$CLIENT_ROOT/spotify.bak" ]; then
    need_patch=1
fi

if [ "$need_upgrade" -eq 0 ] && [ "$need_patch" -eq 0 ]; then
    printf '✅ 이미 최신 설치 + SpotX 패치 상태입니다.\n'
    exit 0
fi

printf '계획:\n'
if [ "$need_upgrade" -eq 1 ]; then
    printf '  1) %s -S --needed --noconfirm %s  (%s → %s)\n' "$YAY_BIN" "$PKG" "$inst_n" "$aur_n"
fi
if [ "$need_patch" -eq 1 ]; then
    flags='--noninteractive'
    [ "$PREMIUM" -eq 1 ] && flags="$flags -p"
    printf '  2) SpotX-Bash 재적용 (%s)\n' "$flags"
fi
printf '\n'

if [ "$MODE" = check ]; then
    printf '상태 확인만 했습니다. 실제로 적용하려면 --apply 를 붙여 실행하세요.\n'
    exit 0
fi

[ -d "$CLIENT_ROOT/Apps" ] || die "$CLIENT_ROOT/Apps 경로가 없습니다. 이 스크립트는 AUR spotify (/opt/spotify)용입니다."
[ -w "$CLIENT_ROOT/Apps" ] || die "$CLIENT_ROOT/Apps 에 쓸 권한이 없습니다. 권한을 확인하세요."
if pgrep -x spotify >/dev/null 2>&1; then
    die "Spotify가 실행 중입니다. 종료한 뒤 다시 실행하세요. (패치 중 파일이 바뀌면 안 됨)"
fi

if [ "$YES" -eq 0 ]; then
    read -r -p "위 내용을 적용할까요? [y/N] " answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *) printf '취소했습니다.\n'; exit 0 ;;
    esac
fi

if [ "$need_upgrade" -eq 1 ]; then
    printf '\n▶ AUR spotify 업그레이드...\n'
    "$YAY_BIN" -S --needed --noconfirm "$PKG"
    new_installed="$(installed_version)"
    [ "$(normalized_version "$new_installed")" = "$aur_n" ] \
        || die "업그레이드 후 버전이 다릅니다: $new_installed (기대: $aur)"
fi

if [ "$need_patch" -eq 1 ]; then
    printf '\n▶ SpotX-Bash 재적용...\n'
    patch_file="$(mktemp "${TMPDIR:-/tmp}/spotx-patch.XXXXXX")"
    if ! "$CURL_BIN" -fsSL --max-time 30 "$PATCH_URL" -o "$patch_file"; then
        rm -f "$patch_file"
        die "SpotX-Bash 스크립트를 내려받지 못했습니다."
    fi
    grep -qi 'spotx' "$patch_file" || { rm -f "$patch_file"; die "내려받은 파일이 SpotX 스크립트가 아닙니다."; }
    patch_opts=(--noninteractive)
    [ "$PREMIUM" -eq 1 ] && patch_opts+=(-p)
    bash "$patch_file" "${patch_opts[@]}"
    rm -f "$patch_file"
fi

final="$(installed_version)"
printf '\n✅ 완료: 설치 %s / SpotX 지원 %s\n' "$final" "$supported"
if [ -f "$CLIENT_ROOT/Apps/xpui.bak" ]; then
    printf '   SpotX 백업(xpui.bak) 확인됨. 이제 Spotify를 실행해도 됩니다.\n'
else
    warn "xpui.bak 이 없습니다. SpotX 패치가 적용되지 않았을 수 있으니 확인하세요."
fi
