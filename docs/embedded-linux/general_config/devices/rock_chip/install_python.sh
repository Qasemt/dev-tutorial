#!/bin/bash
# ============================================================
#  install_python_portable.sh — Standalone Python 3.12.5 installer
#
#  Usage:
#    wget -qO- https://raw.githubusercontent.com/Qasemt/dev-tutorial/refs/heads/master/LinuxEmbeddedSystems/general_config/devices/rock_chip/install_python.sh | sudo bash
#
#  This script:
#    - Downloads portable Python 3.12.5 for aarch64 from Dropbox
#    - Installs it to /usr/local
#    - Creates symlinks (python3, pip3)
#    - Sets up ldconfig
#    - No other system changes
# ============================================================
set -o pipefail

# ================= CONFIG =================
PYTHON_ARCHIVE_NAME="python-3.12.5-aarch64.tar.gz"
PYTHON_URL="https://www.dropbox.com/scl/fi/knukx9zmgce00vyzw7f0f/python-3.12.5-aarch64.tar.gz?rlkey=ffk30peywqk07y9b3d0gg4hks&st=f6ipqmz9&dl=0"
INSTALL_PREFIX="/usr/local"
WORK_DIR="/tmp/python_install_$$"
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error()   { echo -e "${RED}✖ $1${NC}" >&2; }
log_success() { echo -e "${GREEN}✔ $1${NC}"; }
log_info()    { echo -e "${YELLOW}ℹ️  $1${NC}"; }
error_exit()  { log_error "$1"; exit 1; }

# Check if running as root
[ "$(id -u)" -eq 0 ] || error_exit "This script must be run as root: sudo bash $0"

# Check if already installed
if [ -x "$INSTALL_PREFIX/bin/python3.12" ]; then
    CURRENT_VERSION=$("$INSTALL_PREFIX/bin/python3.12" --version 2>&1)
    if echo "$CURRENT_VERSION" | grep -q "3.12"; then
        log_success "Python 3.12 is already installed: $CURRENT_VERSION"
        log_info "Location: $INSTALL_PREFIX/bin/python3.12"
        exit 0
    fi
fi

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    log_info "Warning: Current architecture is '$ARCH', but the archive is for 'aarch64'"
    log_info "The script will continue, but Python may not work on this system."
    sleep 3
fi

# Create temporary work directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || error_exit "Cannot enter $WORK_DIR"

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    cd /
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# Download Python archive
log_info "Downloading Python 3.12.5 for aarch64..."
log_info "Source: Dropbox"

# Force direct download (dl=1)
DOWNLOAD_URL="${PYTHON_URL//dl=0/dl=1}"
case "$DOWNLOAD_URL" in
    *dl=1*) ;;
    *) DOWNLOAD_URL="${DOWNLOAD_URL}&dl=1" ;;
esac

# Try wget first, fallback to curl
if command -v wget &>/dev/null; then
    log_info "Using wget to download..."
    if ! wget --progress=bar:force -O "$PYTHON_ARCHIVE_NAME" "$DOWNLOAD_URL" 2>&1; then
        log_error "wget failed to download Python archive"
        log_info "Trying curl as fallback..."
        
        if command -v curl &>/dev/null; then
            if ! curl -L --progress-bar -o "$PYTHON_ARCHIVE_NAME" "$DOWNLOAD_URL"; then
                error_exit "Both wget and curl failed to download the archive"
            fi
        else
            error_exit "Neither wget nor curl is available. Install one of them first."
        fi
    fi
elif command -v curl &>/dev/null; then
    log_info "Using curl to download..."
    if ! curl -L --progress-bar -o "$PYTHON_ARCHIVE_NAME" "$DOWNLOAD_URL"; then
        error_exit "curl failed to download Python archive"
    fi
else
    error_exit "Neither wget nor curl is available. Install one of them first."
fi

