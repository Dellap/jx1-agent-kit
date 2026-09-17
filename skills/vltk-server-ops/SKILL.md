---
name: vltk-server-ops
description: Use when operating the VLTK/JX1 <SERVER_NAME> server.
---

# VLTK/JX1 server operations (<SERVER_NAME>, WSL2 on PC <GAME_HOST_IP>)

Server stack of the user's JX1/VLTK "<SERVER_NAME>" test server. The game runs
inside **WSL2 (CentOS7 distro <WSL_DISTRO>, hostname <PC_NAME>-Kho)** on Windows PC
<GAME_HOST_IP>; SSH in via `ssh jx1` (root@<GAME_HOST_IP>:2222, key). Game data
under `/home/jxser` (gateway/ + server1/). Webpanel (quản lý server, screenshot
"VLTK SERVER - THỬ NGHIỆM") = python2 `server.py` on WSL :80, http://<wsl-ip>.

## Service stack & ports (start order matters)
1. mysqld → 3306
2. goddess_y (gateway/) → 5001 (account/role DB), binds 0.0.0.0 — bishop needs it up first
3. bishop_y (gateway/) → **5622 client login**, 5632 (game-svr), 5623 deny — the gateway clients talk to
4. s3relay_y (gateway/s3relay/) → 5003/5004/5005 — **gameserver dies if this is down** ("Connect to [Chat] is failed!")
5. jx_linux_y (server1/, `env LD_PRELOAD=./vdk.so ./jx_linux_y`) → 6666 (binds 127.0.0.1)

Restarting only bishop (pkill) makes jx_linux_y exit too ("connection[Bishop] lost
→ GameServer exit"). After any partial restart, verify all 5 with
`for p in mysqld goddess_y bishop_y s3relay_y jx_linux_y; do pgrep -x $p >/dev/null && echo "$p UP" || echo "$p DOWN"; done`
scripts: /opt/vltk_portable/{boot_all.sh,stop_all.sh,fix_config.sh,apply_patch.sh} (boot_all used by webpanel).

## LAN play from another machine (laptop)
Client (E:\Game\jx1\VoLamTruyenKy\Client on the PC; same layout on laptop) connects
to bishop **5622**. Because WSL2 NATs, remote clients need Windows portproxy on <GAME_HOST_IP>
(same trick as SSH 2222→22). **wsl-fix-game.bat** (C:\ProgramData\) does it — reads
WSL IP from C:\Users\<WIN_USER>\wsl_ip.txt (rewritten each WSL boot by /root/wsl-boot.sh),
deletes+re-adds portproxy + firewall for 2222, 5622, 5632. Run as admin after every
PC reboot. Client `settings\serverlist.ini` 0_Address must point at <GAME_HOST_IP>
(laptop) / 127.0.0.1 (same-machine); port comes from config.ini GameServPort=5622.

## FixIp — the classic "laptop can't enter game" trap
Each of bishop.cfg / goddess.cfg / s3relay relay_config.ini / servercf*.ini has a
[FixIp] InternetIp/IntranetIp. **Semantics differ per file:**
- bishop.cfg FixIp = the IP bishop *advertises to clients* for the enter-game hop →
  must be LAN IP **<GAME_HOST_IP>** for remote play.
- goddess/s3relay FixIp + all inter-service Ip= lines stay **127.0.0.1** (bind internal;
  <GAME_HOST_IP> does NOT exist inside WSL → bind fails → "Failed to startup HostServer").
Symptoms: laptop logs in + picks character fine but "kết nối máy chủ thất bại" ⇒
bishop FixIp still 127.0.0.1 (PC works because 127.0.0.1 is local). "Máy chủ đầy"
(server full) at enter-game ⇒ gameserver actually DOWN, not full. Check
`server1/Logs/KSG_LoginOutLog_*.log`: repeated "Del …: login timeout" 20s after Add =
client never reached jx.

## fix_config.sh pitfall (SELF-INFLICTED, verify after every sed)
fix_config.sh force-resets IPs on every boot (idempotent, offline-oriented: bishop
CheckAccount=0, everything →127.0.0.1). To make remote play stick across boots you
must patch fix_config.sh, not just the cfg. **It is multi-line with repeated
`IntranetIp *=.*/…127.0.0.1` patterns — a blanket sed replaces the WRONG line**
(once hit s3relay's line instead of bishop's, setting relay FixIp=<GAME_HOST_IP> →
s3relay "Failed to startup HostServer" → cascade: jx DOWN → "máy chủ đầy").
Use targeted per-line edits (`sed -i "Ns/…/"`) and re-`grep -n` every affected line
afterward. Intended final state: fix_config bishop line →<GAME_HOST_IP>; goddess,
s3relay lines →127.0.0.1.

## Diagnosis logs (all under /opt/vltk_portable/logs/ unless noted)
- KSG_G_System_*.log (gateway/Logs) — bishop client flow (GetRoleInfo/EnterGame/Move Node)
- heaven_2_500_*.log (gateway/Logs) — raw client connects; Allocate→CloseReason:2 = client dropped
- KSG_LoginOutLog_*.log (server1/Logs) — account enter/leave + timeouts
- gameserver.log, s3relay.log, goddess.log, bishop.log (webpanel logs dir)
- relay logs: gateway/s3relay/relay_log/<date>/; s3relay Logs/database_*.log shows DB ok
- .bat files must be CRLF (`sed -i "s/$/\r/"`); C:\ProgramData files carry Windows ACL —
  existing file may be unwritable from WSL (create new file alongside instead).
- Admin Windows ops from WSL SSH: no elevation. Trigger UAC on the PC's screen with
  `powershell Start-Process cmd -Verb RunAs -ArgumentList '/c …'` — user clicks Yes;
  SSH connection resets meanwhile, re-check after.
