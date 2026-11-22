#!/usr/bin/env bash
BAT=/sys/class/power_supply/BAT0
ICONS=("" "" "" "" "")

while true; do
    status=$(cat "$BAT/status" 2>/dev/null) || status=""
    capacity=$(cat "$BAT/capacity" 2>/dev/null) || capacity=""
    if [[ -n "$capacity" ]]; then
        if (( capacity >= 95 )); then icon="${ICONS[4]}"
        elif (( capacity >= 70 )); then icon="${ICONS[3]}"
        elif (( capacity >= 45 )); then icon="${ICONS[2]}"
        elif (( capacity >= 25 )); then icon="${ICONS[1]}"
        else icon="${ICONS[0]}"; fi
        case "$status" in
            Charging|Not\ charging) text="$icon $capacity% 충전"; cls="charging" ;;
            Full)                   text="$icon $capacity% 충전완료"; cls="full" ;;
            *)                      text="$icon $capacity%"; cls="discharging" ;;
        esac
        if (( capacity <= 15 )); then cls="$cls critical"
        elif (( capacity <= 30 )); then cls="$cls warning"; fi
        printf '{"text":"%s","tooltip":"%s%%","class":"%s"}\n' "$text" "$capacity" "$cls"
    fi
    sleep 0.1
done
