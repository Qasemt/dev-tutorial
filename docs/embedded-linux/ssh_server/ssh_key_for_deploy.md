# 🔐 Secure Deployment Guide — Using Restricted SSH Key for Updating app-controller

This guide is designed for the development, support, and operations (DevOps) teams to securely deploy new versions of app-controller on a Linux board, without access to the system's main keys.

## 🎯 Objective

Allowing the support/development team to:

- Upload wheel and wheelhouse files
- Execute the service update script

Without full shell access or system public keys.

## 🔒 Security Principles

- No one except the system owner receives the main SSH key.
- A dedicated deployment key is used.
- The deployment key can only execute a specific script.
- System access is limited to one directory and one operation.

## 🛠️ Implementation Steps

### 1️⃣ Windows Side (Development/Deployment)

#### A) Create Deployment Key (Perform Once)

In PowerShell (in the project folder):

```powershell
ssh-keygen -t rsa -b 4096 -f .\scripts\install_script\remote\app-deploy-key -C "app-deploy-key"
```

Generated files:

- app-deploy-key → Private key (Keep secret!)
- app-deploy-key.pub → Public key (For the Linux server)

💡 Do not add these files to Git!

Add to .gitignore:

```text
scripts/install_script/remote/app-deploy-key
```

### 2️⃣ Linux Side (Target Server)

#### A) Create Restricted User (Optional but Recommended)

```bash
sudo adduser --disabled-password --gecos "" deploy
```

#### B) Add Public Key with Restrictions

```bash
sudo mkdir -p /home/deploy/.ssh
sudo nano /home/deploy/.ssh/authorized_keys
```

Write the file content like this (one complete line):

```conf
command="/usr/local/bin/app-deploy-guard.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2E... app-deploy-key
```

⚠️ Replace:

AAAAB3NzaC1yc2E... with the actual content of app-deploy-key.pub.

#### C) Set Permissions

```bash
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
```

#### D) Create Guard Script

```bash
sudo nano /usr/local/bin/app-deploy-guard.sh
```

Content:

```bash
#!/bin/bash
# Only allow update execution with valid file name

PROJECT_DIR="/root/workspace/app_controller"
UPDATE_SCRIPT="/root/update_app.sh"

# Check allowed pattern: Only execute update_app.sh with a .whl file
if [[ "$SSH_ORIGINAL_COMMAND" =~ ^bash\ /root/update_app\.sh\ [a-zA-Z0-9._-]+\.whl$ ]]; then
    # Extract file name
    WHL_FILE="${SSH_ORIGINAL_COMMAND#* }"
    exec "$UPDATE_SCRIPT" "$WHL_FILE"
else
    echo "❌ Unauthorized access. Only app-controller update is allowed."
    exit 1
fi
```

Grant execution permission:

```bash
sudo chmod +x /usr/local/bin/app-deploy-guard.sh
```

### 3️⃣ Update Deployment Script on Windows

In the file:
scripts/install_script/remote/Deploy-App.ps1

Change the ssh and scp execution lines to this:

```powershell
$SshKey = "$ScriptDir/app-deploy-key" # private key 

# Upload
scp -i "$SshKey" -r "$LocalWheelhousePath" "deploy@$LinuxIP:$RemoteProjectDir/"
scp -i "$SshKey" "$($WhlFile.FullName)" "deploy@$LinuxIP:$RemoteProjectDir/"

# Execute
ssh -i "$SshKey" "deploy@$LinuxIP" "bash $RemoteScript '$WhlName'"
```

## ✅ Benefits of This Method

| Shell access | ❌ Disabled |
| Arbitrary command execution | ❌ Prohibited |
| File upload | ✅ Only to /root/workspace/app_controller |
| Script execution | ✅ Only update_app.sh with valid .whl file |
| Password requirement | ❌ No (Automatic) |
| Main key security | ✅ Fully protected |

## 📁 Suggested Project Structure

```text
your-project/
├── build/
├── wheelhouse/
├── scripts/
│   └── install_script/
│       └── remote/
│           ├── Deploy-App.ps1
│           └── app-deploy-key          ← ❌ Do not add to Git!
│           └── app-deploy-key.pub      ← ✅ Can be in Git (optional)
└── .gitignore
```

.gitignore content:

```conf
# Deploy keys (private)
scripts/install_script/remote/app-deploy-key
```

## 📌 Important Notes

- Never place the private key (app-deploy-key) in Git, email, or chat.
- If the key is leaked, remove it from authorized_keys and create a new key.
- This method can be used for multiple servers (with separate keys).

 
