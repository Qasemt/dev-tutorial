# Update Boards

Provisioning/update scripts for a car-PC style board application (GIS data, voice files, and a `vtl` binary, backed by a local SQLite `app.db3`). No further documentation existed for this project — descriptions below are inferred from the scripts themselves; verify before relying on them.

| File | What it appears to do |
| :--- | :--- |
| `linuxscript.sh` | Detects an inserted USB drive and drives a flash/update flow onto the board (`flashpath` argument, folder-name detection). |
| `packmaker.sh` | Packages `gisdata`, `voices`, `vtl`, and `data` folders from a device into a `pack.tar.gz` update bundle. |
| `USBUpdate.txt` | udev rule + `myusblinker.sh` script to auto-mount/unmount USB drives — the trigger that `linuxscript.sh` likely relies on. |
| `Script/1.altertable.sh` | Template for an SQLite `ALTER TABLE` migration against `app.db3` (currently an empty statement — fill in before use). |
| `Script/2.bulkinsert.sh` | Runs the three bulk-insert scripts below against the same database. |
| `Script/bulkinsert/bulk_lines.sh`, `bulk_linestation.sh`, `bulk_station.sh` | Bulk-insert transit line/station data into `app.db3`. |
