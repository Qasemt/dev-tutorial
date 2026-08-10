<div align="center">

# 🐈 Nekoray — Linux Setup

**AppImage · Qt5 dependencies · x64**

`v4.0.1` · build `2024-12-12`

</div>

---

## 📦 1. Install Dependencies

The AppImage needs a few Qt5 / XCB libraries that are not always present on a
fresh system:

```bash
sudo apt install libpcre2-16-0
```

```bash
sudo apt install libpcre2-16-0 libxcb-xinerama0 libxcb-cursor0 libqt5gui5
```

<details>
<summary><b>What each package is for</b></summary>

| Package | Purpose |
| :--- | :--- |
| `libpcre2-16-0` | 16-bit PCRE2 regex library required by Qt |
| `libxcb-xinerama0` | Multi-monitor support for the X11 backend |
| `libxcb-cursor0` | Cursor rendering under XCB |
| `libqt5gui5` | Core Qt5 GUI runtime |

</details>

---

## 🚀 2. Run the AppImage

```bash
./nekoray-4.0.1-2024-12-12-linux-x64.AppImage
```

> [!TIP]
> If the file refuses to launch, make it executable first:
> ```bash
> chmod +x nekoray-4.0.1-2024-12-12-linux-x64.AppImage
> ```

---

## ✅ Quick Reference

```text
1. sudo apt install libpcre2-16-0
2. sudo apt install libpcre2-16-0 libxcb-xinerama0 libxcb-cursor0 libqt5gui5
3. ./nekoray-4.0.1-2024-12-12-linux-x64.AppImage
```

---

<div align="center"><sub>Nekoray setup notes</sub></div>
