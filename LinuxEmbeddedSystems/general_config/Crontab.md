Guide to Fix Crontab Error and Set Up Automatic Script Execution

1. Install Cron
sudo apt-get update
sudo apt-get install cron
sudo systemctl enable cron
sudo systemctl start cron
sudo systemctl status cron  # Check status

2. Configure Crontab
crontab -e  # Edit cron file

Add the following line:
@reboot python3 /full/path/to/script.py

Set executable permission:
chmod +x /full/path/to/script.py

3. Alternative Method (Systemd)
sudo nano /etc/systemd/system/auto_script.service

Service file content:
[Unit]
Description=Run script automatically

[Service]
ExecStart=/usr/bin/python3 /full/path/to/script.py
Restart=always
User=username

[Install]
WantedBy=multi-user.target

Enable the service:
sudo systemctl enable auto_script.service
sudo systemctl start auto_script.service
sudo systemctl status auto_script.service  # Check status

For stop and disable:
sudo systemctl stop auto_script.service
sudo systemctl disable auto_script.service # for disable in boot 
sudo systemctl status auto_script.service  # Check status

4. Important Notes
- Find the script path using pwd in the terminal
- Use #!/usr/bin/env python3 at the top of Python scripts
- Add logging with >> /path/to/log.txt 2>&1 in crontab

Usage Guide:
Save this file as cron_setup_guide.txt and view it with any text editor.
