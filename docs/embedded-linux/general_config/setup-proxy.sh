#!/usr/bin/env bash
#
# setup-proxy.sh - Debian: persist proxy settings at boot level (env layer)
#
# ======================================================================
#  AFTER RUNNING - THE STEP PEOPLE ALWAYS MISS
# ======================================================================
#
#  Writing the files is not enough. A process's environment is copied at
#  exec() time and can NEVER be changed from outside afterwards - not by
#  this script, not by anything. So every process that was already running
#  keeps the OLD proxy value, and so does every child it spawns later.
#
#  This is why re-running the script "changes nothing": the files are
#  correct, but you are inspecting a stale process tree.
#
#  Symptom: the value you see does not match /etc/environment.
#    echo "$https_proxy"              -> old value  (stale shell)
#    bash -lc 'echo $https_proxy'     -> new value  (fresh login shell)
#
#  The second command is the honest test: it is what your next login gets.
#
#  FIND THE STALE ANCESTOR:
#
#    ./setup-proxy.sh --walk            # walks claude's ancestor chain
#    ./setup-proxy.sh --walk <pid>      # or any pid you choose
#
#  Output looks like this - the culprit is the TOPMOST row with the old
#  value, and PPID=1 means it survives independently of your SSH session:
#
#    PID    PPID  CMD                              HTTPS_PROXY
#    11945  8704  ~/.vscode-server/extensions/...   http://old:8080
#    8704   2647  ~/.vscode-server/cli/...          http://old:8080
#    2643   1     sh ~/.vscode-server/cli/...       http://old:8080   <- root cause
#    1      -     systemd                           http://new:8080
#
#  FIX, in increasing order of thoroughness:
#
#    exec bash -l                     # refresh THIS shell, keeps SSH alive
#    pkill -f '.vscode-server'        # kill the resident server tree
#    sudo reboot                      # refreshes all layers at once
#
#  Killing a leaf process is not enough. VS Code respawns it from the same
#  stale parent, so it inherits the old value again. Kill the ancestor, or
#  use "Remote-SSH: Kill VS Code Server on Host" from the command palette.
#  For a local VS Code, close the window entirely - Reload Window does NOT
#  refresh the environment.
#
# ======================================================================
#  HOW TO VERIFY IT WORKS
# ======================================================================
#
#  Just run:      ./setup-proxy.sh --verify
#
#  It checks the config files, a fresh login shell, both systemd layers,
#  every running process that matters, and one real request, then prints
#  ALL GOOD or an ordered list of what to fix. No sudo needed.
#
#  A successful end-to-end result looks exactly like this:
#
#      code=401 via=127.0.0.1
#
#    code=401  we reached Anthropic; 401 only means no API key was sent.
#              This is the GOOD answer. 000 = nothing answered,
#              403 = blocked by policy or you went direct,
#              407 = proxy wants credentials (use cntlm).
#    via=...   the IP curl really connected to. It MUST be your proxy.
#              A public IP here means the request bypassed the proxy.
#
#  Manual equivalent, if you prefer:
#      curl -s -o /dev/null -w 'code=%{http_code} via=%{remote_ip}\n' \
#           https://api.anthropic.com/v1/models
#
# ======================================================================
#  WHY IT "DOES NOT WORK" RIGHT AFTER INSTALLING  (read this first)
# ======================================================================
#
#  The environment of a process is copied at exec() time and can never be
#  changed from outside afterwards. So editing files changes NOTHING for
#  anything already running. Two consequences bite every single time:
#
#  a) In your current shell, echo "$https_proxy" keeps showing the OLD
#     value forever, no matter how often you re-run this script.
#     That is not a failure. To see what the NEXT login will get:
#         bash -lc 'echo $https_proxy'
#     To update the shell you are sitting in, without dropping SSH:
#         exec bash -l
#
#  b) A stale ANCESTOR poisons every child it spawns. Killing the child
#     does not help, because the parent hands it the old value again.
#     The usual culprit on a remote box is the VS Code server: it runs
#     with ppid=1, so it outlives closing the editor window, and every
#     extension it starts inherits the stale environment.
#         pkill -f '.vscode-server'
#         pgrep -af '.vscode-server'     # must come back empty
#     Then reconnect the window. In VS Code you can instead run
#     "Remote-SSH: Kill VS Code Server on Host".
#
#  The sequence that reliably works after installing:
#      1. sudo ./setup-proxy.sh http://IP:PORT
#      2. pkill -f '.vscode-server'
#      3. exit   and ssh back in         (or: exec bash -l)
#      4. reconnect VS Code, start your tool
#      5. ./setup-proxy.sh --verify      -> expect ALL GOOD
#
#  sudo reboot does steps 2-3 for you and is the fastest way out if you
#  are chasing resident processes. This script changes nothing in the
#  network layer and nothing in sshd, so SSH comes back fine.
#
#  NOTE ON A 127.0.0.1 PROXY: if you point this at a local client
#  (v2ray/Xray/sing-box on 127.0.0.1:10808, or cntlm on 127.0.0.1:3128),
#  make that client a systemd service with WantedBy=multi-user.target.
#  Otherwise every boot-time service that runs before the client is up
#  will fail - nightly apt timers, docker pulls, and so on.
#
# ======================================================================
#  HOW TO SUPPLY THE PROXY ADDRESS   (read in this order of precedence)
# ======================================================================
#
#  1) Positional argument - safest, sudo cannot strip it:
#
#        sudo ./setup-proxy.sh http://192.168.40.10:8080
#
#  2) PROXY_URL on the command line:
#
#        sudo PROXY_URL="http://192.168.40.10:8080" ./setup-proxy.sh
#
#     NOTE: depends on your sudoers. sudo with env_reset strips variables
#     and only passes them when your rule matches ALL (Debian's default,
#     but not guaranteed). If unsure, verify with:
#
#        sudo PROXY_URL=http://x:8080 ./setup-proxy.sh --show
#            -> if it prints PROXY = http://x:8080, it came through.
#
#  3) From an existing https_proxy in your shell:
#
#        export https_proxy="http://192.168.40.10:8080"
#        sudo -E ./setup-proxy.sh            # -E is required
#
#     Or pass the value explicitly instead of using -E:
#
#        sudo ./setup-proxy.sh "$https_proxy"
#
#  4) Edit DEFAULT_PROXY in the CONFIG section below, then just:
#        sudo ./setup-proxy.sh
#
#  PREFLIGHT: before writing anything, the script resolves the proxy host,
#  opens a TCP connection to it, and tries api.anthropic.com through it.
#  If the host does not resolve or the port is closed it ABORTS and writes
#  nothing - this prevents the ENOTFOUND-style failures that appear much
#  later in unrelated tools. Override with FORCE=1 if you know better.
#
#  INTERNAL DOMAIN: the bypass list and dconf use INTERNAL_DOMAIN
#  (default .emdad.local). Change it in CONFIG or pass it inline:
#        sudo INTERNAL_DOMAIN=.corp.local ./setup-proxy.sh http://ip:port
#
# ======================================================================
#  OTHER COMMANDS
# ======================================================================
#
#  Show resolved values, change nothing:
#        ./setup-proxy.sh --show
#
#  Trace why a running process still has the old value:
#        ./setup-proxy.sh --walk            # defaults to the claude process
#        ./setup-proxy.sh --walk <pid>
#
#  Dry run against a fake root (touches no real file):
#        ROOT=/tmp/proxytest ./setup-proxy.sh http://192.168.40.10:8080
#        grep -r . /tmp/proxytest/etc
#
#  Remove what this script created:
#        sudo ./setup-proxy.sh --uninstall
#        (for a deeper cleanup incl. per-user files, use clear-proxy.sh)
#
#  Override the bypass list:
#        sudo NO_PROXY_LIST="localhost,127.0.0.1,192.168.40.0/23,.corp.local" \
#             ./setup-proxy.sh http://192.168.40.10:8080
#
#  If the proxy requires NTLM/Kerberos: run cntlm on 127.0.0.1:3128, then
#        sudo ./setup-proxy.sh http://127.0.0.1:3128
#
#  CAVEAT for a loopback proxy (127.0.0.1:PORT, e.g. a local v2ray/Xray or
#  cntlm client): it only exists for that user and only while the client is
#  running. System services that start at boot before the client is up will
#  fail - apt timers, docker pulls, anything in cron. If you set a loopback
#  address here, make the client a systemd unit with
#  WantedBy=multi-user.target so it is always up first. A LAN proxy address
#  avoids this problem entirely.
#
#  After running: sudo reboot   (or at minimum logout/login)
#
set -euo pipefail

