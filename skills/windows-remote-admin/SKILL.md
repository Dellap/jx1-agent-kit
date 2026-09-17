---
name: windows-remote-admin
description: "SSH admin Windows via sshpass: setup, cmd, read-only fix."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos]
metadata:
  hermes:
    tags: [windows, ssh, sshpass, remote-admin, attrib, icacls]
    related_skills: [file-transfer]
---

# Windows Remote Admin (SSH from macOS)

Manage a Windows machine over SSH using OpenSSH + `sshpass`. Trigger: user says "SSH vào <IP>", "bỏ read-only", "sửa file trên máy Windows", remote cmd/PowerShell.

## 1. Check port before connecting
`nc -z` can hang/timeout oddly against Windows hosts. Use python socket with short timeout:
```python
import socket; s = socket.socket(); s.settimeout(3)
s.connect(('IP', 22)); print('OPEN')
```
Common ports: 22 SSH, 445 SMB, 3389 RDP, 5985 WinRM. Only 445 open = SSH not enabled yet.

## 2. Enable OpenSSH server on Windows (one-time, user runs in PowerShell Admin)
```powershell
Get-Service sshd
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
# Rule often missing or wrong profile — create for all profiles:
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```
Check existing rule: `Get-NetFirewallRule -Name *ssh* | Format-Table Name, Enabled, Profile`. Service running + port still timeout from outside = firewall rule missing/disabled.

## 3. Connect
```bash
sshpass -p 'PASSWORD' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 -o UserKnownHostsFile=/dev/null USER@IP "command"
```
- Quote the password in single quotes — Windows passwords often contain `@` (e.g. `P@ssw0rd!`) and shell eats it unquoted.
- Locally-created users (e.g. `<SMB_USER>` added via `net user`) work for SSH even when the main account is MS/Microsoft-account.
- SMB password often == SSH password for the same user. If `Permission denied`, `session_search` for the `net user` command used when the account was created — the exact password may be there.
- PowerShell over SSH works: `"powershell -Command \"Get-Service sshd\""` if cmd one-liners fall short.

## 4. Remove read-only recursively (attrib)
```cmd
attrib -r -s -h "E:\path\to\dir" /s /d
```
Verify no files still carry R: `attrib "path" /s | findstr /I /C:" R "` (empty output = clean).

## 6. SMB mount from macOS — auth rejected (Win11 build 26200+)

Symptom: SSH works fine with the same user/pass, but `mount_smbfs` / `smbutil view` return `server rejected the connection: Authentication error` (rc=77). Ports 22+445 both open.

Root-cause checklist (in order):
1. **`LocalAccountTokenFilterPolicy` missing** — the #1 cause. Windows denies SMB network auth for local admin accounts (e.g. `<SMB_USER>`) unless this reg key exists. SSH is unaffected (different auth path), which is why SSH works while SMB fails. Fix (via SSH):
   ```cmd
   reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
   shutdown /r /t 0 /f
   ```
   Takes effect only after reboot. Re-verify after reboot: `reg query ... /v LocalAccountTokenFilterPolicy` → 0x1.
2. **Machine was reinstalled** — new Win11 builds (26200+) wipe previously-set policies AND recreate user accounts (<WIN_USER>/<PC_NAME> → <PC_NAME> etc.). Check `net user` output; if usernames changed since last session, re-apply LATFP and re-sync creds: `net user <SMB_USER> PASSWORD /active:yes`.
3. **Isolate server-side vs client-side**: test SMB from the Windows box itself:
   ```cmd
   net use Z: \\localhost\VoLamTruyenKy /user:<SMB_USER> PASSWORD
   ```
   RC=0 = share+user+pass are fine server-side; the failure is the macOS client.
4. **`mount_smbfs` on macOS is too old for Win11 26200** — even with LATFP set + reboot + local `net use` working, mount_smbfs can still reject. Workaround: **Samba `smbclient`** (negotiates SMB2/3 properly):
   ```bash
   brew install samba
   smbclient -L IP -U "USER%PASS" -m SMB3            # list shares
   smbclient "//IP/SHARE" -U "USER%PASS" -m SMB3 -c "ls"
   smbclient "//IP/SHARE" -U "USER%PASS" -m SMB3 -c "cd dir; get file /tmp/local"
   ```
   Warning `Can't load /opt/homebrew/etc/smb.conf` is harmless. Note: smbclient is command-per-call (no persistent mount) — fine for reading configs/copying files.
