#!/usr/bin/env bash
# Switch to next keyboard layout

device=$(hyprctl devices -j 2>/dev/null | python3 -c "
import json, sys
d = json.load(sys.stdin)
for kb in d.get('keyboards', []):
    name = kb.get('name', '')
    if 'virtual' not in name.lower() and 'keyboard' in name.lower():
        print(name)
        break
")

[ -n "$device" ] && hyprctl switchxkblayout "$device" next