# ----------------------------- CONFIG -----------------------------
# Change this if you want to run without an argument:
DEFAULT_PROXY="http://proxy.company.local:8080"

# Your internal DNS domain, used in the bypass list and in dconf.
INTERNAL_DOMAIN="${INTERNAL_DOMAIN:-.emdad.local}"

# Precedence: arg 1  <-  PROXY_URL  <-  https_proxy  <-  HTTPS_PROXY  <-  default
_ENV_PROXY_URL="${PROXY_URL:-}"
ARG_PROXY=""
ARGS=()
for a in "$@"; do
  case "$a" in
    http://*|https://*|socks5://*|socks5h://*) ARG_PROXY="$a" ;;
    *) ARGS+=("$a") ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

PROXY_URL="${ARG_PROXY:-${PROXY_URL:-${https_proxy:-${HTTPS_PROXY:-$DEFAULT_PROXY}}}}"

# Destinations that must NOT go through the proxy.
# 192.168.40.0/23  =  192.168.40.0 - 192.168.41.255  (both company ranges)
_hosts="$(printf '%s\n%s\n' "$(hostname)" "$(hostname -f 2>/dev/null || true)" \
          | awk 'NF && !seen[$0]++' | paste -sd,)"
NO_PROXY_LIST="${NO_PROXY_LIST:-localhost,127.0.0.1,::1,192.168.40.0/23,192.168.40.0/24,192.168.41.0/24,${INTERNAL_DOMAIN},${_hosts}}"

