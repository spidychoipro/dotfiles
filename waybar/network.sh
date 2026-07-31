#!/usr/bin/env bash

CURRENT_CONN=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep -v "^lo:" | head -1 | cut -d: -f1)
WIFI_ON=$(nmcli radio wifi 2>/dev/null)

if [[ "$WIFI_ON" == "enabled" ]]; then
    TOGGLE="Turn WiFi OFF"
else
    TOGGLE="Turn WiFi ON"
fi

MENU="$TOGGLE\nScan WiFi\nOpen nmtui"

CHOSEN=$(echo -e "$MENU" | rofi -dmenu -p "WiFi" -mesg "Connected: ${CURRENT_CONN:-none}" -theme-str 'window {width: 320px;} listview {lines: 3;}')

case "$CHOSEN" in
    "Turn WiFi OFF")
        nmcli radio wifi off
        notify-send "WiFi OFF"
        ;;
    "Turn WiFi ON")
        nmcli radio wifi on
        notify-send "WiFi ON"
        ;;
    "Scan WiFi")
        SCAN_RESULTS=$(nmcli -t -f SSID,SIGNAL device wifi list --rescan yes 2>/dev/null | awk -F: '{
            ssid = $1; sig = $2
            if (ssid != "" && ssid != "--") {
                if (sig+0 >= 75) bar = "█████"
                else if (sig+0 >= 50) bar = "███▒"
                else if (sig+0 >= 25) bar = "██▒▒"
                else bar = "█░░░░"
                printf "%s %3d%%  %s\n", bar, sig, ssid
            }
        }' | sort -t' ' -k2 -rn | head -30)

        if [[ -z "$SCAN_RESULTS" ]]; then
            notify-send -u critical "WiFi scan failed" "No networks found"
            exit 1
        fi

        SELECTED=$(echo -e "$SCAN_RESULTS" | rofi -dmenu -p "WiFi" -i -theme-str 'window {width: 480px;} listview {lines: 15;}')
        [[ -z "$SELECTED" ]] && exit 0

        SSID=$(echo "$SELECTED" | sed 's/.*%  //' | xargs)
        [[ -z "$SSID" ]] && exit 0

        if nmcli -t -f NAME con show --active 2>/dev/null | grep -Fxq "$SSID"; then
            notify-send "Already connected" "$SSID"
            exit 0
        fi

        SECURITY=$(nmcli -t -f SSID,SECURITY device wifi list 2>/dev/null | grep -F "$SSID" | head -1 | cut -d: -f2)

        PASSWORD=""
        if [[ -n "$SECURITY" ]]; then
            ROFI_BIN="/usr/bin/rofi"
            PASSWORD=$($ROFI_BIN -dmenu -password -p "Password" -mesg "$SSID")
            [[ -z "$PASSWORD" ]] && exit 0
            RESULT=$(nmcli device wifi connect "$SSID" password "$PASSWORD" 2>&1)
        else
            RESULT=$(nmcli device wifi connect "$SSID" 2>&1)
        fi

        if echo "$RESULT" | grep -qi "error\|failed\|already"; then
            notify-send -u critical "Connection failed" "$SSID: $RESULT"
        else
            notify-send "Connected" "$SSID"
        fi
        ;;
    "Open nmtui")
        kitty -e nmtui
        ;;
esac
