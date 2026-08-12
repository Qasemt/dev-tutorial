cat > install_python_buildroot.sh << 'EOF'
#!/bin/bash
# ============================================================
# install_python_buildroot.sh
# Install Python 3.12.5 on Buildroot systems (no package manager)
#
# Usage:
#   1. Download python-3.12.5-aarch64.tar.gz to /root/work_space/
#      (via SCP: scp python-3.12.5-aarch64.tar.gz root@IP:/root/work_space/)
#   2. Run: bash install_python_buildroot.sh
#
# Features:
#   - No wget/curl needed (uses local archive)
#   - Works on BusyBox systems
#   - Creates all necessary directories
#   - Sets up permanent PATH
#   - Survives reboot
# ============================================================

set -e

# ================= CONFIG =================
ARCHIVE_NAME="python-3.12.5-aarch64.tar.gz"
ARCHIVE_DIR="/root/work_space"
INSTALL_PREFIX="/usr/local"
# ==========================================

echo "========================================="
echo "  Python 3.12.5 - Buildroot Installer"
echo "========================================="
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run as root: bash $0"
    exit 1
fi

# Check archive
if [ ! -f "$ARCHIVE_DIR/$ARCHIVE_NAME" ]; then
    echo "ERROR: $ARCHIVE_NAME not found in $ARCHIVE_DIR"
    echo ""
    echo "Please transfer the file first:"
    echo "  scp $ARCHIVE_NAME root@BOARD_IP:$ARCHIVE_DIR/"
    exit 1
fi

# Check if already installed
if [ -x "$INSTALL_PREFIX/bin/python3.12" ]; then
    echo "✓ Python already installed: $($INSTALL_PREFIX/bin/python3.12 --version)"
    echo "  Location: $INSTALL_PREFIX/bin/python3.12"
    exit 0
fi

echo "Step 1/6: Creating directories..."
mkdir -p "$INSTALL_PREFIX"
mkdir -p /etc/ld.so.conf.d
mkdir -p /etc/profile.d

echo "Step 2/6: Extracting archive ($(du -h "$ARCHIVE_DIR/$ARCHIVE_NAME" | cut -f1))..."
tar xzf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$INSTALL_PREFIX"
echo "  ✓ Extracted to $INSTALL_PREFIX"

echo "Step 3/6: Setting up libraries..."
echo "$INSTALL_PREFIX/lib" > /etc/ld.so.conf.d/python3.12.conf
echo "$INSTALL_PREFIX/lib" >> /etc/ld.so.conf
ldconfig 2>/dev/null || echo "  (ldconfig not available - skipping)"

echo "Step 4/6: Creating symlinks..."
# Create symlinks in multiple locations for compatibility
for target in /usr/bin /usr/local/bin /bin; do
    mkdir -p "$target"
    ln -sf "$INSTALL_PREFIX/bin/python3.12" "$target/python3" 2>/dev/null || true
    if [ -x "$INSTALL_PREFIX/bin/pip3.12" ]; then
        ln -sf "$INSTALL_PREFIX/bin/pip3.12" "$target/pip3" 2>/dev/null || true
    fi
done
echo "  ✓ Symlinks created"

echo "Step 5/6: Setting up PATH permanently..."
# Add to bashrc
touch /root/.bashrc
grep -q "$INSTALL_PREFIX/bin" /root/.bashrc || \
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> /root/.bashrc

# Add to profile
echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" > /etc/profile.d/python.sh
chmod +x /etc/profile.d/python.sh

# Set for current session
export PATH="$INSTALL_PREFIX/bin:$PATH"
echo "  ✓ PATH configured"

echo "Step 6/6: Verifying installation..."
echo ""

# Test Python
if "$INSTALL_PREFIX/bin/python3.12" --version >/dev/null 2>&1; then
    VERSION=$("$INSTALL_PREFIX/bin/python3.12" --version 2>&1)
    echo "  ✓ Python: $VERSION"
else
    echo "  ✖ Python failed to run!"
    echo "  Checking dependencies..."
    ldd "$INSTALL_PREFIX/bin/python3.12" 2>/dev/null | grep "not found" || echo "  (ldd not available)"
    exit 1
fi

# Test pip
if "$INSTALL_PREFIX/bin/pip3.12" --version >/dev/null 2>&1; then
    PIP_VERSION=$("$INSTALL_PREFIX/bin/pip3.12" --version 2>&1)
    echo "  ✓ Pip: $PIP_VERSION"
else
    echo "  ⚠ Pip needs setup - running ensurepip..."
    "$INSTALL_PREFIX/bin/python3.12" -m ensurepip --upgrade 2>/dev/null || echo "  (ensurepip failed - may need manual setup)"
fi

# Test imports
echo "  ✓ Testing basic imports..."
"$INSTALL_PREFIX/bin/python3.12" -c "import sys, os, json, sqlite3, ssl; print('    sys:', sys.version)" 2>/dev/null || \
    echo "  ⚠ Some modules missing (normal for minimal Python)"

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
echo "  Python:  $INSTALL_PREFIX/bin/python3.12"
echo "  Version: $VERSION"
echo ""
echo "  To use now:"
echo "    source /root/.bashrc"
echo "    python3 --version"
echo ""
echo "  After reboot:"
echo "    python3 --version"
echo ""
echo "  Note: PATH is saved in /root/.bashrc"
echo "========================================="
EOF

chmod +x install_python_buildroot.sh
