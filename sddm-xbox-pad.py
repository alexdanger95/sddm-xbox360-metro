import time, subprocess, evdev
from evdev import UInput, ecodes as e

def greeter_ativo():
    res = subprocess.run(["pgrep", "-f", "sddm-greeter"], stdout=subprocess.DEVNULL)
    return res.returncode == 0

time.sleep(1.5)
ui = UInput({e.EV_KEY: [e.KEY_ENTER, e.KEY_F10, e.KEY_F12, e.KEY_DOWN, e.KEY_PAGEUP, e.KEY_PAGEDOWN]}, name="Xbox360-SDDM-Bridge")
devs = {}

while greeter_ativo():
    for path in evdev.list_devices():
        if path not in devs:
            try:
                d = evdev.InputDevice(path)
                if e.EV_KEY in d.capabilities() and e.BTN_SOUTH in d.capabilities()[e.EV_KEY]:
                    devs[path] = d
            except Exception:
                pass
    for path, d in list(devs.items()):
        try:
            for ev in d.read():
                if ev.type == e.EV_KEY and ev.value == 1:
                    k = None
                    if ev.code == e.BTN_SOUTH: k = e.KEY_ENTER
                    elif ev.code == e.BTN_WEST: k = e.KEY_F10
                    elif ev.code == e.BTN_NORTH: k = e.KEY_F12
                    elif ev.code in (e.BTN_DPAD_DOWN, e.BTN_DPAD_UP): k = e.KEY_DOWN
                    elif ev.code == e.BTN_TL: k = e.KEY_PAGEUP
                    elif ev.code == e.BTN_TR: k = e.KEY_PAGEDOWN
                    if k:
                        ui.write(e.EV_KEY, k, 1); ui.syn()
                        time.sleep(0.05)
                        ui.write(e.EV_KEY, k, 0); ui.syn()
        except BlockingIOError:
            pass
        except Exception:
            del devs[path]
    time.sleep(0.05)

ui.close()
