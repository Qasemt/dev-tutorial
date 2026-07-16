#!/bin/bash
# ============================================================
#  setup_board.sh — ONE-SHOT BOARD INSTALLER (self-contained)
#
#  Usage (one-liner from GitHub):
#
#    wget -O setup_board.sh https://raw.githubusercontent.com/USER/REPO/master/setup_board.sh
#    sudo bash setup_board.sh
#
#  or directly:
#
#    wget -qO- https://raw.githubusercontent.com/USER/REPO/master/setup_board.sh | sudo bash
#
#  What it does (fully automatic, no questions):
#    1) Board base config (no proxy / no static IP)
#    2) Download + install portable Python 3.12.5 (aarch64) -> /usr/local
#    3) Download wheels from MEGA (via megatools) if not present
#    4) Install padiscontroller + paku as systemd services
#       (each in its own folder under /root/work_space)
#    5) Point paku's config.yaml at wherever padiscontroller actually got
#       installed by this script (paths.project_dist_dir/_name/_entry_point/
#       files_dist_dir), so paku can control it without manual editing.
#
#  Everything happens inside /root/work_space/
# ============================================================
set -o pipefail

# ================= CONFIG (edit before pushing to GitHub) =================
WORK_SPACE="/root/work_space"

PYTHON_ARCHIVE_NAME="python-3.12.5-aarch64.tar.gz"
PYTHON_URL="https://www.dropbox.com/scl/fi/knukx9zmgce00vyzw7f0f/python-3.12.5-aarch64.tar.gz?rlkey=ffk30peywqk07y9b3d0gg4hks&st=f6ipqmz9&dl=0"

# Dropbox links for the wheels
# (dl=0 or dl=1 — the script converts to direct download automatically)
PADIS_WHEEL_NAME="padiscontroller-0.0.52-py3-none-any.whl"
PADIS_WHEEL_URL="https://www.dropbox.com/scl/fi/ldbckhb6myrxi0dl8evh5/padiscontroller-0.0.52-py3-none-any.whl?rlkey=a9vqx505baevvoidkdyzw9e1t&st=aanf7upg&dl=0"

PAKU_WHEEL_NAME="paku-0.0.9-py3-none-any.whl"
PAKU_WHEEL_URL="https://www.dropbox.com/scl/fi/pcarsnc7497xzrtl1s6y3/paku-0.0.9-py3-none-any.whl?rlkey=8c3moh48l3ewprxaczoa2oz31&st=wjgj9k4s&dl=0"
# ===========================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_error()   { echo -e "${RED}✖ $1${NC}" >&2; }
log_success() { echo -e "${GREEN}✔ $1${NC}"; }
log_info()    { echo -e "${YELLOW}ℹ️  $1${NC}"; }
log_action()  { echo -e "${BLUE}🔧 $1${NC}"; }
log_step()    { echo -e "\n${BLUE}=====================================================\n🔧 STEP $1\n=====================================================${NC}"; }
error_exit()  { log_error "$1"; exit 1; }

[ "$(id -u)" -eq 0 ] || error_exit "Run as root:  sudo bash $0"

mkdir -p "$WORK_SPACE"
cd "$WORK_SPACE" || error_exit "Cannot enter $WORK_SPACE"

LOG_FILE="$WORK_SPACE/setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
log_info "Workspace: $WORK_SPACE"
log_info "Log file:  $LOG_FILE"

FAILED=()

