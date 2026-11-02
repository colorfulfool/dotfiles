#!/usr/bin/env python3
import os
import sys
import time

import evdev
from evdev import ecodes

DEVICE_NAME = os.environ.get("MOUSE_NAME", "ProtoArc EM11 NL")
MODIFIER_NAME = os.environ.get("MOUSE_BUTTON", "BTN_SIDE")
INVERT = os.environ.get("HORIZONTAL_INVERT", "0") not in ("", "0")
MODIFIER = getattr(ecodes, MODIFIER_NAME, ecodes.BTN_SIDE)
WHEEL_CODES = {
    ecodes.REL_WHEEL: ecodes.REL_HWHEEL,
    ecodes.REL_WHEEL_HI_RES: ecodes.REL_HWHEEL_HI_RES,
}


def find_device():
    for path in evdev.list_devices():
        try:
            device = evdev.InputDevice(path)
        except (OSError, PermissionError):
            continue
        keys = device.capabilities().get(ecodes.EV_KEY, [])
        if device.name == DEVICE_NAME and MODIFIER in keys:
            return device
        device.close()
    return None


def make_uinput(source):
    caps = {kind: list(codes) for kind, codes in source.capabilities().items()}
    caps.pop(ecodes.EV_SYN, None)
    rels = set(caps.get(ecodes.EV_REL, []))
    rels.update(WHEEL_CODES.values())
    caps[ecodes.EV_REL] = sorted(rels)
    return evdev.UInput(
        caps,
        name=f"{source.name} horizontal wheel",
        vendor=source.info.vendor,
        product=source.info.product,
        version=source.info.version,
        bustype=source.info.bustype,
        phys=source.phys,
    )


def click(ui, code):
    ui.write(ecodes.EV_KEY, code, 1)
    ui.syn()
    ui.write(ecodes.EV_KEY, code, 0)
    ui.syn()


def run(source):
    source.grab()
    ui = make_uinput(source)
    held = False
    used = False
    try:
        for event in source.read_loop():
            if event.type == ecodes.EV_KEY and event.code == MODIFIER:
                if event.value == 1:
                    held = True
                    used = False
                elif event.value == 0:
                    if held and not used:
                        click(ui, MODIFIER)
                    held = False
                    used = False
                continue

            if event.type == ecodes.EV_REL and event.code in WHEEL_CODES:
                if held:
                    used = True
                    event.code = WHEEL_CODES[event.code]
                    if INVERT:
                        event.value = -event.value

            ui.write_event(event)
    finally:
        ui.close()
        source.close()


def main():
    while True:
        source = find_device()
        if source is None:
            time.sleep(1)
            continue
        try:
            run(source)
        except (OSError, evdev.UInputError) as error:
            print(f"horizontal-wheel: {error}", file=sys.stderr, flush=True)
            time.sleep(1)


if __name__ == "__main__":
    main()
