#!/usr/bin/env python3
import subprocess, json, re

def is_running():
    try:
        r = subprocess.run(
            ["systemctl", "is-active", "bluetooth"],
            capture_output=True, text=True, timeout=2
        )
        return r.stdout.strip() == "active"
    except Exception:
        return False

def is_powered():
    try:
        r = subprocess.run(
            ["rfkill", "list", "bluetooth"],
            capture_output=True, text=True, timeout=2
        )
        return "Soft blocked: no" in r.stdout and "Hard blocked: no" in r.stdout
    except Exception:
        return False

def connected_devices():
    try:
        o = subprocess.check_output(
            ["bluetoothctl", "devices", "Connected"],
            stderr=subprocess.DEVNULL, timeout=3
        ).decode().strip()
        if not o:
            return []
        devices = []
        for line in o.split("\n"):
            m = re.match(r"Device\s+([0-9A-F:]+)\s+(.+)", line)
            if not m:
                continue
            mac, name = m.groups()
            battery = None
            try:
                info = subprocess.check_output(
                    ["bluetoothctl", "info", mac],
                    stderr=subprocess.DEVNULL, timeout=3
                ).decode()
                bm = re.search(r"Battery Percentage.*?(\d+)", info, re.IGNORECASE)
                if bm:
                    battery = int(bm.group(1))
            except Exception:
                pass
            devices.append({"name": name, "battery": battery})
        return devices
    except Exception:
        return []

if not is_running() or not is_powered():
    print(json.dumps({"text": "", "class": "off"}))
else:
    devices = connected_devices()
    if not devices:
        print(json.dumps({"text": "", "class": "on"}))
    else:
        d = devices[0]
        text = f" {d['name']}"
        if d["battery"] is not None:
            text += f" {d['battery']}%"
        tooltip_lines = [
            f"{x['name']}{' ' + str(x['battery']) + '%' if x['battery'] is not None else ''}"
            for x in devices
        ]
        print(json.dumps({
            "text": text,
            "class": "connected",
            "tooltip": "\n".join(tooltip_lines),
        }))
