# How to Clone a Private GitHub Repository on a Linux Board

This document explains how to **generate SSH keys**, **register them with GitHub**, and **clone a private repository** on a Linux-based embedded board (e.g., Raspberry Pi, BeagleBone, or industrial Linux boards).

---

## 1. Prerequisites

Before starting, ensure that:
- Git is installed:
  ```bash
  git --version
  ```
- SSH is installed:
  ```bash
  ssh -V
  ```
- You have **write access** to the private repository on GitHub.

---

## 2. Generate a New SSH Key (ED25519)

Generate a new SSH key **directly on the board** to ensure compatibility with its OpenSSH version.

To access private repositories, you need an SSH key pair (`private` + `public`).

> The safest way is to use the **OpenSSH** format — it works on both Linux and Windows (PowerShell, Git Bash, or WSL).

### Linux / macOS
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# or with a name
ssh-keygen -t ed25519 -C "your_email@example.com" -f root/app_name
```

Then follow the prompts:

```text
Enter file in which to save the key (/root/.ssh/id_ed25519): [Press Enter]
Enter passphrase (optional): [Press Enter]
```

This creates:

```text
/root/.ssh/id_ed25519        ← private key
/root/.ssh/id_ed25519.pub    ← public key
```

### Windows (PowerShell or Git Bash)

If you are using **Git Bash** or **PowerShell (with OpenSSH client)**, you can use the exact same command:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

These keys will also be stored in:

```text
C:\Users\<username>\.ssh\id_ed25519
C:\Users\<username>\.ssh\id_ed25519.pub
```

### Easy way to generate standard keys

Use this Python script to generate a standard Ed25519 key pair (`private_key.pem` and `public_key.pem`).
The script automatically converts SSH keys into PEM format, making them fully compatible with the license manager.

```python
from pathlib import Path
import subprocess
import sys

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend


ROOT = Path(__file__).resolve().parent.parent

OUT_DIR = ROOT / "out"
OUT_DIR.mkdir(exist_ok=True)

TEMP_KEY = OUT_DIR / "temp_ed25519"
TEMP_PUB = OUT_DIR / "temp_ed25519.pub"

PRIVATE_KEY = OUT_DIR / "private_key.pem"
PUBLIC_KEY = OUT_DIR / "public_key.pem"


def run(cmd):
    print(">", " ".join(cmd))
    subprocess.run(cmd, check=True)


def main():
    try:
        # 1. generate ed25519 key (OpenSSH format)
        run([
            "ssh-keygen",
            "-t", "ed25519",
            "-C", "license@manager",
            "-f", str(TEMP_KEY),
            "-N", ""
        ])

        # 2. load private key (OpenSSH) and save as PEM
        private_bytes = TEMP_KEY.read_bytes()
        private_key = serialization.load_ssh_private_key(
            private_bytes,
            password=None,
            backend=default_backend()
        )

        PRIVATE_KEY.write_bytes(
            private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            )
        )

        # 3. load public key (OpenSSH) and save as PEM
        public_bytes = TEMP_PUB.read_bytes()
        public_key = serialization.load_ssh_public_key(
            public_bytes,
            backend=default_backend()
        )

        PUBLIC_KEY.write_bytes(
            public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
        )

        # 4. cleanup temp files
        TEMP_KEY.unlink(missing_ok=True)
        TEMP_PUB.unlink(missing_ok=True)

        print("\nKeys generated successfully!")
        print(f"Output directory: {OUT_DIR}")
        print(" - private_key.pem")
        print(" - public_key.pem")

    except Exception as e:
        print("Key generation failed:")
        print(e)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

> Do **not** use PuTTYgen unless you need `.ppk` keys.
> If you already have a PuTTY `.ppk` key, convert it using:
>
> ```bash
> puttygen mykey.ppk -O private-openssh -o id_ed25519
> ```

---

## 3. Copy the Public Key

Display the public key content:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire line (starts with `ssh-ed25519`).

---

## 4. Add the SSH Key to Your GitHub Account

1. Go to **[GitHub → Settings → SSH and GPG keys](https://github.com/settings/keys)**
2. Click **"New SSH key"**
3. Set a title (e.g., `Linux Board Key`)
4. Paste the copied public key
5. Click **Add SSH key**

---

## 5. Test the SSH Connection

Run the following command:

```bash
ssh -T git@github.com
```

Expected output:

```text
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see that message, your SSH setup is working correctly.

---

## 6. Clone the Private Repository

Now you can safely clone your private repository:

```bash
cd ~/work_space
git clone git@github.com:YourUserName/YourPrivateRepo.git
```

For example:

```bash
git clone git@github.com:qasemt/test_project.git
```

---

## 7. Optional — Verify or Troubleshoot SSH Setup

If cloning fails, check the following:

| Issue             | Command to Check                              | Solution                                                    |
| ----------------- | --------------------------------------------- | ------------------------------------------------------------ |
| Wrong permissions | `ls -ld ~/.ssh` and `ls -l ~/.ssh/id_ed25519` | Run:<br>`chmod 700 ~/.ssh`<br>`chmod 600 ~/.ssh/id_ed25519` |
| Wrong Git remote  | `git remote -v`                               | Use SSH URL format:<br>`git@github.com:user/repo.git`       |
| Old/invalid key   | `ssh-add -l`                                  | Regenerate the key (Section 2)                              |

---

## 8. Summary

| Step | Action                          |
| ---- | -------------------------------- |
| 1    | Generate SSH key on the board   |
| 2    | Copy the public key             |
| 3    | Add the key to GitHub           |
| 4    | Test SSH connection             |
| 5    | Clone private repo successfully |

---

## 9. Setting Up an SSH Config File for Automatic Connection

After testing the SSH connection with your private key successfully, you can configure the SSH config file so you don't need to specify the key path with the `-i` parameter every time.

### 9.1 Create/edit the config file
```bash
nano ~/.ssh/config
```

### 9.2 Add GitHub configuration
Add the following content to the config file:
```conf
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_git_hub
    IdentitiesOnly yes
```

### 9.3 Set proper permissions for the config file
```bash
chmod 600 ~/.ssh/config
```

### 9.4 Test automatic connection
Now test the connection without specifying the key path:
```bash
ssh -T git@github.com
```

You should receive this message:
```text
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

### Benefits of using the SSH config file
- **No need for `-i` parameter**: every time you use `git@github.com`, the specified key is automatically used
- **Multiple key management**: you can define different Hosts for various servers and services
- **Advanced settings**: ability to specify port, user, and other parameters for each Host

### Additional notes
- If you have other private keys, you can manage them by defining new Host entries in the same file
- The `IdentitiesOnly yes` option ensures only the specified key is used, ignoring other keys from ssh-agent
- The config file must have `600` permissions, otherwise SSH will ignore it
- Never share your **private key** (`id_ed25519`)
- If your board is used by multiple users, store SSH keys securely
- You can reuse this guide for any project that requires GitHub SSH authentication

---

See also: [SSH Config for VS Code](SSH_Config_for_VSCode.md) · [SSH key for deploy](ssh_key_for_deploy.md)
