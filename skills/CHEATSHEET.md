# CHEATSHEET — facts tra nhanh (path, port, log, lệnh)

Trang 1 chỗ để **không phải SSH dò lại**. Số liệu bám server server JX1 (<GAME_HOST_IP>) và bản JXLinux 6/8.

## Máy & truy cập

| Thứ | Giá trị |
|---|---|
| Server chính | PC Windows 11 `<GAME_HOST_IP>`, game trong **WSL2 CentOS 7** (distro `<WSL_DISTRO>`, hostname `<WSL_HOSTNAME>`) |
| SSH | `ssh jx1` (= `root@<GAME_HOST_IP>:2222`, key; portproxy 2222→WSL:22 tự refresh) |
| ⚠️ Sau reboot PC | chạy `C:\ProgramData\wsl-fix-game.bat` bằng quyền admin (portproxy 2222/5622/5632 + firewall) |
| Server JX1 thứ 2 | `<GAME_HOST2_IP>` (Ubuntu 24.04, `/home/jxser/gateway+server1`, 7 systemd svc, webpanel :8080) — **khác hoàn toàn** máy chính, không dùng chung file |
| Webpanel quản lý | python2 `server.py` trên WSL port 80 (nút Start/Stop gọi `/opt/vltk_portable/boot_all.sh`) |
| Client game | `<JX1_ROOT>\Client` (trên PC) — share SMB cùng tên |
| Client patch/resolution | `resolution.ini` + `filtertext.dll` (hook), `dgVoodoo` (`ddraw.dll`) cho Win11 |

## Service & port (thứ tự start quan trọng)

| # | Service | Port | Ghi chú |
|---|---|---|---|
| 1 | `mysqld` | 3306 | phải lên trước |
| 2 | `goddess_y` | 5001 | account/role DB, bind 0.0.0.0 |
| 3 | `bishop_y` | **5622 client login**, 5632 game-svr, 5623 deny | `bishop.cfg [FixIp]` = IP LAN để client ngoài vào |
| 4 | `s3relay_y` | 5003/5004/5005 | **chết cái này là gameserver chết** ("Connect to [Chat] is failed!") |
| 5 | `jx_linux_y` | 6666 (loopback) | `env LD_PRELOAD=./vdk.so ./jx_linux_y` |

```bash
# kiểm tra nhanh 5 service
for p in mysqld goddess_y bishop_y s3relay_y jx_linux_y; do pgrep -x $p >/dev/null && echo "$p UP" || echo "$p DOWN"; done
```
⚠️ Restart **chỉ bishop** (pkill) làm `jx_linux_y` thoát theo (`connection[Bishop] lost → GameServer exit`).

## Đường dẫn dữ liệu

| Loại | Đường dẫn |
|---|---|
| Server root | `/home/jxser/server1` (`settings/`, `script/`, `Logs/`) |
| Gateway | `/home/jxser/gateway` (`Logs/`, `s3relay/relaysetting/`, `s3relay/setting/`) |
| Sự kiện định kỳ | `gateway/s3relay/relaysetting/task/tasklist.ini` + `task/*.lua` |
| Mission/task | `server1/settings/task/missions.txt`, `server1/settings/timertask.txt` |
| Thông số npc/quái | `server1/settings/npcs.txt` + `settings/npcres/*.txt` (tên file GBK) |
| Shop | `server1/settings/{goods,buysell,magicscript}.txt` (+ copy sang `gateway/s3relay/relaysetting/syncfiles/settings` và client `settings`) |
| Lua script | `server1/script/{lib,global,missions,battles}/…` |
| SimBot/SimCity | `server1/script/global/nobitaxd/vdk/simcity/` + `server1/settings/global/vdk/simcity/` |
| Log hay soi | `gateway/Logs/KSG_G_System_*.log`, `gateway/Logs/heaven_2_500_*.log`, `server1/Logs/KSG_LoginOutLog_*.log`, `/opt/vltk_portable/logs/{bishop,s3relay,goddess,gameserver}.log` |
| Cli patch portable | `/opt/vltk_portable/{boot_all.sh,stop_all.sh,fix_config.sh,apply_patch.sh}` |

## Client UI — facts (không phải dò lại)

