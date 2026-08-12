<h1 align="center">Raspberry Pi</h1>

<p align="center">
  Boot, display, GPIO, and USB notes for Raspberry Pi boards.
</p>

---

## Hardware

| Page | Notes |
| :--- | :--- |
| [Pinout & GPIO](./pinout.md) | Pinout diagrams, GPIO commands, relay wiring, LCD 1602 wiring |
| [Relay Wiring (PDF)](./RelayWiring.pdf) | Reference diagram |
| [Raspi Dependencies](./raspi-dependencies.md) | Qt/GStreamer build dependencies |

## Boot & Display

| Page | Notes |
| :--- | :--- |
| [Custom Boot-up Screen](./Custom_boot_up_screen.md) | Replacing the boot splash with `fbi` |
| [Hide Boot Messages](./Hide_Boot_Messages.md) | Editing `cmdline.txt` |
| [Resolution (VNC & TV/Monitor)](./resolution_pi.md) | Forcing HDMI mode and resolution in `config.txt` |

## System

| Page | Notes |
| :--- | :--- |
| [General Configuration](./general_config.md) | Boot app setup |
| [USB Action](./usb_action.md) | udev rule for USB insert/remove events |

See also: [BeagleBone Black](../../embedded-linux/general_config/devices/beaglebone_black.md) · [Rockchip](../../embedded-linux/general_config/devices/rock_chip/readme.md) for other boards.