# ROOT is for dry runs only; empty on a real run.
ROOT="${ROOT:-}"
TAG="# >>> managed by setup-proxy.sh >>>"
END="# <<< managed by setup-proxy.sh <<<"
# ------------------------------------------------------------------

if [[ "${1:-}" == "--walk" ]]; then
  set +e   # a process without a proxy value must not abort the walk
  # Walk a process's ancestor chain and show each one's proxy value.
  # The topmost row still holding an old value is the process to restart.
  p="${2:-$(pgrep -x claude 2>/dev/null | head -1)}"
  [[ -z "$p" ]] && p="$(pgrep -f 'bin/claude' 2>/dev/null | head -1)"
  if [[ -z "$p" || ! -d "/proc/$p" ]]; then
    echo "no matching process. Pass a pid explicitly: $0 --walk <pid>"
    echo "candidates:"
    pgrep -af 'vscode-server|extensionHost|claude' 2>/dev/null | cut -c1-90 | head
    echo
    echo "A fresh login shell would get: $(bash -lc 'echo $https_proxy' 2>/dev/null)"
    exit 1
  fi
  printf '%-8s %-7s %-36s %s\n' PID PPID CMD HTTPS_PROXY
  while [[ -n "$p" && "$p" -gt 1 ]]; do
    pp="$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')"
    cmd="$(tr '\0\n' '  ' < "/proc/$p/cmdline" 2>/dev/null | cut -c1-36)"
    [[ -z "${cmd// }" ]] && cmd="[$(cat "/proc/$p/comm" 2>/dev/null)]"
    val="$(tr '\0' '\n' < "/proc/$p/environ" 2>/dev/null \
           | grep -m1 -i '^https_proxy=' | cut -d= -f2-)"
    printf '%-8s %-7s %-36s %s\n' "$p" "${pp:--}" "$cmd" "${val:--}"
    p="$pp"
  done
  printf '%-8s %-7s %-36s %s\n' 1 '-' 'systemd' \
    "$(systemctl show-environment 2>/dev/null | awk -F= '/^HTTPS_PROXY=/{print $2;exit}')"
  echo
  echo "A fresh login shell would get: $(bash -lc 'echo $https_proxy' 2>/dev/null)"
  echo "Rows above that differ from it are stale and need a restart."
  exit 0
fi

if [[ "${1:-}" == "--show" ]]; then
  if   [[ -n "$ARG_PROXY" ]];                       then src='positional argument'
  elif [[ -n "$_ENV_PROXY_URL" ]];                  then src='PROXY_URL variable'
  elif [[ -n "${https_proxy:-${HTTPS_PROXY:-}}" ]]; then src='https_proxy from environment'
  else                                                   src='DEFAULT_PROXY in script'
  fi
  printf 'PROXY    = %s\n' "$PROXY_URL"
  printf 'NO_PROXY = %s\n' "$NO_PROXY_LIST"
  printf 'source   = %s\n' "$src"
  exit 0
