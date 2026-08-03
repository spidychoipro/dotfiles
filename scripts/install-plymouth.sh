#!/usr/bin/env bash
# Plymouth 부팅 애니메이션 설치 스크립트 (EndeavourOS / systemd-boot / dracut)
#
# 안전장치 (플리머스가 망가져도 OS로 진입 가능하게):
#   A. 백업: /efi(부트 파티션) 전체 + dracut 설정 + loader.conf 를 ~/boot-backup/ 에 복사
#   B. 안전 복구 엔트리: 플리머스 설치 "전" initramfs를 사본으로 보관하고,
#      그 사본을 가리키는 "안전 복구" 부팅 엔트리를 추가
#      → 메인 initramfs가 손상돼도 부팅 메뉴에서 이 항목을 선택하면 OS로 들어옵니다
#   C. 부팅 메뉴 타임아웃이 0이면 2초로 설정 (메뉴를 열어 안전 엔트리를 고를 수 있게)
#
# 실행:
#   chmod +x install-plymouth.sh && ./install-plymouth.sh
# 되돌리기:
#   chmod +x revert-plymouth.sh && ./revert-plymouth.sh
set -euo pipefail

BACKUP=~/boot-backup
ESP=/efi
ENTRIES="$ESP/loader/entries"
MAIN_INITRDS=()
mkdir -p "$BACKUP"

echo "== 1/6. 백업 =="
if [ ! -e "$BACKUP/efi" ]; then
    sudo cp -a "$ESP" "$BACKUP/efi"
    echo "  /efi -> $BACKUP/efi"
else
    echo "  /efi 백업 이미 존재"
fi
if [ ! -e "$BACKUP/dracut.conf.d" ]; then
    sudo cp -a /etc/dracut.conf.d "$BACKUP/dracut.conf.d"
    echo "  dracut 설정 백업 완료"
fi
if [ ! -e "$BACKUP/loader.conf" ]; then
    sudo cp -a "$ESP/loader/loader.conf" "$BACKUP/loader.conf"
    echo "  loader.conf 백업 완료"
fi

