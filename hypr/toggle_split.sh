#!/usr/bin/env bash
# Super+R: toggle a 2-window split between horizontal and vertical.
# dwindle -> togglesplit, master -> orientationnext (cycles master side).
layout=$(hyprctl activeworkspace -j 2>/dev/null | sed -n 's/.*"tiledLayout": "\([^"]*\)".*/\1/p')
if [ "$layout" = "master" ]; then
    hyprctl dispatch 'hl.dsp.layout("orientationnext")'
else
    hyprctl dispatch 'hl.dsp.layout("togglesplit")'
fi