fi

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[ABORT]\033[0m %s\n' "$*" >&2; exit 1; }

# ---- --verify : did the installed settings actually take effect? ----
if [[ "${1:-}" == "--verify" ]]; then
  ok_n=0; bad_n=0
  vok() { printf '  \033[1;32m[OK]\033[0m   %s\n' "$*"; ok_n=$((ok_n+1)); }
  vno() { printf '  \033[1;31m[FAIL]\033[0m %s\n' "$*"; bad_n=$((bad_n+1)); }
  vnb() { printf '  \033[0;90m[--]\033[0m   %s\n' "$*"; }

  # Source of truth is what was written to /etc/environment.
  WANT="$(awk -F= '/^HTTPS_PROXY=/{print $2;exit}' /etc/environment 2>/dev/null)"
  [[ -z "$WANT" ]] && die "no HTTPS_PROXY in /etc/environment - run the installer first."
  printf '\nexpected proxy: %s\n' "$WANT"

  printf '\n1. config files\n'
  grep -qF "$WANT" /etc/environment 2>/dev/null \
    && vok "/etc/environment" || vno "/etc/environment"
  grep -qF "$WANT" /etc/profile.d/proxy.sh 2>/dev/null \
    && vok "/etc/profile.d/proxy.sh" || vno "/etc/profile.d/proxy.sh"
  grep -qrF "$WANT" /etc/systemd/user.conf.d/ 2>/dev/null \
    && vok "/etc/systemd/user.conf.d" || vno "/etc/systemd/user.conf.d"

  printf '\n2. what a NEW login shell gets  (this is the one that matters)\n'
  FRESH="$(bash -lc 'printf %s "$https_proxy"' 2>/dev/null)"
  [[ "$FRESH" == "$WANT" ]] && vok "fresh login shell: $FRESH" \
    || vno "fresh login shell: ${FRESH:-<empty>}"

  printf '\n3. this shell  (stale is NORMAL - env is copied at exec time)\n'
  if [[ "${https_proxy:-}" == "$WANT" ]]; then
    vok "current shell: ${https_proxy}"
  else
    vnb "current shell: ${https_proxy:-<empty>}  -> run: exec bash -l"
  fi

  printf '\n4. systemd layers\n'
  systemctl show-environment 2>/dev/null | grep -qF "$WANT" \
    && vok "system manager" || vno "system manager -> sudo systemctl daemon-reexec"
  if systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user show-environment 2>/dev/null | grep -qF "$WANT" \
      && vok "user manager (desktop apps inherit from here)" \
      || vno "user manager -> log out and back in"
  else
    vnb "no user manager in this session"
  fi

  printf '\n5. running processes  (a stale ancestor poisons every child)\n'
  hit=0
  for pat in '\.vscode-server' extensionHost '/claude' gopls pylance rust-analyzer; do
    pids="$(pgrep -f "$pat" 2>/dev/null | head -3 || true)"
    for pid in $pids; do
      [[ "$pid" == "$$" || "$pid" == "$PPID" ]] && continue
      [[ -r "/proc/$pid/environ" ]] || continue
      cmd="$(tr '\0\n' '  ' < "/proc/$pid/cmdline" 2>/dev/null | cut -c1-40 || true)"
      case "$cmd" in *setup-proxy*|*walk.sh*|*pgrep*) continue ;; esac
      val="$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null \
             | grep -m1 -i '^https_proxy=' | cut -d= -f2- || true)"
      ppid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
      hit=1
      if [[ "$val" == "$WANT" ]]; then
        vok "[$pid] $cmd"
      else
        vno "[$pid ppid=${ppid:-?}] $cmd
         holds: ${val:-<none>}"
      fi
    done
  done
  if (( hit == 0 )); then
    vnb "none running - open VS Code from the icon, then re-check"
  fi

  printf '\n6. end-to-end through the proxy\n'
  if command -v curl >/dev/null 2>&1; then
    R="$(curl -s --max-time 15 -o /dev/null \
         -w 'code=%{http_code} via=%{remote_ip}' \
         https://api.anthropic.com/v1/models 2>/dev/null)"
    WH="${WANT#*://}"; WH="${WH%%:*}"
    if [[ "$R" == *"code=401"* || "$R" == *"code=200"* ]] && [[ "$R" == *"via=$WH"* ]]; then
      vok "$R"
    else
      vno "$R   (want code=401 via=$WH)"
    fi
  fi

  printf '\n'
  if (( bad_n == 0 )); then
    printf '\033[1;32mALL GOOD\033[0m (%d checks passed)\n' "$ok_n"; exit 0
  fi
  cat <<'HINT'
