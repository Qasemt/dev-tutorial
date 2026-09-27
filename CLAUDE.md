# CLAUDE.md

Operating manual for any Claude session working in `Qasemt/dev-tutorial`. Read this before touching a file. This is instructions for an agent, not navigation for a human — for navigation, see [README.md](./README.md).

## Project

A personal field-notes collection on embedded Linux, SBCs, toolchains, networking, and Windows, accumulated since 2015 by a single author (Qasem Taheri). MIT-licensed intent, docs-only: no build, no test suite, no CI.

**Non-goal:** this is not a product manual. Don't homogenize terse, opinionated "the step people miss" notes into corporate prose — restructure and clarify, never sanitize away the field-note voice.

## Repository map

```text
README.md                  landing page (human nav — don't duplicate it here)
docs/
  embedded-linux/          general config, devices, host-bootstrap, ssh_server
  boards/raspberry-pi/     Pi-specific pages, images, one PDF
  toolchain/               compile_cxx, Python, golang, NodeJS, git-lab, teamcity, CI
  networking/              wireguard/, squid/, v2ray/, proxy & tunnel pages
  projects/update-boards/  SQL/bulk-insert board-provisioning scripts
  windows/, misc/, reference/
```

Each area has a `readme.md` index built from `| Page | Notes |` tables. Non-markdown assets (`.sh`, `.py`, `.bat`, `.zip`, NMEA/CSV samples, images, one PDF) live beside the pages that use them.

## Ground rules

- **Never invent a command, flag, path, or package name.** Mark anything you can't verify with `<!-- UNVERIFIED: needs a check on real hardware -->` (see Verification & honesty). A wrong `dd`/`iptables`/`parted` line here costs someone a board.
- **Never delete a quirk note, a hedge, or a "the step people miss" passage** just because it looks untidy — that's the value of this repo, not noise.
- **Never translate an identifier, command, path, or flag** inside a Persian-language page or comment.
- **Ask before a mass rename or mass rewrite** (more than one file at once). Small, single-file, reviewable changes are fine to make directly.
- **No new top-level directories under `docs/`** without asking first.
- **A fact has one home.** If two pages teach the same thing, link, don't re-paste (current duplicates are listed under Known debt).

## Markdown conventions

House style is extracted from the repo's own polished pages (root `README.md`, `docs/embedded-linux/readme.md`, `docs/toolchain/readme.md`, `docs/networking/readme.md`).