# Verify download
if [ ! -f "$PYTHON_ARCHIVE_NAME" ]; then
    error_exit "Download failed - archive file not found"
fi

ARCHIVE_SIZE=$(stat -c%s "$PYTHON_ARCHIVE_NAME" 2>/dev/null || stat -f%z "$PYTHON_ARCHIVE_NAME" 2>/dev/null)
if [ "$ARCHIVE_SIZE" -lt 1000000 ]; then  # Less than 1MB is suspicious
    log_info "Warning: Archive size is only ${ARCHIVE_SIZE} bytes. This might be an HTML error page."
    log_info "First few bytes of the file:"
    head -c 200 "$PYTHON_ARCHIVE_NAME" | cat -v
    error_exit "Download appears to be invalid. Check the URL or network connectivity."
fi

# Test archive integrity
log_info "Testing archive integrity..."
if ! tar tzf "$PYTHON_ARCHIVE_NAME" > /dev/null 2>&1; then
    error_exit "Archive is corrupted or not a valid tar.gz file"
fi

log_success "Download complete ($(du -h "$PYTHON_ARCHIVE_NAME" | cut -f1))"

# Extract to /usr/local
log_info "Installing Python to $INSTALL_PREFIX ..."
if ! tar xzf "$PYTHON_ARCHIVE_NAME" -C "$INSTALL_PREFIX"; then
    error_exit "Failed to extract Python archive to $INSTALL_PREFIX"
fi

# Set up library path
echo "$INSTALL_PREFIX/lib" > /etc/ld.so.conf.d/python3.12.conf
ldconfig

# Create symlinks if they don't exist
if ! command -v python3 &>/dev/null; then
    ln -sf "$INSTALL_PREFIX/bin/python3.12" "$INSTALL_PREFIX/bin/python3"
    log_success "Created symlink: python3 -> python3.12"
fi

if ! command -v pip3 &>/dev/null; then
    if [ -x "$INSTALL_PREFIX/bin/pip3.12" ]; then
        ln -sf "$INSTALL_PREFIX/bin/pip3.12" "$INSTALL_PREFIX/bin/pip3"
        log_success "Created symlink: pip3 -> pip3.12"
    fi
fi

# Verify installation
if ! "$INSTALL_PREFIX/bin/python3.12" --version &>/dev/null; then
    log_error "Python 3.12.5 installed but cannot execute. Checking dependencies..."
    ldd "$INSTALL_PREFIX/bin/python3.12" | grep "not found"
    error_exit "Python installation failed - missing system libraries"
fi

# Test basic functionality
INSTALLED_VERSION=$("$INSTALL_PREFIX/bin/python3.12" --version 2>&1)
log_success "Python installed successfully: $INSTALLED_VERSION"

# Test pip
if "$INSTALL_PREFIX/bin/python3.12" -m pip --version &>/dev/null; then
    log_success "pip is functional"
else
    log_info "pip needs setup - running ensurepip..."
    "$INSTALL_PREFIX/bin/python3.12" -m ensurepip --upgrade 2>/dev/null || log_info "pip setup failed (may need manual installation)"
fi

# Test venv module
if "$INSTALL_PREFIX/bin/python3.12" -m venv --help &>/dev/null; then
    log_success "venv module is available"
else
    log_info "Warning: venv module is not available. Virtual environments won't work."
fi

# Add to PATH if needed (optional)
log_info ""
log_info "========================================="
log_info "Python 3.12.5 installation complete!"
log_info "Location: $INSTALL_PREFIX/bin/python3.12"
log_info "Version:  $INSTALLED_VERSION"
log_info ""
log_info "To use immediately:"
log_info "  export PATH=$INSTALL_PREFIX/bin:\$PATH"
log_info ""
log_info "To add permanently:"
log_info "  echo 'export PATH=$INSTALL_PREFIX/bin:\$PATH' >> ~/.bashrc"
log_info "========================================="

exit 0
