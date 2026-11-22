#!/usr/bin/env bash
current=$(hyprctl getoption general:layout | head -1 | awk '{print $2}')
if [ "$current" = "dwindle" ]; then
    hyprctl eval 'hl.config({general = {layout = "master"}})' 
else
    hyprctl eval 'hl.config({general = {layout = "dwindle"}})' 
fi
