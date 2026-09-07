# Fortis [BETA]
*tested on Ubuntu 26.04.1 LTS*

Interactive Bash tool for basic Linux server hardening: SSH configuration, administrative users, firewall and Fail2Ban management — with safety nets like config backups, `sshd -t` validation and explicit apply.

## Warning

Fortis modifies live system configuration. Mistakes in SSH or firewall settings can lock you out of your server.

- Keep your current SSH session open until a second one works
- Make sure you have console/recovery access before changing SSH or firewall settings
- Backups are stored in `backups/`

## Features

**SSH**
- Root SSH login toggle (`yes` / `no` / `prohibit-password`)
- Password authentication toggle
- SSH port change with busy-port detection
- Sudo user creation
- SSH public key installation with correct ownership and permissions
- Menu shows which users already have keys installed

**Firewall**
- Enable/disable: **UFW**, **iptables** (+iptables-persistent), **firewalld**, **nftables**
- SSH port is allowed *before* the firewall is enabled (lockout protection)
- Frontend-based firewall status detection

**Fail2Ban**
- Enable/disable, install on demand
- Standard sshd jail with `maxretry` / `bantime` from `config.conf`

**Safety**
- `sshd -t` validation and automatic restore from backup before `systemctl reload ssh`
- Live status detection via `sshd -T`

## Requirements

- Ubuntu / Debian (apt-based)
- Root privileges

## Usage

```bash
git clone https://github.com/heldoreik/Fortis.git
cd Fortis
sudo bash fortis.sh
```

The script can be run from any directory — module paths are resolved relative to the script itself.

## Project structure

```
fortis.sh      — entry point (interactive menu)
config.conf    — defaults (HTTP/HTTPS rules, fail2ban values, warnings)
lib/           — sourced modules: status detection and helpers
backups/       — sshd_config / nftables.conf backups (gitignored)
```

## Configuration

`config.conf` holds defaults such as `ALLOW_HTTP` / `ALLOW_HTTPS` (used by firewall branches), `FAIL2BAN_MAX_RETRIES` / `FAIL2BAN_BAN_TIME` (used by the Fail2Ban jail), warning toggles and options reserved for the upcoming non-interactive mode.

## Roadmap

- Automatic updates, kernel hardening (menu items 8–9)
- Security audit and SSH connection confirmation with auto-rollback (items 10–12)
- Firewall "change" mode, non-interactive apply driven by `config.conf`

## Versions

- `v0.2` — SSH hardening
- `v0.3` — firewall management
- `v0.4` — Fail2Ban management, live SSH key status