FAILURES FOUND. In order of likelihood:

  1. A resident process still holds the old value. Closing the VS Code
     window is NOT enough - the remote server survives it (ppid=1):
         pkill -f '.vscode-server'
         pgrep -af '.vscode-server'       # must come back empty
     then reconnect the window.

  2. This shell is stale. It cannot be updated from outside:
         exec bash -l

  3. The user-level systemd manager is stale. Needs a real re-login:
         exit        # and ssh back in

  4. Fastest way to clear all of the above at once:
         sudo reboot
HINT
  exit 1
fi

# ---- PREFLIGHT: never write config for a proxy that does not work ----
# A bad address here produces ENOTFOUND deep inside other tools later,
# which is very hard to trace back to this script. So verify it now.
if [[ "${1:-}" != "--uninstall" && "${FORCE:-0}" != "1" ]]; then
  _h="${PROXY_URL#*://}"; _p="${_h##*:}"; _h="${_h%%:*}"
  [[ "$_p" == "$_h" ]] && _p=8080

  if [[ "$PROXY_URL" == "$DEFAULT_PROXY" ]]; then
    warn "you did not supply a proxy address; falling back to the built-in default:"
    warn "  $DEFAULT_PROXY"
  fi

  # 1. does the proxy host resolve / is it a literal IP?
  if [[ ! "$_h" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    if ! getent hosts "$_h" >/dev/null 2>&1; then
      die "proxy host '$_h' does not resolve.
       This is exactly what causes ENOTFOUND later on.
       Re-run with the real address, e.g.:
         sudo $0 http://192.168.40.10:8080
       To skip this check anyway: FORCE=1 sudo -E $0 ..."
    fi
  fi

  # 2. is the port actually open?
  if command -v nc >/dev/null 2>&1; then
    nc -z -w3 "$_h" "$_p" 2>/dev/null \
      || die "cannot reach $_h:$_p (port closed or filtered).
       Nothing was written. Check the address and try again.
       To skip this check anyway: FORCE=1 sudo -E $0 ..."
  elif command -v timeout >/dev/null 2>&1; then
    timeout 3 bash -c "echo > /dev/tcp/$_h/$_p" 2>/dev/null \
      || die "cannot reach $_h:$_p (port closed or filtered). Nothing was written."
  fi
  log "preflight OK: $_h:$_p is reachable"

  # 3. optional end-to-end check against Anthropic
  if command -v curl >/dev/null 2>&1; then
    _c="$(curl -s --max-time 12 -o /dev/null -w '%{http_code}' \
          -x "$PROXY_URL" https://api.anthropic.com/v1/models 2>/dev/null)"
    case "$_c" in
      401|200) log "preflight OK: reached api.anthropic.com through the proxy ($_c)" ;;
      407)     warn "proxy demands authentication (407) - consider cntlm on 127.0.0.1:3128" ;;
      403)     warn "proxy answered 403 for api.anthropic.com - it may be blocked by policy" ;;
      000)     warn "no answer from api.anthropic.com through the proxy" ;;
      *)       warn "unexpected code from api.anthropic.com: $_c" ;;
    esac
  fi
fi

write() {   # write <path> ; content on stdin
  local p="${ROOT}$1"
  mkdir -p "$(dirname "$p")"
  cat > "$p"
  log "wrote: $p"
}

strip_block() {
  local p="${ROOT}$1"
  [[ -f "$p" ]] || return 0
  sed -i "\|^${TAG}$|,\|^${END}$|d" "$p"
}

# Remove any previous run so re-running never duplicates entries.
cleanup() {
  rm -f "${ROOT}/etc/systemd/system.conf.d/10-proxy.conf" \
        "${ROOT}/etc/systemd/user.conf.d/10-proxy.conf" \
        "${ROOT}/etc/profile.d/proxy.sh" \
        "${ROOT}/etc/apt/apt.conf.d/95proxy" \
        "${ROOT}/etc/dconf/db/local.d/00-proxy" \
        "${ROOT}/etc/dconf/db/local.d/locks/proxy" \
        "${ROOT}/etc/sudoers.d/95-proxy" \
        "${ROOT}/etc/fish/conf.d/proxy.fish" \
        "${ROOT}/etc/cron.d/00-proxy-env"
  strip_block /etc/environment
  strip_block /etc/wgetrc
  strip_block /etc/dconf/profile/user
  strip_block /etc/csh.login
}

