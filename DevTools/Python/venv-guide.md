

# راهنمای ساخت و فعال‌سازی محیط مجازی (venv)

این پروژه از **Python virtual environment** (venv) استفاده می‌کند  
تا وابستگی‌ها جدا از سیستم اصلی نگه داشته شوند.

## ۱. ساخت محیط مجازی (فقط یک بار)

در ریشه پروژه اجرا کنید:

```bash
# لینوکس / macOS
python3 -m venv venv

# ویندوز (PowerShell یا CMD)
python -m venv venv
```

> **نکته**: اگر نسخه خاصی از پایتون مدنظرت است:
>
> ```bash
> python3.11 -m venv venv       # لینوکس / macOS
> py -3.11 -m venv venv          # ویندوز (با py launcher)
> ```

## ۲. فعال کردن محیط مجازی

### لینوکس / macOS
```bash
source venv/bin/activate
# یا کوتاه‌تر:
. venv/bin/activate
```

### ویندوز – PowerShell (توصیه می‌شود)
```powershell
.\venv\Scripts\Activate.ps1
```

### ویندوز – CMD
```cmd
venv\Scripts\activate.bat
```

بعد از فعال شدن، باید چیزی شبیه این ببینید:

```
(venv) user@machine:~/project$      ← لینوکس / macOS
(venv) C:\project>                  ← ویندوز
```

## ۳. نصب پکیج‌ها (بعد از فعال کردن venv)

```bash
# اگر requirements.txt داری
pip install -r requirements.txt
```

## ۴. غیرفعال کردن محیط

در هر shell فقط این را بزن:

```bash
deactivate
```

## ۵. خلاصه سریع (Cheat Sheet)

**لینوکس / macOS**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate     # برای خروج
```

**ویندوز (PowerShell)**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
deactivate     # برای خروج
```

```
py --list          # show all found Pythons
# Newest Python
py -m venv .venv

# Exactly Python 3.12
py -3.12 -m venv .venv
py -3.12 -m venv venv-312
```

