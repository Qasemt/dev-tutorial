### Hide boot messages on screen
```bash
Edit the /boot/cmdline.txt file:

sudo nano /boot/cmdline.txt
Make these changes:

Replace “console=tty1” with “console=tty3” to redirect boot messages to the third console.

Add “loglevel=3” to disable non-critical kernel log messages.

Add “vt.global_cursor_default=0” to disable the blinking cursor.
```
