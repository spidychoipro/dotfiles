#!/usr/bin/env bash
# Plymouth 제거 + 안전 복구 엔트리 정리 스크립트
set -euo pipefail

ESP=/efi
ENTRIES="$ESP/loader/entries"
BACKUP=~/boot-backup

echo "== 1/4. dracut 설정 제거 =="
CONF=/etc/dracut.conf.d/plymouth.conf
if [ -f "$CONF" ]; then
    sudo rm -v "$CONF"
else
    echo "  (제거할 설정 없음)"
fi

echo "== 2/4. initramfs 재생성 (plymouth 제외) =="
sudo dracut --regenerate-all

echo "== 3/4. 패키지 제거 =="
sudo pacman -Rns plymouth plymouth-themes || echo "  (이미 제거됨)"

echo "== 4/4. 안전 복구 엔트리/이미지/타임아웃 정리 =="
if [ -d "$ENTRIES" ]; then
    sudo find "$ENTRIES" -name "*-fallback.conf" -delete
    echo "  안전 복구 엔트리 제거 완료"
fi
sudo find "$ESP" -maxdepth 3 -name "*-fallback.img" -delete
echo "  안전 initramfs 사본 제거 완료"

if [ -f "$BACKUP/loader.conf" ]; then
    sudo cp -a "$BACKUP/loader.conf" "$ESP/loader/loader.conf"
    echo "  loader.conf 원복 (타임아웃 복원)"
fi

echo
echo "== 되돌리기 완료 =="
echo "정말 원상복구가 되었는지 재부팅으로 확인하세요."
echo "참고: ~/boot-backup/ 의 백업본이 남아 있으니 문제없으면 지워도 됩니다."