if [[ "${1:-}" == "--uninstall" ]]; then
  cleanup
  if [[ -z "$ROOT" ]]; then
    command -v dconf >/dev/null && dconf update || true
    git config --system --unset-all http.proxy  2>/dev/null || true
    git config --system --unset-all https.proxy 2>/dev/null || true
    systemctl daemon-reexec || true
  fi
  log "removed. Log out and back in, or reboot."
  exit 0
fi

cleanup

# -- 1) system services (PID 1) ------------------------------------
write /etc/systemd/system.conf.d/10-proxy.conf <<EOF
[Manager]
DefaultEnvironment="HTTP_PROXY=${PROXY_URL}" "HTTPS_PROXY=${PROXY_URL}" "http_proxy=${PROXY_URL}" "https_proxy=${PROXY_URL}" "ALL_PROXY=${PROXY_URL}" "all_proxy=${PROXY_URL}" "NO_PROXY=${NO_PROXY_LIST}" "no_proxy=${NO_PROXY_LIST}"
EOF

# -- 2) user session manager: VS Code and all its children inherit here --
write /etc/systemd/user.conf.d/10-proxy.conf <<EOF
[Manager]
DefaultEnvironment="HTTP_PROXY=${PROXY_URL}" "HTTPS_PROXY=${PROXY_URL}" "http_proxy=${PROXY_URL}" "https_proxy=${PROXY_URL}" "ALL_PROXY=${PROXY_URL}" "all_proxy=${PROXY_URL}" "NO_PROXY=${NO_PROXY_LIST}" "no_proxy=${NO_PROXY_LIST}"
EOF

# -- 3) login sessions via pam_env - no export, no shell expansion --
mkdir -p "${ROOT}/etc"; touch "${ROOT}/etc/environment"
cat >> "${ROOT}/etc/environment" <<EOF
${TAG}
HTTP_PROXY=${PROXY_URL}
HTTPS_PROXY=${PROXY_URL}
http_proxy=${PROXY_URL}
https_proxy=${PROXY_URL}
ALL_PROXY=${PROXY_URL}
all_proxy=${PROXY_URL}
NO_PROXY=${NO_PROXY_LIST}
no_proxy=${NO_PROXY_LIST}
${END}
EOF
log "updated: ${ROOT}/etc/environment"

# -- 4) interactive login shells -----------------------------------
write /etc/profile.d/proxy.sh <<EOF
# shellcheck shell=sh
export HTTP_PROXY="${PROXY_URL}"  HTTPS_PROXY="${PROXY_URL}"  ALL_PROXY="${PROXY_URL}"
export http_proxy="${PROXY_URL}"  https_proxy="${PROXY_URL}"  all_proxy="${PROXY_URL}"
export NO_PROXY="${NO_PROXY_LIST}"
export no_proxy="${NO_PROXY_LIST}"
EOF

# -- 5) apt (does not read env) ------------------------------------
write /etc/apt/apt.conf.d/95proxy <<EOF
Acquire::http::Proxy  "${PROXY_URL}";
Acquire::https::Proxy "${PROXY_URL}";
EOF

# -- 6) GNOME/GTK reads dconf, not env -----------------------------
PHOST="${PROXY_URL#*://}"; PPORT="${PHOST##*:}"; PHOST="${PHOST%%:*}"
[[ "$PPORT" == "$PHOST" ]] && PPORT=8080
write /etc/dconf/db/local.d/00-proxy <<EOF
[system/proxy]
mode='manual'
ignore-hosts=['localhost','127.0.0.0/8','::1','192.168.40.0/23','*${INTERNAL_DOMAIN}']

[system/proxy/http]
host='${PHOST}'
port=${PPORT}

[system/proxy/https]
host='${PHOST}'
port=${PPORT}
EOF
write /etc/dconf/db/local.d/locks/proxy <<'EOF'
/system/proxy/mode
/system/proxy/http/host
/system/proxy/http/port
/system/proxy/https/host
/system/proxy/https/port
EOF

