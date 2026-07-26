#!/bin/bash
# install-brave-graceful-shutdown.sh
#
# 목적: EndeavourOS(KDE/Wayland)에서 재부팅/종료 시 Brave가 SIGTERM을 받고도
# 즉시 죽어버려 exit_type=Normal을 기록하지 못하는 문제를 영구적으로 해결.
#
# 방식: systemd-logind의 shutdown 지연 잠금(delay inhibitor)을 잡아두는
# 사용자 서비스를 등록. PrepareForShutdown 신호가 오면
#   1) Brave 메인 프로세스에만 SIGTERM을 보냄 (자식 프로세스 말고 메인만)
#   2) 브레이브 관련 프로세스가 실제로 다 사라질 때까지 최대 4초 대기
#   3) 잠금을 풀어 실제 종료를 진행시킴
#
# 사용법:
#   chmod +x install-brave-graceful-shutdown.sh
#   ./install-brave-graceful-shutdown.sh

set -euo pipefail

echo "1) 핸들러 스크립트 설치..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/brave-graceful-shutdown.sh" << 'HANDLER_EOF'
#!/bin/bash
systemd-inhibit --what=shutdown --who="brave-graceful-exit" \
  --why="Brave 세션을 안전하게 저장하기 위해" --mode=delay bash -c '
    dbus-monitor --system "type=\x27signal\x27,interface=\x27org.freedesktop.login1.Manager\x27,member=\x27PrepareForShutdown\x27" |
    while read -r line; do
      if echo "$line" | grep -q "boolean true"; then
        # 메인 브라우저 프로세스에만 SIGTERM (zygote/renderer 등 자식은 건드리지 않음)
        pkill -TERM -f "^/opt/brave-bin/brave\$" 2>/dev/null || true
        # 브레이브 관련 프로세스가 실제로 다 사라질 때까지 최대 4초(0.1초 간격) 대기
        for i in $(seq 1 40); do
          pgrep -f "/opt/brave-bin/brave" > /dev/null 2>&1 || break
          sleep 0.1
        done
        break
      fi
    done
  '
HANDLER_EOF
chmod +x "$HOME/.local/bin/brave-graceful-shutdown.sh"

echo "2) systemd 사용자 서비스 등록..."
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/brave-graceful-shutdown.service" << 'SERVICE_EOF'
[Unit]
Description=Kill Brave gracefully before system shutdown/reboot

[Service]
ExecStart=%h/.local/bin/brave-graceful-shutdown.sh
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
SERVICE_EOF

systemctl --user daemon-reload
systemctl --user enable --now brave-graceful-shutdown.service

echo
echo "3) 서비스가 잠금을 잡았는지 확인:"
sleep 1
systemd-inhibit --list | grep -i brave || echo "   (아직 안 보이면 몇 초 뒤 'systemd-inhibit --list | grep brave'로 다시 확인)"

echo
echo "설치 완료. 이제 Brave를 켜둔 채로 'reboot' 해서 팝업이 사라지는지 확인해보세요."
echo "확인용: systemctl --user status brave-graceful-shutdown.service"
