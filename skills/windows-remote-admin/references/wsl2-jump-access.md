# WSL2 distro access from macOS via a Windows SSH host

Recipe proven 07/09/2026: máy Mac điều khiển → Windows <GAME_HOST_IP> (OpenSSH user `<SMB_USER>`, ELEVATED over SSH) → WSL2 CentOS7 distro `<WSL_DISTRO>` (owned by Windows user `<WIN_USER>`), game server at `/home/jxser/server1`.

## Why direct access fails
- WSL2 IP (172.26.x.x) is NAT-internal to the Windows host — unreachable from LAN/other machines, and it **changes on every WSL restart** (`wsl --shutdown` or Windows reboot).
- WSL distros are **per-Windows-user**: `wsl.exe -l -q` run as another user returns empty / "no installed distributions". You cannot launch someone else's distro from your SSH session.

## Discover which Windows user owns a distro
```cmd
reg query HKU
reg query "HKU\<SID>\Software\Microsoft\Windows\CurrentVersion\Lxss" /s   :: per SID
```
→ `DistributionName` + `BasePath` (e.g. `C:\Users\<WIN_USER>\AppData\Local\Programs\JxLTStudio\ServerRuntime\server\wsl`).

## Check remote elevation (decides what you can do)
```cmd
net session >nul && echo ELEVATED || echo NOT-ELEVATED
```
**Elevation differs per SSH path** (verified 08/09/2026):
- Direct Windows OpenSSH as `<SMB_USER>` (sshpass) = **ELEVATED** → netsh/schtasks/firewall all work over SSH.
- `ssh <SSH_ALIAS>` (root@<GAME_HOST_IP>:2222 → WSL-side sshd, runs as Windows user `<WIN_USER>`) = **NOT-ELEVATED** (medium IL; Administrators group shows "deny only"). `netsh add`, `schtasks /create /rl highest`, `attrib -r`, overwriting admin-owned files in `C:\ProgramData` — all `Access denied`.

### Non-elevated: interactive UAC prompt (user is at the machine)
From the WSL SSH session, fire a one-shot elevated bat through UAC — it pops on the user's screen, they click Yes:
```cmd
powershell -NoProfile -Command "Start-Process cmd -Verb RunAs -ArgumentList \"/c C:\\ProgramData\\wsl-fix-game.bat\" -Wait; Write-Output DONE"
```
Expected: SSH session drops (broken pipe) while the prompt is up; reconnect after ~8s, then verify with `netsh interface portproxy show all`. This was the working path for opening game port 5622 on <GAME_HOST_IP>.

## Bridge WSL2 to the LAN (one-time, admin cmd on Windows host)
```cmd
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=2222 connectaddress=<wsl-ip> connectport=22
netsh advfirewall firewall add rule name="wsl-ssh" dir=in action=allow protocol=TCP localport=2222
```
Clients/SSH then use the **host LAN IP** (e.g. `<GAME_HOST_IP>:2222`), never the WSL IP.
Pitfall: `netsh` is a Windows command — running it inside WSL bash gives `netsh: command not found`.
Game ports: JX1/VLTK client connects to **bishop** on **5622** (`ClientOpenPort` in `gateway/bishop.cfg`, `GameServPort` in client `config.ini`); other listeners (5001 goddess, 5003-5005 relay, 6666 game, 80 webpanel) stay internal. Bridge the same way, firewall rule name `wsl-game`.

### Verifying an applied proxy from macOS
```bash
nc -zv -w 5 <GAME_HOST_IP> 5622    # expect: succeeded
```

## Over-SSH cmd.exe quirks (Windows OpenSSH default shell = cmd)
- `;` is NOT a separator — the whole string becomes one `echo` argument. Chain with `&` / `&&`.
- `wsl.exe` stdout when redirected is **UTF-16LE** (`type` shows `\u0000` between chars). Fix: have the command write results to a file **from inside Linux** (plain ASCII), then `type` that file.
- `wsl.exe` DOES run from a non-interactive SSH session (kernel 6.x / recent WSL) — earlier assumptions that it can't are wrong.

## Auto-heal the changing WSL IP (set up once, zero user steps after)
1. Inside WSL: `/etc/wsl.conf`:
   ```
   [automount]
   enabled = true          # bundled distros often disable automount → /mnt/c missing

   [boot]
   command = /bin/bash /root/wsl-boot.sh
   ```
   (wsl.conf changes need ONE `wsl --shutdown` + reopen to take effect.)
2. `/root/wsl-boot.sh` (chmod +x):
   ```bash
   pgrep sshd >/dev/null || /usr/sbin/sshd
   hostname -I | awk '{print $1}' > /mnt/c/Users/<winuser>/wsl_ip.txt
   ```
3. Windows scheduled task (create via remote SSH as the admin user; runs elevated, no user action):
   ```cmd
   schtasks /create /tn wsl-fix /tr C:\ProgramData\wsl-fix.bat /sc minute /mo 5 /ru <adminuser> /rp <pass> /rl highest /f
   ```
   `wsl-fix.bat`: if `wsl_ip.txt` exists → read IP → `netsh interface portproxy delete v4tov4 ... 2>nul` + re-`add` + firewall delete/add.
4. macOS `~/.ssh/config` alias → `ssh <alias>` forever:
   ```
   Host <SSH_ALIAS>
       HostName <GAME_HOST_IP>
       Port 2222
       User root
       IdentityFile ~/.ssh/id_ed25519
   ```
5. Install pubkey once: `cat ~/.ssh/id_ed25519.pub | sshpass -p ... ssh -p 2222 root@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`.

Caveat: if the WSL VM is fully stopped nothing is reachable — the chain only matters while the user's WSL/game server is running.

## CentOS 7 inside WSL2 specifics
- No systemd: `systemctl` → `Failed to get D-Bus connection: Operation not permitted`. Run `/usr/sbin/sshd` directly (warning `UsePAM no is not supported...` is harmless).
- EOL repos: `sed -i 's|^mirrorlist=|#mirrorlist=|; s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-Base.repo` before `yum install`.
- For SSH-as-root: `passwd` + `PermitRootLogin yes` in sshd_config, restart sshd.
- `wsl.exe` over SSH as a non-owner user can't start the distro; owner must launch it (their app/terminal).

## Writing .bat files over remote cmd — don't echo
`echo` with `%VAR%` gets mangled both as `%%VAR%%` and `^%VAR^%`. Write the .bat locally, then:
```bash
sshpass -p PASS scp /tmp/x.bat 'user@host:C:/ProgramData/x.bat'
```
