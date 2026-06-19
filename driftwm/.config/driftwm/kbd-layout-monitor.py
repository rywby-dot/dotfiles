#!/usr/bin/env python3
import evdev, os, sys, selectors, signal as _signal, time

LAYOUT_FILE = "/tmp/kbd_layout"
PID_FILE    = "/tmp/kbd_layout_daemon.pid"
LAYOUTS     = ["EN", "RU"]

SHIFT_KEYS  = frozenset({                                          # 
    evdev.ecodes.KEY_LEFTSHIFT,                                    # 
    evdev.ecodes.KEY_RIGHTSHIFT,                                   # 
})                                                                 # 

def find_keyboards():
    kbs = []
    for path in evdev.list_devices():
        try:
            dev  = evdev.InputDevice(path)
            keys = dev.capabilities().get(evdev.ecodes.EV_KEY, [])
            if (evdev.ecodes.KEY_CAPSLOCK in keys and
                    evdev.ecodes.KEY_A in keys and
                    "kbd-layout-ctrl" not in dev.name):
                kbs.append(dev)
        except Exception:
            pass
    return kbs

def write_layout():
    with open(LAYOUT_FILE, "w") as f:
        f.write(LAYOUTS[idx] + "\n")
    os.system("pkill -SIGRTMIN+8 waybar")

def switch_to(target):
    global idx
    target_idx = LAYOUTS.index(target)
    if target_idx == idx:
        return
    ui.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_CAPSLOCK, 1)
    ui.write(evdev.ecodes.EV_SYN, evdev.ecodes.SYN_REPORT,  0)
    ui.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_CAPSLOCK, 0)
    ui.write(evdev.ecodes.EV_SYN, evdev.ecodes.SYN_REPORT,  0)
    idx = target_idx
    write_layout()

# init
try:
    current = open(LAYOUT_FILE).read().strip()
    idx = LAYOUTS.index(current) if current in LAYOUTS else 0
except Exception:
    idx = 0

try:
    ui = evdev.UInput(
        {evdev.ecodes.EV_KEY: [evdev.ecodes.KEY_CAPSLOCK,
                                evdev.ecodes.KEY_A,
                                evdev.ecodes.KEY_Z]},
        name="kbd-layout-ctrl"
    )
    time.sleep(0.5)
except PermissionError:
    sys.exit("Нет доступа к /dev/uinput — проверь udev-правило")

with open(PID_FILE, "w") as f:
    f.write(str(os.getpid()) + "\n")

_sig_r, _sig_w = os.pipe()

def _on_signal(signum, frame):
    target = b"EN\n" if signum == _signal.SIGUSR1 else b"RU\n"
    try:
        os.write(_sig_w, target)
    except Exception:
        pass

_signal.signal(_signal.SIGUSR1, _on_signal)
_signal.signal(_signal.SIGUSR2, _on_signal)

keyboards = find_keyboards()
if not keyboards:
    sys.exit("Клавиатура не найдена — ты в группе input?")

sel = selectors.DefaultSelector()
for kb in keyboards:
    sel.register(kb, selectors.EVENT_READ)
sel.register(_sig_r, selectors.EVENT_READ)

shift_held = False                                                 # 

while True:
    try:
        events = sel.select()
    except InterruptedError:
        continue
    for key, _ in events:
        if key.fd == _sig_r:
            try:
                data = os.read(_sig_r, 32).decode().strip().upper()
                for line in data.splitlines():
                    if line in LAYOUTS:
                        switch_to(line)
            except Exception:
                pass
        else:
            try:
                for event in key.fileobj.read():
                    if event.type != evdev.ecodes.EV_KEY:          # 
                        continue                                    # 
                    if event.code in SHIFT_KEYS:                   # 
                        shift_held = (event.value != 0)            # 
                    elif (event.code  == evdev.ecodes.KEY_CAPSLOCK
                          and event.value == 1
                          and not shift_held):                     # 
                        idx = (idx + 1) % len(LAYOUTS)
                        write_layout()
            except Exception:
                pass