# ============================================================
# STEP 1 — Board base configuration (no proxy / no static IP)
# ============================================================
step_board_config() {
    export DEBIAN_FRONTEND=noninteractive

    log_action "Commenting out outdated bullseye-backports repositories..."
    sed -i '/bullseye-backports/s/^[^#]/#&/' /etc/apt/sources.list 2>/dev/null
    if ls /etc/apt/sources.list.d/*.list &>/dev/null; then
        sed -i '/bullseye-backports/s/^[^#]/#&/' /etc/apt/sources.list.d/*.list 2>/dev/null
    fi

    log_action "Updating package list..."
    apt-get update -y || log_info "apt update reported errors (continuing)..."

    log_action "Installing core packages..."
    apt-get install -y nano git net-tools locales curl wget tar || log_info "Some packages failed (continuing)..."

    log_action "Disabling Bluetooth..."
    systemctl stop bluetooth 2>/dev/null
    systemctl disable bluetooth 2>/dev/null
    systemctl mask bluetooth 2>/dev/null

    log_action "Configuring locale en_US.UTF-8..."
    if [ -f /etc/locale.gen ]; then
        sed -i 's/^zh_CN.UTF-8/# zh_CN.UTF-8/' /etc/locale.gen
        sed -i 's/^#\s*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    fi
    locale-gen --purge en_US.UTF-8 || log_info "locale-gen issue (continuing)..."
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 2>/dev/null
    export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

    local bashrc="/root/.bashrc"; touch "$bashrc"
    sed -i '/zh_CN.UTF-8/d;/en_US.UTF-8/d' "$bashrc" 2>/dev/null
    {
        echo 'export LANG=en_US.UTF-8'
        echo 'export LC_ALL=en_US.UTF-8'
        echo 'export LANGUAGE=en_US.UTF-8'
    } >> "$bashrc"

    local sshd="/etc/ssh/sshd_config"
    if [ -f "$sshd" ]; then
        log_action "Allowing SSH root login..."
        sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$sshd"
        grep -q '^PermitRootLogin' "$sshd" || echo 'PermitRootLogin yes' >> "$sshd"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    fi

    log_success "Board base configuration done."
    return 0
}

# ============================================================
# STEP 2 — Install portable Python 3.12.5 into /usr/local
# ============================================================
step_install_python() {
    local prefix="/usr/local"

    if [ -x "$prefix/bin/python3.12" ] && "$prefix/bin/python3.12" --version 2>/dev/null | grep -q "3.12"; then
        log_success "Python already installed: $("$prefix/bin/python3.12" --version) — skipping."
        return 0
    fi

    [ "$(uname -m)" = "aarch64" ] || log_info "Warning: arch is $(uname -m), archive is for aarch64."

    local archive=""
    for c in "$WORK_SPACE/$PYTHON_ARCHIVE_NAME" "/root/$PYTHON_ARCHIVE_NAME" "$WORK_SPACE"/python-3.12.5-*.tar.gz; do
        [ -f "$c" ] && { archive="$c"; break; }
    done

    if [ -z "$archive" ]; then
        dropbox_download "$PYTHON_URL" "$WORK_SPACE/$PYTHON_ARCHIVE_NAME" \
            || { log_error "Download failed. Put $PYTHON_ARCHIVE_NAME in $WORK_SPACE and re-run."; return 1; }
        archive="$WORK_SPACE/$PYTHON_ARCHIVE_NAME"
    fi

    log_info "Using archive: $archive"
    tar tzf "$archive" > /dev/null 2>&1 || { log_error "Archive corrupted."; return 1; }

    log_action "Extracting into $prefix ..."
    tar xzf "$archive" -C "$prefix" || { log_error "Extraction failed."; return 1; }

    echo "$prefix/lib" > /etc/ld.so.conf.d/python3.12.conf
    ldconfig

    command -v python3 &>/dev/null || ln -sf "$prefix/bin/python3.12" "$prefix/bin/python3"
    command -v pip3 &>/dev/null || { [ -x "$prefix/bin/pip3.12" ] && ln -sf "$prefix/bin/pip3.12" "$prefix/bin/pip3"; }

    local ver; ver=$("$prefix/bin/python3.12" --version 2>&1) \
        || { log_error "python3.12 does not run. Check: ldd $prefix/bin/python3.12"; return 1; }
    log_success "Installed: $ver"

    "$prefix/bin/python3.12" -m ensurepip --upgrade 2>/dev/null || true
    "$prefix/bin/python3.12" -m venv --help &>/dev/null || log_info "venv module missing — services will fail!"
    return 0
}

# ============================================================
# Dropbox download helper (forces direct download: dl=0 -> dl=1)
# ============================================================
dropbox_download() {
    local url="$1" dest="$2"
    # Force direct download
    url="${url//dl=0/dl=1}"
    case "$url" in *dl=1*) : ;; *) url="${url}&dl=1" ;; esac

    log_action "Downloading $(basename "$dest") from Dropbox..."
    if command -v wget &>/dev/null; then
        wget -O "$dest" "$url" && return 0
    fi
    if command -v curl &>/dev/null; then
        curl -L -o "$dest" "$url" && return 0
    fi
    log_error "Download failed: $url"
    rm -f "$dest"
    return 1
}

# ============================================================
# STEP 3/4 — Generic service installer (venv + wheel + systemd)
#   args: app_name  wheel_pattern  service_name  service_desc  wheel_name  wheel_url  preferred_bins...
#
#   On success, records where it installed things into two globals so later
#   steps (see configure_paku_paths below) can wire paku to the real path:
#     LAST_INSTALL_DIR   -> absolute path of $project_dir
#     LAST_INSTALL_EXEC  -> basename of the detected venv/bin executable
# ============================================================
install_app_service() {
    local app_name="$1" wheel_pattern="$2" service_name="$3" service_desc="$4" wheel_name="$5" wheel_url="$6"
    shift 6
    local preferred_bins=("$@")

    local project_dir="$WORK_SPACE/$app_name"
    local venv_dir="$project_dir/.venv"
    local runner="$project_dir/app_runner.sh"
    local wheelhouse="$project_dir/wheelhouse"
    local service_file="/etc/systemd/system/$service_name"

    mkdir -p "$project_dir"
    LAST_INSTALL_DIR="$project_dir"
    LAST_INSTALL_EXEC=""

    # --- find wheel (or download from Dropbox) ---
    local wheels=( "$project_dir"/$wheel_pattern )
    if [ ! -e "${wheels[0]}" ] && [ -n "$wheel_url" ]; then
        dropbox_download "$wheel_url" "$project_dir/$wheel_name" || true
        wheels=( "$project_dir"/$wheel_pattern )
    fi
    if [ ! -e "${wheels[0]}" ]; then
        wheels=( "$project_dir"/*.whl )   # fallback: any wheel
    fi
    [ -e "${wheels[0]}" ] || { log_error "[$app_name] No wheel '$wheel_pattern' in $project_dir. Copy it there and re-run."; return 1; }
    local wheel; wheel=$(printf '%s\n' "${wheels[@]}" | sort -V | tail -n1)
    log_info "[$app_name] Selected wheel: $(basename "$wheel")"

    # --- python detection ---
    local py=""
    for cand in /usr/local/bin/python3.12 python3.12 python3.13 python3; do
        if command -v "$cand" &>/dev/null; then
            local p v; p=$(command -v "$cand")
            v=$("$p" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
            [[ "$v" == "3.12" || "$v" == "3.13" ]] && { py="$p"; break; }
        fi
    done
    [ -n "$py" ] || { log_error "[$app_name] Python 3.12/3.13 not found."; return 1; }

    # --- venv ---
    if [ ! -f "$venv_dir/bin/python" ]; then
        log_action "[$app_name] Creating venv with $("$py" --version)..."
        "$py" -m venv "$venv_dir" || { rm -rf "$venv_dir"; log_error "[$app_name] venv creation failed."; return 1; }
    fi
    local pip_exe="$venv_dir/bin/pip" py_exe="$venv_dir/bin/python"
    "$py_exe" -m pip install --upgrade pip 2>/dev/null || log_info "[$app_name] pip upgrade skipped."

    # --- install wheel (offline first) ---
    if [ -d "$wheelhouse" ] && ls "$wheelhouse"/*.whl &>/dev/null; then
        log_action "[$app_name] Installing from wheelhouse (offline)..."
        "$pip_exe" install --no-index --find-links="$wheelhouse" "$wheel" \
            || { log_error "[$app_name] Offline install failed."; return 1; }
    else
        log_action "[$app_name] Installing wheel (online)..."
        "$pip_exe" install "$wheel" \
            || { log_error "[$app_name] Install failed. For offline boards put dependency wheels in $wheelhouse"; return 1; }
    fi

    # --- detect executable ---
    local app_exec=""
    for name in "${preferred_bins[@]}"; do
        [ -x "$venv_dir/bin/$name" ] && { app_exec="$venv_dir/bin/$name"; break; }
    done
    if [ -z "$app_exec" ]; then
        for bin in "$venv_dir"/bin/*; do
            local base; base=$(basename "$bin")
            if [[ -x "$bin" && ! -d "$bin" && ! "$base" =~ ^(python|pip|activate|easy_install|wheel|idle|pydoc) ]]; then
                app_exec="$bin"; break
            fi
        done
    fi
    [ -n "$app_exec" ] || { log_error "[$app_name] No executable found in venv/bin."; return 1; }
    log_success "[$app_name] Executable: $(basename "$app_exec")"
    LAST_INSTALL_EXEC="$(basename "$app_exec")"

    # --- runner script ---
    cat > "$runner" <<RUNNER_EOF
#!/bin/bash
WORKING_DIR="$project_dir"
VENV_DIR="$venv_dir"

if [ -f "\$VENV_DIR/bin/activate" ]; then
    source "\$VENV_DIR/bin/activate"
else
    echo "✖ Error: venv not found at \$VENV_DIR" >&2
    exit 1
fi

cd "\$WORKING_DIR" || { echo "✖ Error: \$WORKING_DIR missing" >&2; exit 1; }

for name in ${preferred_bins[@]}; do
    [ -x "\$VENV_DIR/bin/\$name" ] && exec "\$VENV_DIR/bin/\$name" "\$@"
done

for bin in "\$VENV_DIR/bin/"*; do
    base=\$(basename "\$bin")
    if [[ -x "\$bin" && ! -d "\$bin" && ! "\$base" =~ ^(python|pip|activate|easy_install|wheel|idle|pydoc) ]]; then
        exec "\$bin" "\$@"
    fi
done

echo "✖ Error: no executable found in \$VENV_DIR/bin" >&2
exit 1
RUNNER_EOF
    chmod +x "$runner"

    # --- systemd service ---
    cat > "$service_file" <<EOF
[Unit]
Description=$service_desc
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$project_dir
Environment=RUNNING_AS_SERVICE=1
Environment=PATH=$venv_dir/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$runner
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now "$service_name" || { log_error "[$app_name] Failed to start service."; return 1; }

    sleep 2
    if systemctl is-active --quiet "$service_name"; then
        log_success "[$app_name] Service '$service_name' is running."
    else
        log_error "[$app_name] Service NOT running. Check: journalctl -u $service_name -e"
        return 1
    fi
    return 0
}

# ============================================================
# STEP 5 — Point paku's config.yaml at wherever padiscontroller
#          actually ended up (no manual editing of Windows-style
#          paths.project_dist_dir / project_entry_point / files_dist_dir).
#
#   args: paku_project_dir  padis_project_dir  padis_exec_name
# ============================================================
step_configure_paku_paths() {
    local paku_dir="$1" padis_dir="$2" padis_exec="$3"
    local config_file="$paku_dir/files/configs/config.yaml"
    local py="$paku_dir/.venv/bin/python"
    local service="paku.service"

    [ -x "$py" ] || { log_error "paku venv python not found at $py"; return 1; }

    # --- 1. Wait until the paku service is actually RUNNING ---
    # (config.yaml is only created by paku itself on first boot)
    log_action "Waiting for $service to become active..."
    local waited=0
    while ! systemctl is-active --quiet "$service"; do
        if [ "$waited" -ge 30 ]; then
            log_error "$service did not become active within 30s. Check: journalctl -u $service -e"
            return 1
        fi
        sleep 1; waited=$((waited + 1))
    done
    log_success "$service is active (after ${waited}s)."

    # --- 2. Wait for paku to create files/configs/config.yaml ---
    # First boot may take a while (factory defaults are written on startup).
    log_action "Waiting for config.yaml to be created by paku..."
    waited=0
    while [ ! -f "$config_file" ]; do
        if [ "$waited" -ge 60 ]; then
            log_error "paku config.yaml never appeared at $config_file (waited 60s)."
            log_info  "Check paku logs: journalctl -u $service -e"
            return 1
        fi
        sleep 1; waited=$((waited + 1))
    done
    log_success "config.yaml appeared after ${waited}s."

    # --- 3. Wait until the file is fully written (size stable for 2s) ---
    local size1 size2
    waited=0
    while [ "$waited" -lt 10 ]; do
        size1=$(stat -c %s "$config_file" 2>/dev/null || echo 0)
        sleep 2
        size2=$(stat -c %s "$config_file" 2>/dev/null || echo 0)
        [ "$size1" = "$size2" ] && [ "$size1" != "0" ] && break
        waited=$((waited + 2))
    done
    log_success "config.yaml is stable (${size2} bytes)."

    # --- 4. Stop paku BEFORE editing ---
    # If paku rewrites its config on shutdown, editing while it runs would
    # be silently overwritten. Stop first, edit, then start again.
    log_action "Stopping $service to edit config safely..."
    systemctl stop "$service" 2>/dev/null
    sleep 1

    # --- 5. Make sure PyYAML is available in paku's venv ---
    if ! "$py" -c "import yaml" 2>/dev/null; then
        log_action "Installing PyYAML into paku venv (needed for config editing)..."
        "$py" -m pip install pyyaml 2>/dev/null \
            || { log_error "PyYAML not available and could not be installed."; systemctl restart "$service" 2>/dev/null; return 1; }
    fi

    # --- 6. Edit the config ---
    "$py" - "$config_file" "$padis_dir" "padiscontroller" "$padis_exec" "$padis_dir/files" <<'PYEOF'
import sys
import yaml

config_file, project_dist_dir, project_dist_name, project_entry_point, files_dist_dir = sys.argv[1:6]

with open(config_file, "r", encoding="utf-8") as f:
    data = yaml.safe_load(f) or {}

paths = data.setdefault("paths", {})
paths["project_dist_dir"] = project_dist_dir
paths["project_dist_name"] = project_dist_name
paths["project_entry_point"] = project_entry_point
paths["files_dist_dir"] = files_dist_dir

with open(config_file, "w", encoding="utf-8") as f:
    yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
PYEOF
    local edit_rc=$?

    # --- 7. Restart paku with the new config ---
    log_action "Restarting $service with updated config..."
    systemctl restart "$service" 2>/dev/null

    if [ $edit_rc -eq 0 ]; then
        log_success "paku config.yaml paths -> project_dist_dir=$padis_dir, project_entry_point=$padis_exec"
        sleep 2
        if systemctl is-active --quiet "$service"; then
            log_success "$service restarted successfully with new config."
        else
            log_error "$service failed to start after config edit. Check: journalctl -u $service -e"
            return 1
        fi
        return 0
    else
        log_error "Failed to update paku config.yaml at $config_file"
        return 1
    fi
}

# ============================================================
# RUN ALL STEPS
# ============================================================
run_step() {
    local title="$1"; shift
    log_step "$title"
    if "$@"; then
        log_success "STEP OK: $title"
        return 0
    else
        log_error "STEP FAILED: $title"
        FAILED+=("$title")
        return 1
    fi
}

run_step "1: Board base configuration"        step_board_config
run_step "2: Install Python 3.12.5"           step_install_python

PADIS_DIR=""; PADIS_EXEC=""; PAKU_DIR=""

if run_step "3: Install padiscontroller service" install_app_service \
    "padiscontroller" "padiscontroller-*.whl" "padis-controller.service" "Padis Controller Service" \
    "$PADIS_WHEEL_NAME" "$PADIS_WHEEL_URL" "padiscontroller-start" "padis-controller" "padiscontroller"; then
    PADIS_DIR="$LAST_INSTALL_DIR"
    PADIS_EXEC="$LAST_INSTALL_EXEC"
fi

if run_step "4: Install paku service"            install_app_service \
    "paku" "paku-*.whl" "paku.service" "Paku Service" \
    "$PAKU_WHEEL_NAME" "$PAKU_WHEEL_URL" "paku-start" "paku"; then
    PAKU_DIR="$LAST_INSTALL_DIR"
fi

if [ -n "$PADIS_DIR" ] && [ -n "$PAKU_DIR" ]; then
    run_step "5: Point paku at padiscontroller's install path" step_configure_paku_paths \
        "$PAKU_DIR" "$PADIS_DIR" "$PADIS_EXEC"
else
    log_info "Skipping step 5 (paku path auto-config) — padiscontroller or paku did not install successfully."
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "====================================================="
echo "                    SUMMARY"
echo "====================================================="
if [ ${#FAILED[@]} -eq 0 ]; then
    log_success "All steps completed successfully! 🎉"
else
    log_error "Failed steps:"
    for f in "${FAILED[@]}"; do echo "   - $f"; done
fi

echo ""
for s in padis-controller.service paku.service; do
    echo "   $s : $(systemctl is-active "$s" 2>/dev/null || echo 'not installed')"
done
echo ""
log_info "Logs:  journalctl -u padis-controller.service -f"
log_info "       journalctl -u paku.service -f"

[ ${#FAILED[@]} -eq 0 ] && exit 0 || exit 1