# Without this profile file, local.d is never read at all.
DPROF="${ROOT}/etc/dconf/profile/user"
mkdir -p "$(dirname "$DPROF")"; touch "$DPROF"
if ! grep -qx 'system-db:local' "$DPROF" 2>/dev/null; then
  grep -qx 'user-db:user' "$DPROF" 2>/dev/null || printf 'user-db:user\n' >> "$DPROF"
  printf '%s\nsystem-db:local\n%s\n' "$TAG" "$END" >> "$DPROF"
  log "registered: $DPROF"
else
  log "already registered: $DPROF"
fi

# -- 7) sudo: env_reset would strip the variables -------------------
SUDOF="${ROOT}/etc/sudoers.d/95-proxy"
mkdir -p "$(dirname "$SUDOF")"
TMPS="$(mktemp)"
cat > "$TMPS" <<'EOF'
Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY NO_PROXY"
Defaults env_keep += "http_proxy https_proxy ftp_proxy all_proxy no_proxy"
EOF
if command -v visudo >/dev/null && ! visudo -cqf "$TMPS"; then
  warn "generated sudoers snippet was invalid - skipped, nothing changed"
  rm -f "$TMPS"
else
  install -m 0440 -o root -g root "$TMPS" "$SUDOF" 2>/dev/null \
    || install -m 0440 "$TMPS" "$SUDOF"
  rm -f "$TMPS"
  log "wrote: $SUDOF"
fi

# -- 8) cron reads neither /etc/environment nor /etc/profile --------
write /etc/cron.d/00-proxy-env <<EOF
# Variable definitions only; runs no job.
# These apply to jobs in this directory and /etc/crontab.
# Per-user crontabs (crontab -e) must carry these lines themselves.
HTTP_PROXY=${PROXY_URL}
HTTPS_PROXY=${PROXY_URL}
http_proxy=${PROXY_URL}
https_proxy=${PROXY_URL}
NO_PROXY=${NO_PROXY_LIST}
no_proxy=${NO_PROXY_LIST}
EOF

# -- 9) non-POSIX shells -------------------------------------------
if [[ -d "${ROOT}/etc/fish" ]] || command -v fish >/dev/null 2>&1; then
  write /etc/fish/conf.d/proxy.fish <<EOF
set -gx HTTP_PROXY  "${PROXY_URL}"
set -gx HTTPS_PROXY "${PROXY_URL}"
set -gx ALL_PROXY   "${PROXY_URL}"
set -gx http_proxy  "${PROXY_URL}"
set -gx https_proxy "${PROXY_URL}"
set -gx all_proxy   "${PROXY_URL}"
set -gx NO_PROXY    "${NO_PROXY_LIST}"
set -gx no_proxy    "${NO_PROXY_LIST}"
EOF
fi

if [[ -f "${ROOT}/etc/csh.login" ]] || command -v tcsh >/dev/null 2>&1; then
  touch "${ROOT}/etc/csh.login"
  cat >> "${ROOT}/etc/csh.login" <<EOF
${TAG}
setenv HTTP_PROXY  "${PROXY_URL}"
setenv HTTPS_PROXY "${PROXY_URL}"
setenv http_proxy  "${PROXY_URL}"
setenv https_proxy "${PROXY_URL}"
setenv NO_PROXY    "${NO_PROXY_LIST}"
setenv no_proxy    "${NO_PROXY_LIST}"
${END}
EOF
  log "updated: ${ROOT}/etc/csh.login"
fi

# -- 10) wget ------------------------------------------------------
touch "${ROOT}/etc/wgetrc"
cat >> "${ROOT}/etc/wgetrc" <<EOF
${TAG}
use_proxy = on
http_proxy = ${PROXY_URL}
https_proxy = ${PROXY_URL}
no_proxy = ${NO_PROXY_LIST}
${END}
EOF
log "updated: ${ROOT}/etc/wgetrc"

# -- 11) apply -----------------------------------------------------
if [[ -z "$ROOT" ]]; then
  git config --system http.proxy  "${PROXY_URL}" || warn "could not set git proxy"
  git config --system https.proxy "${PROXY_URL}" || true
  command -v dconf >/dev/null && dconf update || warn "dconf not installed, skipped"
  systemctl daemon-reexec
  log "systemd re-executed (system level applied)"
  warn "for the user layer and VS Code you must log out and back in, or reboot."
else
  log "dry run: no service touched. Output under ${ROOT}"
fi

log "done. PROXY=${PROXY_URL}"
log "NO_PROXY=${NO_PROXY_LIST}"
