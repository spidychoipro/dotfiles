#!/usr/bin/env python3
"""Waybar media widget.

Shows exactly the player that a plain `playerctl` command controls, so the
widget, click (play-pause) and scroll (prev/next) always act on the same player.
"""
import json
import re
import subprocess

from wcwidth import wcswidth

W = 40
FORMAT = "{{playerName}}|{{status}}|{{artist}}|{{title}}"


def clean(s):
    """Drop YouTube tab-title noise such as '(3) ' and ' - YouTube'."""
    s = re.sub(r"^\(\d+\)\s*", "", s or "")
    s = re.sub(r"\s*-\s*YouTube(?:\s+Music)?\s*$", "", s, flags=re.I)
    return s.strip()


def trunc(s, n):
    if wcswidth(s) <= n:
        return s
    r = ""
    for c in s:
        if wcswidth(r + c + "…") > n:
            break
        r += c
    return r + "…"


def get():
    try:
        out = subprocess.check_output(
            ["playerctl", "metadata", "--format", FORMAT],
            stderr=subprocess.DEVNULL, timeout=1,
        ).decode().strip()
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired,
            FileNotFoundError):
        return None, None, None
    parts = out.split("|", 3)
    if len(parts) < 4:
        return None, None, None
    name, status, artist, title = parts
    artist, title = clean(artist), clean(title)
    # plasma-browser-integration's "artist" is the YouTube channel name, not the
    # musician. The title already carries the real artist, so show it alone.
    if name == "plasma-browser-integration":
        artist = ""
    label = f"{artist} - {title}" if artist and artist != title else (title or artist)
    return name, label or None, status


pn, text, status = get()
if not text:
    print(json.dumps({"text": "♪", "class": "idle"}))
else:
    nl = (pn or "").lower()
    ICON_MAP = {
        "spotify": "\uF1BC",
        "firefox": "\uF269", "librewolf": "\uF269", "zen": "\uF269",
        "chrom": "\uF268", "brave": "\uF268", "edge": "\uF268",
        "opera": "\uF268", "vivaldi": "\uF268",
        "plasma-browser-integration": "\uF268",
    }
    icon = "\uF001"
    for k, v in ICON_MAP.items():
        if k in nl:
            icon = v
            break

    state = {"Playing": "재생 중", "Paused": "일시정지"}.get(status, status)
    cls = "paused" if status == "Paused" else "playing"
    print(json.dumps({
        "text": trunc(f"{icon} {text}", W),
        "tooltip": f"{pn} · {state} · {text}",
        "class": cls,
    }))
