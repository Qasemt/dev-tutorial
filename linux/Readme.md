Debian Bootstrap Scripts

These scripts are designed for quickly bootstrapping fresh Debian 12 (Bookworm) and Debian 13 (Trixie) systems. They automatically:

- Configure APT sources
- Update the system
- Install build dependencies for Python
- Compile and install Python 3.12.5 from source (using altinstall)
- Enable root SSH login (for testing/internal use only)

⚠️ Security Warning: Enabling "PermitRootLogin yes" is dangerous in production environments. Use only in trusted/internal networks.

Available Scripts:

- bootstrap-debian12.sh → For Debian 12 (Bookworm)
- bootstrap-debian13.sh → For Debian 13 (Trixie)

How to Run:

1. (Recommended) Review the script first:
   curl -s https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian12.sh
   # or for Debian 13:
   curl -s https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian13.sh

2. Download and run:
   # Debian 12:
   wget https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian12.sh
   chmod +x bootstrap-debian12.sh
   sudo ./bootstrap-debian12.sh

   # Debian 13:
   wget https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian13.sh
   chmod +x bootstrap-debian13.sh
   sudo ./bootstrap-debian13.sh

3. (Optional) Run directly without saving:
   # Debian 12:
   sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian12.sh)"

   # Debian 13:
   sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/Qasemt/dev-tutorial/master/linux/bootstrap-debian13.sh)"

After Installation:

- Python 3.12.5 is available as:
    python3.12.5 --version

- Create a virtual environment:
    python3.12.5 -m venv .venv
    source .venv/bin/activate

Technical Notes:

- Uses 'make altinstall' to avoid overriding the system python3.
- GCC 12 (on Debian 12) or the default compiler (on Debian 13) is sufficient.
- Designed for clean/fresh OS installations.

Common Issues:

- "command not found" for python3.12.5 → Ensure /usr/local/bin is in your PATH.
- Missing compiler → The script installs build-essential automatically.
- SSL or SQLite issues → Required dev packages are included in the install list.

Developer: Qasemt (https://github.com/Qasemt)
