<h1 align="center">Luckfox Lyra</h1>

<p align="center">
  Networking and toolchain notes for the Luckfox Lyra family (Rockchip RK3506G2, Buildroot).
</p>

---

## Pages

| Page | Notes |
| :--- | :--- |
| [USB Internet from Windows (ICS)](./usb-internet-windows-ics.md) | Share Windows internet over USB RNDIS (`usb0`), plus an `S99net` watchdog that survives the gadget re-creating `usb0` |
| [System Clock, NTP & SSL Errors](./system-clock-ntp-ssl-fix.md) | No RTC battery → clock before 2022 → `CERTIFICATE_VERIFY_FAILED` in `pip`; Python NTP sync + `S99ntpsync` init script, pip-in-venv install notes |
| [Cross-compile Python 3.12 for 32-bit ARM](../../toolchain/Python/cross-compile-python-armhf.md) | Build on x86 with `arm-none-linux-gnueabihf`, tested on RK3506G2 — lives in Toolchain |

See also: [Rockchip](../../embedded-linux/general_config/devices/rock_chip/readme.md) setup scripts · [Raspberry Pi](../raspberry-pi/readme.md).