| Thứ | Giá trị |
|---|---|
| Theme đang chạy | `Client/config.ini`: `Theme=CTC`; `Client/UserData/<acc>/uiconfig.ini`: `[Main] Scheme=CTC` |
| Thư mục theme loose | `ui/ctc` (10 ini — theme đang chạy), `ui/ui_ctc_v2` (133 ini — theme đầy đủ), `ui/ui_vlmp`, `ui/one`, `ui/ui3` |
| Cửa sổ NEO dùng chung | `ui/ctc/battle/battle_select.ini` (3 nút pet/kỹ năng sống/vòng quay + 4 vùng info + shop động) — **không đè** |
| Engine có hỗ trợ đứng bán | `UserData/uiconfig.ini` có `[StallSection] StallAdv=`; `RegisterFunctionAlias("trade","Trade",0)` |
| Sprite đứng bán | `spr/Ui3/°ÚÌ¯/` (9 file, `Ì¯Ö÷Ãæ°å.spr`=摊主面板 107KB), mua bán: `spr/Ui3/ÂòÂô/ÂòÂôÃæ°å.spr` |
| Kéo cửa sổ | `Moveable=1` trong `[Main]` của ini |
| Script client (loose) | `Client/script/{protocol.lua, tasktrace/, global/, item/, skill/, ui/, activitysys/}` |
| Mod client (DLL) | `one.dll` = **ONE.DLL V6.2a R3**, cấu hình `Client/JX1Mod.ini` (`AutoUILayout`, `ThanhMauBoss/NPC`, `LienTram`, `ThongBaoPK`, `CompareShop`/`EquipmentCompare`…) — tắt cả mod: `[OneDLL] Enabled=0` |
| API engine ở ĐÂU | `GetNpcId`, `NpcIdx2PIdx`, `GetNpcKind`, `GetNpcParam`… do **`server1/jx_linux_y`** cấp; `SetNpcStall`, `SetBotStallTier`, `PollTradeStay`, `TradeStayClear`, `SendTradeItem` do **`vdk.so`** (nạp bằng `LD_PRELOAD`) |

## Đơn vị & quy ước

- **Tick**: `jump`/timer JX dùng frame, **18 frame = 1 giây** (`FRAME2TIME = 18`, `REFRESH_RATE = 18`).
- **Toạ độ NPC**: `SubWorldID2Idx(mapId)` → index map; toạ độ lưu `x*32, y*32` (ô × 32).
- **Encoding**: file `.lua`/settings server = **iso-8859-1/TCVN3**; `.ini` client = **CRLF** + tên file GBK; nhiều chuỗi Trung.
- **Tên file/thư mục trong client = MOJIBAKE** (bytes GBK bị hiểu thành Latin-1): `°ÚÌ¯`=摆摊, `ÂòÂô`=买卖, `½»Ò×`=交易,
  `Ö÷½çÃæ`=主界面, `´¢ÎïÏä`=储物箱. Copy file tiếng Trung vào client ⇒ đặt **tên mojibake**
  (`name.encode('gbk').decode('latin-1')`); tên ASCII không bị ảnh hưởng.
- **Chữ hiển thị trong `.ini` client = TCVN3** (không phải UTF-8/GBK) — encode bằng `vietnamese-conversion`, verify roundtrip.
- **Kinh nghiệm mới của bản mod này** = comment có mốc ngày trong code (vd `-- [2026-06-28] …`) → `grep "20\d\d-\d\d-\d\d"`.

## Lệnh hay dùng

```bash
ssh jx1 'pgrep -x jx_linux_y'                        # game có chạy không
ssh jx1 'tail -50 /home/jxser/server1/Logs/KSG_LoginOutLog_*.log'   # player vào/ra, timeout
ssh jx1 'grep -c "Login failed" /home/jxser/gateway/Logs/*.log'     # lỗi login
ssh jx1 'cd /home/jxser && tar czf /tmp/x.tgz <path>' && scp jx1:/tmp/x.tgz .   # kéo code về grep local
ssh jx1 'pkill -x jx_linux_y; sleep 2; bash /opt/vltk_portable/boot_all.sh /home/jxser'  # NẠP LẠI LUA server
#  ⚠️ panel_restart.sh CHỈ restart web panel :80 — không đụng service game. Lua print -> server1/Logs/KSG_ScriptOutputLog_<ngày>.txt
```

## Nhớ nhanh luật FixIp

- `gateway/bishop.cfg [FixIp] InternetIp` = **IP LAN** (`<GAME_HOST_IP>`) — cho client ngoài vào game.
- `goddess.cfg`, `s3relay relay_config.ini`, `server1/servercf*.ini` = **`127.0.0.1`** (IP LAN không tồn tại trong WSL → bind fail → "Failed to startup HostServer" → cascade chết game).
- `fix_config.sh` **reset IP mỗi lần boot** ⇒ muốn giữ thì phải patch cả `fix_config.sh`, không chỉ file .cfg.
- `servercf0.ini` là bản song sinh của `servercfg.ini` — sửa cả hai.

## Bug ĐANG ĐỂ NGÕ (chưa rõ nguyên nhân — đừng thử lại các hướng đã loại trừ)

- **Click vào bot đứng bán ⇒ không hiện đồ bày bán (không cửa sổ, không lỗi).** Quầy **người thật mở được** ⇒ lỗi ở nhánh bot.
  ĐÃ LOẠI TRỪ: thiếu cửa sổ theme `ui/ctc` (đã copy đủ 6 ini + sprite, cả tên mojibake) · bản `vdk.so` (đổi `_goc`) ·
  khối `_ts > 0 … _ts = 0` trong `sim.core.lua` · pack `NPC PLAYER HIỆN BANG` (guard NpcId) · hook client `EquipmentCompare`/ONE.DLL.
  Chi tiết bảng 7 phép thử + 3 hướng còn lại: `skills/jx1-simbot/SKILL.md` → mục **TRẠNG THÁI LỖI QUẦY BOT**.
