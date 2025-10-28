عالی 👌
در ادامه یک راهنمای کامل و استاندارد به فرمت **Markdown** آماده کرده‌ام تا در پروژه‌تان قرار دهید.
نام پیشنهادی فایل:
📄 **`HOW_TO_CLONE_PRIVATE_REPO_ON_LINUX.md`**

---

````markdown
# 🧩 How to Clone a Private GitHub Repository on a Linux Board

This document explains how to **generate SSH keys**, **register them with GitHub**, and **clone a private repository** on a Linux-based embedded board (e.g., Raspberry Pi, BeagleBone, or industrial Linux boards).

---

## 📘 1. Prerequisites

Before starting, ensure that:
- Git is installed:  
  ```bash
  git --version
````

* SSH is installed:

  ```bash
  ssh -V
  ```
* You have **write access** to the private repository on GitHub.

---

## 🔑 2. Generate a New SSH Key (ED25519)

Generate a new SSH key **directly on the board** to ensure compatibility with its OpenSSH version.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

* When prompted for a file path, press **Enter** to accept the default:

  ```
  /root/.ssh/id_ed25519
  ```
* When prompted for a passphrase, you can leave it empty (just press Enter twice).

This creates two files:

```
/root/.ssh/id_ed25519        ← Private key (keep this secret)
/root/.ssh/id_ed25519.pub    ← Public key (safe to share)
```

---

## 🗝️ 3. Copy the Public Key

Display the public key content:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire line (starts with `ssh-ed25519`).

---

## 🌐 4. Add the SSH Key to Your GitHub Account

1. Go to **[GitHub → Settings → SSH and GPG keys](https://github.com/settings/keys)**
2. Click **“New SSH key”**
3. Set a title (e.g., `Linux Board Key`)
4. Paste the copied public key
5. Click **Add SSH key**

---

## 🔍 5. Test the SSH Connection

Run the following command:

```bash
ssh -T git@github.com
```

Expected output:

```
Hi <your-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see that message, your SSH setup is working correctly.

---

## 📥 6. Clone the Private Repository

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

## ⚙️ 7. Optional — Verify or Troubleshoot SSH Setup

If cloning fails, check the following:

| Issue             | Command to Check                              | Solution                                                    |
| ----------------- | --------------------------------------------- | ----------------------------------------------------------- |
| Wrong permissions | `ls -ld ~/.ssh` and `ls -l ~/.ssh/id_ed25519` | Run:<br>`chmod 700 ~/.ssh`<br>`chmod 600 ~/.ssh/id_ed25519` |
| Wrong Git remote  | `git remote -v`                               | Use SSH URL format:<br>`git@github.com:user/repo.git`       |
| Old/invalid key   | `ssh-add -l`                                  | Regenerate the key (Section 2)                              |

---

## ✅ 8. Summary

| Step | Action                          |
| ---- | ------------------------------- |
| 1    | Generate SSH key on the board   |
| 2    | Copy the public key             |
| 3    | Add the key to GitHub           |
| 4    | Test SSH connection             |
| 5    | Clone private repo successfully |

---

## 🧠 Notes

* Never share your **private key (`id_ed25519`)**.
* If your board is used by multiple users, store SSH keys securely.
* You can reuse this guide for any project that requires GitHub SSH authentication.