5. **Need a REAL persistent mount (Finder /Volumes)?** mount_smbfs is dead on Win11 26200; go sshfs over SSH (SSH always works):
   ```bash
   brew install --cask macfuse        # kernel ext — REQUIRES manual user approval + reboot
   brew install gromgit/fuse/sshfs-mac
   sshfs user@IP:"E:/share/path" /tmp/mnt -p 22 -o password_stdin,StrictHostKeyChecking=no,UserKnownHostsFile=/dev/null,volname=JX1,reconnect <<< 'PASSWORD'
   ```
   ⚠️ **macOS blocks the macfuse kext from CLI** — `kextload` fails (KMErrorDomain 71 dependency error), `sysctl vfs.generic.fuse` empty. The USER must open System Settings → General → Privacy & Security → Security → **Allow** "macfuse" → **reboot** before sshfs mounts. Plan this as an explicit user hand-off; nothing on the CLI side makes it load.

## 8. WSL2 distro access from macOS (via the Windows SSH host)

Reach a WSL2 distro (game server, dev VM) from outside its NAT. Full recipe + CentOS7 specifics: `references/wsl2-jump-access.md`. Cheat sheet:
- WSL2 IP (172.26.x) is NAT-internal + changes each WSL restart; never give it to LAN clients. Bridge = `netsh interface portproxy` on the Windows host (admin) → everyone uses the **host LAN IP**.
- WSL distros are **per-Windows-user**: as another user `wsl -l` is empty. Find the owner: `reg query HKU\<SID>\Software\Microsoft\Windows\CurrentVersion\Lxss /s`.
- **Elevation is PER SSH path, never assume**: `net session >nul && echo ELEVATED`. Direct Windows OpenSSH as `<SMB_USER>` was ELEVATED (netsh/schtasks/firewall worked). But `ssh <SSH_ALIAS>` (root@<GAME_HOST_IP>:2222, WSL-side sshd) runs as Windows user <WIN_USER> at **medium IL** — `whoami /groups` shows Administrators "Group used for deny only" → netsh add, `schtasks /rl highest`, `attrib -r` all return Access denied.
- **Not-elevated + user is at the machine? Use the interactive UAC prompt** — pops on their screen, they click Yes, command runs elevated:
  ```cmd
  powershell -NoProfile -Command "Start-Process cmd -Verb RunAs -ArgumentList \"/c C:\\ProgramData\\wsl-fix-game.bat\" -Wait; Write-Output DONE"
  ```
  Expected: SSH session drops (broken pipe) while UAC is up — reconnect after ~8s and verify with `netsh interface portproxy show all`. User-side approve is the ONE manual step in an otherwise remote flow.
- **Verify a schtasks auto-heal actually exists before relying on it**: `Get-ScheduledTask | Where-Object {$_.TaskName -match "wsl|fix"}`. The documented 5-min `wsl-fix` task was ABSENT (only Windows Autochk "Proxy" matched) — portproxy had been applied by hand. Check `schtasks /query /fo CSV /v` before assuming reboot-survival.
- Over-SSH cmd: `;` is not a separator (use `&`); redirected `wsl.exe` output is UTF-16LE — write results to a file from inside Linux instead.
- Auto-heal IP drift: wsl.conf `[boot]`+`[automount]` (bundled distros often have automount off → no /mnt/c) → boot script writes IP to a Windows file → schtasks (elevated, 5 min) re-applies portproxy.
- **New .bat in C:\ProgramData = create fresh, don't overwrite**: an existing admin-created .bat is ACL/read-only even from WSL root (rm/chmod/scp-overwrite/attrib -r all denied). Writing a NEW filename via heredoc works (`cat > ... << "EOF"`), then fix line endings — Windows bat needs CRLF, heredoc gives LF: `sed -i "s/$/\r/" file.bat` and confirm with `file` → "DOS batch file, with CRLF line terminators".

## Pitfalls
- **Windows cmd has no `grep`/`head`** — pipe to `findstr` instead (e.g. `| findstr /I "needle"`).
- **Folder "Read-only" checkbox auto-reverts = NORMAL on Win10/11.** Folder-level read-only attribute does NOT block writes; don't chase it. Real write blockers are NTFS ACLs or antivirus.
- Writes still failing after attrib → grant ACLs (admin):
  ```cmd
  takeown /f "path" /r /d y
  icacls "path" /grant "%USERNAME%:(OI)(CI)F" /T
  ```
- Antivirus (e.g. game settings not saving) is a common cause of denied writes even with clean attributes — check AV exclusions.
