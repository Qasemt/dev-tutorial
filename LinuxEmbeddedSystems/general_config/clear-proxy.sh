#!/usr/bin/env bash
#
# clear-proxy.sh - remove all proxy settings from a Debian system
#
#   sudo ./clear-proxy.sh                 clear system level, report per-user files
#   sudo ./clear-proxy.sh --all           also clean per-user config files
#   sudo ./clear-proxy.sh --dry-run       show only, change nothing
#   ROOT=/tmp/pt ./clear-proxy.sh --all   test against a fake root
#
# Every edited file is backed up to <file>.bak-<timestamp> first.
#
set -uo pipefail

ROOT="${ROOT:-}"
TAG="# >>> managed by setup-proxy.sh >>>"
END="# <<< managed by setup-proxy.sh <<<"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY=0; ALL=0

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --all)     ALL=1 ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
skip() { printf '\033[0;90m  -\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
act()  { (( DRY )) && printf '\033[1;36m[dry]\033[0m %s\n' "$*" || return 1; }

backup() {
  local p="$1"
  [[ -f "$p" ]] || return 0
  cp -a "$p" "${p}.bak-${STAMP}" && skip "backup: ${p}.bak-${STAMP}"
}

del() {
  local p="${ROOT}$1"
  [[ -e "$p" ]] || { skip "absent: $1"; return 0; }
  act "delete $1" && return 0
  rm -f "$p" && log "deleted: $1"
}

unblock() {
  local p="${ROOT}$1"
  [[ -f "$p" ]] || { skip "absent: $1"; return 0; }
  grep -q "^${TAG}$" "$p" 2>/dev/null || { skip "no managed block: $1"; return 0; }
  act "strip managed block from $1" && return 0
  backup "$p"
  sed -i "\|^${TAG}$|,\|^${END}$|d" "$p"
  log "block stripped: $1"
}

striplines() {   # remove proxy lines from a personal config file
  local p="$1"
  [[ -f "$p" ]] || return 0
  grep -qiE 'proxy|CA_CERTS|cafile|REQUESTS_CA_BUNDLE' "$p" 2>/dev/null || return 0
  act "strip proxy lines from $p" && return 0
  backup "$p"
  sed -i -E '/^[[:space:]]*[#;]?[[:space:]]*(export[[:space:]]+)?(https?_|all_|ftp_|no_)?proxy([[:space:]]*[=:]|[[:space:]])/Id;
             /^[[:space:]]*(https?[-_]?proxy|proxy|noproxy|no[-_]proxy)[[:space:]]*=/Id;
             /NODE_EXTRA_CA_CERTS/d; /REQUESTS_CA_BUNDLE/d;
             /^[[:space:]]*cafile[[:space:]]*=/Id' "$p"
  log "cleaned: $p"
}

echo
(( DRY )) && warn "dry-run mode: nothing will be changed."
[[ -z "$ROOT" && $EUID -ne 0 && $DRY -eq 0 ]] && { echo "run with sudo." >&2; exit 1; }

# --------------- 1) system level ---------------
log "system level"
del /etc/systemd/system.conf.d/10-proxy.conf
del /etc/systemd/user.conf.d/10-proxy.conf
del /etc/profile.d/proxy.sh
del /etc/apt/apt.conf.d/95proxy
del /etc/sudoers.d/95-proxy
del /etc/cron.d/00-proxy-env
del /etc/fish/conf.d/proxy.fish
del /etc/dconf/db/local.d/00-proxy
del /etc/dconf/db/local.d/locks/proxy
unblock /etc/environment
unblock /etc/wgetrc
unblock /etc/csh.login
unblock /etc/dconf/profile/user

# Files this script never created but you may have added by hand.
for f in /etc/apt/apt.conf.d/95proxies /etc/apt/apt.conf.d/80proxy \
         /etc/profile.d/http_proxy.sh /etc/environment.d/proxy.conf; do
  del "$f"
done

echo
log "system-level tool configuration"
if [[ -z "$ROOT" ]] && ! (( DRY )); then
  for k in http.proxy https.proxy http.sslCAInfo; do
    git config --system --unset-all "$k" 2>/dev/null && log "git --system: removed $k"
  done
  if [[ -f /etc/gitconfig ]] && ! grep -q '[^[:space:]]' /etc/gitconfig 2>/dev/null; then
    rm -f /etc/gitconfig && log "/etc/gitconfig was empty, removed"
  fi
  striplines /etc/npmrc
  striplines /etc/pip.conf
  striplines /etc/curlrc
else
  act "git --system --unset http.proxy / https.proxy"
  for f in /etc/npmrc /etc/pip.conf /etc/curlrc; do striplines "$f"; done
fi

# --------------- 2) per-user files ---------------
echo
if [[ -n "$ROOT" ]]; then
  mapfile -t HOMES < <(
    { for d in "${ROOT}"/home/*/ "${ROOT}"/root/; do
        [[ -d "$d" ]] && printf '%s\n' "${d%/}" ; done; } \
    | sed "s|^${ROOT}||" | sort -u
  )
else
  mapfile -t HOMES < <(
    { getent passwd 2>/dev/null | awk -F: '$3>=1000 && $3<65534 {print $6}'
      echo /root; } | sort -u
  )
fi
(( ${#HOMES[@]} )) || HOMES=(/root)

USERFILES=(.bashrc .bash_profile .profile .zshrc .zshenv .zprofile
           .curlrc .wgetrc .npmrc .gitconfig .cargo/config.toml
           .config/pip/pip.conf .config/fish/config.fish
           .docker/config.json .m2/settings.xml)

FOUND=0
for h in "${HOMES[@]}"; do
  [[ -d "${ROOT}${h}" ]] || continue
  for rel in "${USERFILES[@]}"; do
    p="${ROOT}${h}/${rel}"
    [[ -f "$p" ]] || continue
    if grep -qiE 'proxy|NODE_EXTRA_CA_CERTS' "$p" 2>/dev/null; then
      FOUND=1
      if (( ALL )); then
        if [[ "$rel" == ".docker/config.json" || "$rel" == ".m2/settings.xml" ]]; then
          warn "review by hand (JSON/XML structure): $p"
        else
          striplines "$p"
        fi
      else
        warn "contains proxy: $p"
      fi
    fi
  done
  for d in "${ROOT}${h}/.config/environment.d"; do
    [[ -d "$d" ]] || continue
    while IFS= read -r f; do
      FOUND=1
      if (( ALL )); then del "${f#$ROOT}"; else warn "contains proxy: $f"; fi
    done < <(grep -rliE 'proxy' "$d" 2>/dev/null)
  done
done

if (( FOUND )) && ! (( ALL )); then
  echo; warn "re-run with --all to clean these files (backups are taken)."
elif ! (( FOUND )); then
  skip "no personal config files with proxy settings found."
fi

# Per-user crontabs: report only, never edit automatically.
if [[ -z "$ROOT" ]]; then
  for h in "${HOMES[@]}"; do
    u="$(awk -F: -v hh="$h" '$6==hh{print $1;exit}' /etc/passwd)"
    [[ -n "${u:-}" ]] || continue
    crontab -l -u "$u" 2>/dev/null | grep -qi proxy \
      && warn "crontab of '$u' sets proxy vars - edit manually: crontab -e -u $u"
  done
fi

# --------------- 3) apply ---------------
echo
if [[ -n "$ROOT" ]]; then
  log "dry run: no service touched."
elif (( DRY )); then
  act "dconf update / systemctl daemon-reexec"
else
  command -v dconf >/dev/null && { dconf update; log "dconf updated"; }
  systemctl daemon-reexec && log "systemd re-executed"
  # Each user's own dconf db may still hold mode='manual'.
  for h in "${HOMES[@]}"; do
    u="$(awk -F: -v hh="$h" '$6==hh{print $1;exit}' /etc/passwd)" || continue
    [[ -n "${u:-}" ]] || continue
    uid="$(id -u "$u" 2>/dev/null)" || continue
    [[ -S "/run/user/$uid/bus" ]] || continue
    sudo -u "$u" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
      dconf reset -f /system/proxy/ 2>/dev/null \
      && log "reset dconf for user '$u'"
  done
fi

# --------------- 4) verify ---------------
echo
log "remaining system-level references:"
grep -rilE 'https?_proxy|all_proxy' \
  "${ROOT}/etc/environment" "${ROOT}/etc/profile.d" "${ROOT}/etc/systemd" \
  "${ROOT}/etc/apt/apt.conf.d" "${ROOT}/etc/dconf" "${ROOT}/etc/wgetrc" \
  "${ROOT}/etc/sudoers.d" "${ROOT}/etc/cron.d" 2>/dev/null \
  | grep -v '\.bak-' || skip "clean"

echo
if (( DRY )); then
  warn "nothing changed. Drop --dry-run to apply."
else
  warn "log out and back in, or reboot, for full effect. Close VS Code completely."
  skip "backups: find /etc /home /root -name '*.bak-${STAMP}'"
fi