echo "== 2/6. 안전 복구 부팅 엔트리 생성 =="
create_fallback() {
    local conf="$1"
    local base; base=$(basename "$conf" .conf)
    [[ "$base" == *-fallback ]] && return   # 이미 폴백이면 건너뜀
    local fb_conf="$ENTRIES/${base}-fallback.conf"
    local exists=0
    sudo [ -e "$fb_conf" ] && exists=1
    local title linux options machineid ver
    # BLS 엔트리는 "key value" 형식이지만 일부는 "key = value"도 허용 → 둘 다 처리
    get() { sudo awk -v k="$1" '$0 ~ "^"k"[ \t]=" || $0 ~ "^"k"[ \t]" { sub("^"k"[ \t]*=?[ \t]*",""); print; exit }' "$conf"; }
    title=$(get title)
    linux=$(get linux)
    options=$(get options)
    machineid=$(get machine-id)
    version=$(get version)

    # 모든 initrd 라인 수집 (예: intel-ucode.img 먼저, 그다음 initramfs)
    local initrd_lines=()
    while IFS= read -r l; do initrd_lines+=("$l"); done \
        < <(sudo awk -v k="initrd" '$0 ~ "^"k"[ \t]=" || $0 ~ "^"k"[ \t]" { sub("^"k"[ \t]*=?[ \t]*",""); print }' "$conf")

    if [ -z "$linux" ] || [ ${#initrd_lines[@]} -eq 0 ]; then
        echo "  경고: $conf 에서 linux/initrd 를 못 읽음 — 건너뜀"
        return
    fi
    # 실제 initramfs 파일 선택: 이름에 "initramfs" 포함된 것 우선, 없으면 마지막 라인
    local main_initrd=""
    for l in "${initrd_lines[@]}"; do
        [[ "$l" == *initramfs* ]] && main_initrd="$l" && break
    done
    [ -z "$main_initrd" ] && main_initrd="${initrd_lines[-1]}"
    # 부팅이 실제로 읽는 initramfs 경로 기억 (뒤에서 재생성 대상으로 사용)
    MAIN_INITRDS+=("$main_initrd")

    local idir; idir=$(dirname "/$main_initrd"); idir=${idir#/}
    [ -n "$idir" ] && idir="$idir/"
    local src="$ESP/$main_initrd"
    local dst="$ESP/$idir${base}-fallback.img"
    if ! sudo [ -f "$src" ]; then
        echo "  경고: initramfs 없음 ($src) — 건너뜀"
        return
    fi
    sudo cp -a "$src" "$dst"
    if [ "$exists" -eq 1 ]; then
        echo "  이미 존재 — 안전 사본만 최신으로 갱신: $dst"
        return
    fi
    echo "  안전 initramfs 사본: $dst"
    {
        echo "title $title (안전 복구 — 플리머스 없음)"
        [ -n "$version" ]   && echo "version $version"
        [ -n "$machineid" ] && echo "machine-id $machineid"
        echo "linux $linux"
        # ucode 등 다른 initrd 라인은 그대로, 실제 initramfs만 안전 사본으로 교체
        for l in "${initrd_lines[@]}"; do
            if [ "$l" = "$main_initrd" ]; then
                echo "initrd /$idir${base}-fallback.img"
            else
                echo "initrd $l"
            fi
        done
        [ -n "$options" ]   && echo "options $options"
    } | sudo tee "$fb_conf" >/dev/null
    echo "  생성됨: $fb_conf"
}
for conf in "$ENTRIES"/*.conf; do
    if sudo [ -e "$conf" ]; then
        create_fallback "$conf"
    fi
done

echo "== 3/6. 부팅 메뉴 타임아웃 확인 =="
sudo bash -c '
    f=/efi/loader/loader.conf
    cur=$(grep -E "^timeout[ \t=]" "$f" 2>/dev/null | head -1 | sed -E "s/^timeout[ \t]*=?[ \t]*//") || true
    if [ -z "$cur" ] || [ "$cur" -eq 0 ]; then
        if [ -f "$f" ] && grep -q "^timeout" "$f"; then
            sed -i "s/^timeout.*/timeout 2/" "$f"
        else
            echo "timeout 2" >> "$f"
        fi
        echo "  timeout 0/없음 -> 2초로 설정 (부팅 시 메뉴 표시)"
    else
        echo "  timeout=$cur 초 (유지)"
    fi
'

echo "== 4/6. 패키지 설치 (plymouth + 테마) =="
sudo pacman -S --needed plymouth plymouth-themes

echo "== 5/6. dracut 설정 + 테마 =="
CONF=/etc/dracut.conf.d/plymouth.conf
if [ -f "$CONF" ]; then
    echo "  dracut 설정 이미 존재"
else
    echo 'add_dracutmodules+=" plymouth "' | sudo tee "$CONF" >/dev/null
    echo "  생성됨: $CONF"
fi
sudo plymouth-set-default-theme spinner || echo "  (테마 설정 실패해도 부팅엔 무관. 나중에 변경 가능)"

echo "== 6/6. initramfs 재생성 =="
# 이 시스템에서 부팅이 읽는 initramfs는 kernel-install이 ESP(/efi)에 쓴 파일입니다.
# /boot가 아니라 실제 부팅 경로($ESP/<initrd>)를 직접 재생성해야 반영됩니다.
if [ ${#MAIN_INITRDS[@]} -eq 0 ]; then
    echo "  [!!] initramfs 경로를 찾지 못했습니다 — 재생성 생략. 수동 점검 필요!"
else
    for initrd in "${MAIN_INITRDS[@]}"; do
        target="$ESP/$initrd"
        sudo dracut -f --kver "$(uname -r)" "$target"
        echo "  재생성 완료: $target"
    done
fi

echo
echo "== 부팅 엔트리 목록 확인 =="
sudo bootctl list
echo
echo "== initramfs 이미지 크기 확인 =="
sudo find "$ESP" -maxdepth 3 \( -name "initramfs*" -o -name "*.img" \) 2>/dev/null \
    | while read -r img; do printf "  %s : %s bytes\n" "$img" "$(sudo stat -c '%s' "$img")"; done
echo
echo "== 완료 =="
echo "재부팅 후 정상 부팅을 확인하세요."
echo "만약 부팅이 안 되면: 부팅 메뉴에서 '(안전 복구)' 항목을 선택하면 OS로 들어옵니다."
echo "그 후 되돌리기: ./revert-plymouth.sh"
