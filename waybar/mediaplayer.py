#!/usr/bin/env python3
import subprocess, json
from wcwidth import wcswidth

W = 40

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
        o = subprocess.check_output(
            ["playerctl", "-a", "metadata", "--format",
             "{{playerName}}|{{status}}|{{artist}}|{{title}}"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode().strip().split("\n")
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired,
            FileNotFoundError):
        return None, None, None
    p, q = [], []
    for line in o:
        if not line:
            continue
        parts = line.split("|", 3)
        if len(parts) < 4:
            continue
        n, s, a, t = parts[0], parts[1], parts[2], parts[3]
        label = f"{a} - {t}" if a else t
        if s == "Playing":
            p.append((n, label, s))
        elif s == "Paused":
            q.append((n, label, s))
    return (p or q or [(None, None, None)])[0]

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
    }
    icon = "\uF001"
    for k, v in ICON_MAP.items():
        if k in nl:
            icon = v
            break

    full = f"{icon} {text}"
    out = trunc(full, W)
    cls = "paused" if status == "Paused" else "playing"
    print(json.dumps({"text": out, "tooltip": text, "class": cls}))
