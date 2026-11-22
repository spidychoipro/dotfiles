#!/usr/bin/env bash
# Plymouth 복구 메뉴 — 원클릭으로 상태 확인 / 되돌리기
# 실행: recovery-menu.sh   (또는 앱 목록에서 "복구 메뉴" 클릭)
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; }
no()   { echo -e "  ${YELLOW}[--]${NC} $1"; }
warn() { echo -e "  ${RED}[!!]${NC} $1"; }

ENTRIES=/efi/loader/entries
BACKUP=~/boot-backup

check_status() {
    echo -e "\n${BOLD}== 현재 Plymouth 상태 ==${NC}"
    if command -v plymouth &>/dev/null; then
        ok "plymouth 설치됨"
        sudo plymouth-set-default-theme 2>/dev/null | sed 's/^/    /' || no "테마 조회 실패"
    else
        no "plymouth 미설치"
    fi

    echo -e "\n${BOLD}== 안전 복구 부팅 엔트리 ==${NC}"
    local found=0
    for f in "$ENTRIES"/*-fallback.conf; do
        if sudo [ -e "$f" ]; then
            ok "안전 복구 엔트리 존재: $(basename "$f")"
            found=1
        fi
    done
    [ "$found" -eq 0 ] && warn "안전 복구 엔트리 없음 — 설치 전이거나 이미 제거됨"

    echo -e "\n${BOLD}== 백업 ==${NC}"
    if [ -d "$BACKUP/efi" ]; then
        local sz; sz=$(du -sh "$BACKUP/efi" 2>/dev/null | cut -f1)
        ok "부트 파티션 백업: $BACKUP/efi ($sz)"
    else
        no "부트 파티션 백업 없음"
    fi

    echo -e "\n${BOLD}== 부팅 타임아웃 ==${NC}"
    local to
    to=$(grep -E "^timeout[ \t=]" "$BACKUP/loader.conf" 2>/dev/null | head -1 | sed -E 's/^timeout[ \t]*=?[ \t]*//')
    if [ -n "$to" ]; then
        ok "백업 시점 timeout=$to 초"
    else
        warn "loader.conf 백업 없음"
    fi
}

show_recover_help() {
    echo -e "\n${BOLD}== 부팅이 안 될 때 (꼭 읽어보세요) ==${NC}"
    cat <<'EOF'
  1. 재부팅하고, 부팅 화면에서 방향키↑↓ 를 눌러 메뉴를 띄웁니다.
  2. "EndeavourOS (안전 복구 — 플리머스 없음)" 항목을 선택해 부팅합니다.
     → 플리머스가 망가져도 OS에 평소처럼 들어옵니다.
  3. 로그인 후 이 메뉴에서 [2. 되돌리기] 를 실행하면 원상복구됩니다.

  ※ 메뉴가 안 보이면: 재부팅 후 Esc 를 연타해도 메뉴가 나옵니다.
EOF
}

revert() {
    echo -e "\n${BOLD}== Plymouth 되돌리기 ==${NC}"
    if [ ! -f ~/scripts/revert-plymouth.sh ]; then
        warn "revert-plymouth.sh 를 찾을 수 없습니다: ~/scripts/revert-plymouth.sh"
        return 1
    fi
    echo "  되돌리기를 시작합니다. sudo 비밀번호를 물어보면 입력하세요."
    echo "  (잠시 후 dracut이 initramfs를 다시 만들어 시간이 걸립니다)"
    echo
    bash ~/scripts/revert-plymouth.sh
    echo
    echo "  완료! 이제 안전 복구 엔트리와 plymouth가 제거되었습니다."
}

menu() {
    while true; do
        echo
        echo -e "${BOLD}┌────────────────────────────────────────┐"
        echo -e "│  복구 메뉴 (Plymouth)                       │"
        echo -e "└────────────────────────────────────────┘${NC}"
        echo "  1. 상태 확인"
        echo "  2. 부팅 안 될 때 대처법 보기"
        echo "  3. Plymouth 되돌리기"
        echo "  4. 백업 파일 위치 보기"
        echo "  5. 나가기"
        printf "  선택: "
        read -r choice
        case "$choice" in
            1) check_status ;;
            2) show_recover_help ;;
            3) revert ;;
            4) echo; echo "  백업 위치: $BACKUP/"; ls -la "$BACKUP" 2>/dev/null | sed 's/^/    /' || warn "백업 없음";;
            5) echo "  안녕히 가세요!"; return 0 ;;
            *) warn "잘못된 선택입니다 (1~5)" ;;
        esac
    done
}

# 권한 미리 받기 (메뉴를 여는 순간 한 번만 비밀번호 입력)
sudo -v 2>/dev/null || warn "sudo 권한이 없습니다. 결과 확인이 제한될 수 있습니다."

menu