- **Area index header:** `<h1 align="center">Title</h1>` + centered `<p align="center">` blurb + a centered nav row of `<a href="#slug">` anchors joined by `·`, then `---`. This pattern is for area indexes only — a normal content page just uses a plain `# Title` H1.
- **Index table:** exactly `| Page | Notes |` / `| :--- | :--- |`.
- **Cheatsheets:** `<details><summary><b>Label</b></summary>...</details>` — optional; not every polished page uses one.
- **Links:** relative, `./`-prefixed from the file's own directory, exact case. Percent-encode spaces in link targets (`%20`) rather than renaming the target — see Naming for the one offending filename.
- **Fences:** every code block is language-tagged (`bash`, `conf`, `text`, `sh`, `console`, `python`, `ini`, `systemd`). Never put prose narration or command output in the same fence as the command itself — separate them.
- **Placeholders:** `ANGLE_BRACKET_CAPS` or an obviously fake value (`example.local`, `192.0.2.10`) — never a real-looking IP, host, or password (see Secrets & privacy).
- **Destructive steps:** a `> **Warning**` callout *before* the command, plus how to undo it.
- **Images:** write real `alt` text — the literal string `![alt text](...)` is a defect, present today in `docs/boards/raspberry-pi/pinout.md`.
- **Footers are optional and rare.** Only root `README.md` has an Author/License footer; area indexes don't need one — don't add ad hoc ones (one exists today in `docs/embedded-linux/host-bootstrap/readme.md` and shouldn't be copied elsewhere).

## Language policy

One language per page, declared by its content — never code-switched mid-paragraph or mid-code-fence. Persian pages (e.g. `docs/toolchain/Python/venv-guide.md`) stay Persian; don't translate them to English. Inside a Persian page, code, paths, flags, and filenames stay LTR inside backticks, never translated.

Ten known pages currently mix Finglish/Persian into English prose (see Known debt). Clean each one to a single language *in place* when you next substantially edit it — move or translate the stray passage within the same file. Don't split it into a `.fa.md` sibling, and don't delete the non-English content to "fix" it.

## Page anatomy

- **How-to:** `# Title` → one-sentence goal → numbered imperative steps, one action each → optional Troubleshooting section.
- **Reference:** `# Title` → one-sentence scope → tables or fenced dumps, minimal narrative, no "how to" framing.
- **Index:** centered header block → `| Page | Notes |` table → optional `<details>` cheatsheets.

## Adding or editing a page

1. Pick the Diátaxis type above and stick to it — don't let a how-to grow a reference dump halfway through.
2. State prerequisites: board/OS/version, privileges needed, blast radius.
3. Tag every fence; keep commands and output in separate blocks; warn before destructive steps.
4. Use `kebab-case.md` for new files (see Naming).
5. **Register the page in its area's `readme.md` index** — the step everyone forgets.
6. Check whether root `README.md` needs a new line too (only for a new area or a major page, not every leaf page).
7. Confirm every relative link you added resolves, with exact case.

## Naming & file placement

Target convention: `kebab-case.md` for content pages, `readme.md` (lowercase) for indexes. Two confirmed anomalies, not yet fixed:
- `docs/embedded-linux/ssh_server/Readme.md` — capital `R`, the only one in the repo.
- `docs/toolchain/compile_cxx/cygwin_building on_windows_using_cygwin.md` — a literal space; its one inbound link already percent-encodes it, but other tooling may not.

**Do not batch-rename the ~67 non-conforming legacy files in one pass** (66 non-kebab-case content pages plus `Readme.md`) — that is a mass rename (see Ground rules) and needs explicit approval first. Rename a legacy file opportunistically when you're already substantially editing it, updating its inbound links in the same commit. Confirmed precedent: `docs/embedded-linux/ssh_server/HOW_TO_CLONE_PRIVATE_REPO_ON_LINUX.md` → `how-to-clone-private-repo-on-linux.md`, author-approved — going forward, rename any new SCREAMING_SNAKE_CASE or otherwise non-kebab-case file to `kebab-case.md` the next time it's touched, updating inbound links in the same commit.

## Scripts and binary assets

Document what a script does; don't rewrite its logic unless asked to. Before describing a script as working, check that it actually runs: `docs/embedded-linux/general_config/devices/rock_chip/install_python_buildroot.sh` and `set_network.sh` are **not functional** — their content is a leftover `cat > file << 'EOF'` chat transcript rather than an executable script (`set_network.sh` fails `bash -n`). Don't present either as a working install path until someone rewrites it.

Call out every destructive or system-modifying line (`sed -i` on `/etc/...`, `PermitRootLogin yes`, table `DROP`s in `docs/projects/update-boards/Script/bulkinsert/*.sh`) when documenting a script. Keep a script's paired `readme.md` in sync with its *actual* flags — `rock_chip/readme.md` currently documents only two of its four sibling scripts. `docs/misc/claime.bat` is legacy/unverified (opens browser tabs to crypto-faucet sites) — label it as such, don't present it as a supported tool.

## Secrets & privacy

Placeholders: `<PROXY_HOST>` / `192.0.2.0/24` (RFC 5737 test range) / `example.local` for hosts and domains, `<PASSWORD>` / `<TOKEN>` for credentials. Never commit a real one.

Known offenders — backlog, flag when you touch the file, don't mass-edit without asking:
- Proxy IP `172.20.10.1` + domain `.emdad.local`, repeated across `docs/embedded-linux/readme.md`, `setup-proxy.sh`, `hunane_config_script.md`, `docs/toolchain/Python/readme.md`.
- LDAP domain `dc=n2it,dc=local` / `ou=karaj-users` in `docs/toolchain/git-lab/readme.md`.
- Real board IPs reused across files: `192.168.1.56`, `192.168.40.151`, `192.168.41.125`.
- Plaintext example passwords `1234` / `4321wifi!@#$` in `SSH-Login-No-Password.md`, `Shadowsocks.md`, `wifi_hotspot.md`.

**Urgent, not backlog:** `rock_chip/install_python.sh` and `setup.sh` embed three *live* Dropbox share-link tokens (`rlkey=...&st=...`). That's an active credential, not a stale personal IP — flag it to the author immediately, don't wait for a cleanup pass.

## Verification & honesty

Mark anything you can't test against real hardware/OS with `<!-- UNVERIFIED: needs a check on real hardware -->` right after the line. State the target board/OS/version whenever a command depends on it — most existing pages don't, and several (`resolution_pi.md`, `Hide_Boot_Messages.md`, `cflagsForBoards.md`) are only valid for long-obsolete Raspbian/Pi 1. Prefer writing "not verified" over a confident-sounding guess.

## Commit conventions

Observed history is imperative, topic-scoped subject lines (`Add tailscale_dev_setup.md`, `Restructure repo into docs/ tree`, `Update readme.md`) — no `type(scope):` prefix is actually used; don't invent one. One logical change per commit; avoid GitHub-web "Add files via upload"-style dumps going forward.

## Tooling

Nothing exists today: no build, no test runner, no linter, no CI, no `.gitignore`, no `LICENSE` file (despite the MIT claim in `README.md`).

**Proposed, not yet present** — don't reference these as if they run:
- `.markdownlint.json` for fence/heading-style linting.
- A link-checker script (case-sensitive, relative-path aware) — this audit did the equivalent by hand.
- `.editorconfig` for line-ending/indent consistency.
- `docs/reference/STYLEGUIDE.md` — if a convention ever needs more than the one-line example given here, it belongs there, with this file linking to it. It doesn't exist yet; don't add the link until the file does.

## Open questions / known debt

- `docs/reference/markdown.md` is **not a markdown style guide** — it's a verbatim copy of a third-party project's (Dillinger) README. Root `README.md`'s description of it ("Markdown syntax reference") is misleading. Needs a human decision: replace its content, or repoint/remove the README's link.
- Two zip archives in `docs/embedded-linux/` are never referenced from any page — confirmed orphans, not yet triaged. (`serial_ping.py` has left this list: it is now linked from `docs/toolchain/Python/serial-ping-echo.md` and the toolchain index.)
- `docs/networking/v2ray/` is a single 19-line file in its own folder; `docs/networking/squid/squid_baic.md` and `test_squid.md` duplicate a curl block verbatim. Both are consolidation candidates, not yet acted on.
- Ten files code-switch Persian/Finglish into English prose (see Language policy) and still need per-file cleanup.
- No repo-wide orphan-page sweep (index-by-index) has been done — only the two zips and one script are confirmed so far.
- `bootstrap-debian12.sh` / `bootstrap-debian13.sh` and `setup-proxy.sh` / `clear-proxy.sh` each hand-maintain a duplicated file list across two scripts; already drifting from each other.
