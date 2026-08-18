# Megatools: Mega.nz Command-Line Client

Install `megatools` and use it to download from and upload to [mega.nz](https://mega.nz) from a Debian/Ubuntu-based shell.

## Prerequisites

- Debian or Ubuntu-based Linux (this page only covers the `apt` install path).
- A Mega.nz account, only if you plan to **upload** or browse your own cloud storage. Downloading a public share link needs no account.

## Install

```bash
sudo apt update
sudo apt install megatools
```

Manual pages ship with the package:

```bash
man megatools
man megarc
```

<!-- UNVERIFIED: needs a check on real hardware — package availability/version on other distros (Fedora, Arch, etc.) not confirmed here; check your distro's package manager or build from the upstream source at https://megatools.megous.com if `apt` isn't available. -->

## Download

### From a public share link (no account needed)

```bash
megadl 'https://mega.nz/file/<FILE_ID>#<DECRYPTION_KEY>'
```

`megadl` also accepts a folder link and will fetch the whole tree.

### From your own cloud storage (account needed)

```bash
megals /Root
megaget --path ./local-dir /Root/<REMOTE_FILE>
```

`megaget` needs credentials — see [Credentials](#credentials) below.

## Upload

Uploading always requires an authenticated account:

```bash
megaput --path /Root/ <LOCAL_FILE>
```

- `--path` sets the destination remote folder (must already exist — see `megamkdir` below).
- Omit `--path` to upload to the account's root.

## Credentials

`megaput`/`megaget`/`megals` need to authenticate. Either pass flags on every call:

```bash
megals --username <MEGA_EMAIL> --password <PASSWORD> /Root
```

or store them once in `~/.megarc` (avoids leaking the password into shell history/`ps`):

```ini
[Login]
Username = <MEGA_EMAIL>
Password = <PASSWORD>
```

> **Warning**: `~/.megarc` holds a plaintext password. Set restrictive permissions and never commit it:
> ```bash
> chmod 600 ~/.megarc
> ```

Verify login works:

```bash
megadf
```

## Other useful commands

| Command | Purpose |
| :--- | :--- |
| `megadf` | Show cloud storage quota/usage |
| `megals` | List remote files/folders |
| `megamkdir` | Create a remote directory |
| `megacopy` | Sync a local directory to/from the cloud |
| `megarm` | Remove a remote file or directory |

> **Warning**: `megarm` deletes the remote path immediately — there is no trash-bin undo from the CLI. Confirm the path with `megals` first:
> ```bash
> megarm /Root/<REMOTE_FILE_OR_DIR>
> ```

## Troubleshooting

- **`megadf`/`megaput` fails to log in** — double-check `[Login]` casing in `~/.megarc` (section/key names are case-sensitive), or that `--username`/`--password` are spelled correctly on the command line.
- **`megadl` fails on a share link** — the link must include the `#<DECRYPTION_KEY>` fragment; a bare file ID without the key cannot be decrypted.
- **Backslash in password** — escape it as `\\` inside `~/.megarc`.
