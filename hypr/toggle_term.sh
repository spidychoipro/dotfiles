#!/usr/bin/env bash
if ! hyprctl clients -j | jq -e '.[] | select(.workspace.name == "special:term")' > /dev/null 2>&1; then
    if ! hyprctl clients -j | jq -e '.[] | select(.class == "kitty-dropdown")' > /dev/null 2>&1; then
        kitty --class kitty-dropdown &
        for _ in {1..20}; do
            window_id=$(hyprctl clients -j | jq -r '.[] | select(.class == "kitty-dropdown") | .address' | head -1)
            [ -n "$window_id" ] && break
            sleep 0.05
        done
        if [ -n "$window_id" ]; then
            hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:term" })'
            sleep 0.05
        fi
    fi
fi
hyprctl dispatch 'hl.dsp.workspace.toggle_special("term")'
