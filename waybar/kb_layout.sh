#!/usr/bin/env bash

hyprctl devices -j 2>/dev/null | python3 -c "
import json, sys

d = json.load(sys.stdin)
for kb in d.get('keyboards', []):
    name = kb.get('name', '')
    if 'virtual' in name.lower():
        continue
    keymap = kb.get('active_keymap', '')
    idx = kb.get('active_layout_index', 0)
    layouts = kb.get('layout', '').split(',')

    short = ''
    if 'korean' in keymap.lower():
        short = 'KR'
        cls = 'kr'
    else:
        short = 'US'
        cls = 'us'

    alt = layouts[idx] if idx < len(layouts) else 'us'
    print(json.dumps({'text': short, 'alt': alt, 'class': cls}))
    break
else:
    print(json.dumps({'text': 'US', 'alt': 'us', 'class': 'us'}))
"