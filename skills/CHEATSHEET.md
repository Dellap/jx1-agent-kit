# CHEATSHEET — facts tra nhanh (path, port, log, lệnh)

Trang 1 chỗ để **không phải SSH dò lại**. Số liệu bám server server JX1 (<GAME_HOST_IP>) và bản JXLinux 6/8.

## Máy & truy cập

| Thứ | Giá trị |
|---|---|
| Server chính | PC Windows 11 `<GAME_HOST_IP>`, game trong **WSL2 CentOS 7** (distro `<WSL_DISTRO>`, hostname `<WSL_HOSTNAME>`) |
| SSH | `ssh <SSH_ALIAS2>` (= `root@<GAME_HOST_IP>:2222`, key; portproxy 2222→WSL:22 tự refresh) |
| ⚠️ Sau reboot PC | chạy `C:\ProgramData\wsl-fix-game.bat` bằng quyền admin (portproxy 2222/5622/5632 + firewall) |
| Server JX1 thứ 2 | `<GAME_HOST2_IP>` (Ubuntu 24.04, `/home/jxser/gateway+server1`, 7 systemd svc, webpanel :8080) — **khác hoàn toàn** máy chính, không dùng chung file |
| Webpanel quản lý | python2 `server.py` trên WSL port 80 (nút Start/Stop gọi `<PORTABLE_DIR>/boot_all.sh`) |
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
| Log hay soi | `gateway/Logs/KSG_G_System_*.log`, `gateway/Logs/heaven_2_500_*.log`, `server1/Logs/KSG_LoginOutLog_*.log`, `<PORTABLE_DIR>/logs/{bishop,s3relay,goddess,gameserver}.log` |
| Cli patch portable | `<PORTABLE_DIR>/{boot_all.sh,stop_all.sh,fix_config.sh,apply_patch.sh}` |

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
ssh <SSH_ALIAS2> 'pgrep -x jx_linux_y'                        # game có chạy không
ssh <SSH_ALIAS2> 'tail -50 /home/jxser/server1/Logs/KSG_LoginOutLog_*.log'   # player vào/ra, timeout
ssh <SSH_ALIAS2> 'grep -c "Login failed" /home/jxser/gateway/Logs/*.log'     # lỗi login
ssh <SSH_ALIAS2> 'cd /home/jxser && tar czf /tmp/x.tgz <path>' && scp jx1:/tmp/x.tgz .   # kéo code về grep local
ssh <SSH_ALIAS2> 'pkill -x jx_linux_y; sleep 2; bash <PORTABLE_DIR>/boot_all.sh /home/jxser'  # NẠP LẠI LUA server
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
  khối `_ts > 0 … _ts = 0` trong `sim.core.lua` · pack `NPC PLAYER HIỆN BANG` (guard NpcId — **đã hoàn nguyên**, xem dưới) ·
  hook client `EquipmentCompare`/ONE.DLL.
  **Phép thử #9 (đo thật 17/09):** cắm log `PollTradeStay` trong `SimCore:OnTimer` (`sim.core.lua`), chủ server online bấm bot nhiều lần ⇒ **0 dòng** ⇒ cú bấm không tạo trạng thái trade-stay ⇒ lỗi ở **cặp module `vdk.so`↔`vdk.dll`**, sửa Lua server là vô ích.
  Chi tiết bảng 9 phép thử + hướng còn lại: `skills/jx1-simbot/references/packs-and-stall-shop.md` → mục **TRẠNG THÁI LỖI QUẦY BOT**.
- **Giá quầy bot** điều khiển bằng `BOT_STALL_PRICE_MULTIPLIER` (`simcity/config.lua`, thang 1..100) → `head.lua` gọi
  `SetBotStallTier(0, 1000 + MULT, 1)`; module sinh đồ/giá là `vdk.so`. Pack `CHANGE PRICE SIMCITY SHOP - Do Bao` = bộ 3 file
  (`vdk.so` md5 **trùng bản đang chạy** + `head.lua` khớp + `config.lua` đặt MULT=15). Nếu biến này **thiếu** ⇒ không đăng ký tier.
- ⛔ **Pack third-party có thể dựa trên baseline CŨ:** pack `NPC PLAYER HIỆN BANG` ghi đè 8 file server mới hơn (mất 24 dòng config riêng)
  ⇒ phải **so md5 3 chiều TỪNG FILE** trước khi ghi đè và hoàn nguyên nếu lệch (`/root/apply_price_shop_pack.sh revert`).
  Xem `skills/vltk-client-modding/references/mod-install-and-debug.md` §5.
- 🔬 **Nội dung quầy bot do `vdk.so` dựng, không có file dữ liệu:** `settings/global/vdk/simcity/` chỉ có chat/names/pets/skills/maps;
  `vdk.so` = ELF 32-bit stripped, `.text` 42.676 B, `.rodata` 3.244 B, `.bss` 9,9 MB, **không export symbol** (tự đăng ký hàm Lua qua constructor)
  ⇒ đổi giá/món phải **build lại module**; pack `CHANGE PRICE - Do Bao` = **patch 23 byte trong `.text`** (không phải đổi dữ liệu).
  Client `vdk.dll` = **UPX-packed** ⇒ `strings` vô nghĩa. Chi tiết + lệnh so 2 bản module: `skills/jx1-simbot/references/packs-and-stall-shop.md`.
- 📡 Dòng Do Bao còn có **cầu client→server** `simbot_client_bridge_server.py` (UDP 39036, gói `CW1`/`CW2` + item descriptor 27 trường) +
  `libsimbot_whisper_spawn.so` + `sim.whisper.spawn.lua` + `server1/data/simbot_*.txt`, cài bằng **systemd** (WSL không chạy được) — server hiện tại **không có gì**
  trong số này. Bản chất = **CHATBOT/xin vật phẩm**, KHÔNG phải đường hiển thị quầy bán.
- 📦 **Pack `DOBAO SIMBOT VER 3` (07/08) = ALL-IN-ONE copy-only + REBOOT**: chuỗi autoload `systemd jxgame.service → LD_PRELOAD vdk.so`;
  `ActivitySys 801 → vdk/main.lua → simcity/main.lua → head.lua`; `jxs3relay + override → libsimbot_whisper_spawn.so`; `simbot-client-bridge.service → UDP 39036`.
  Số **quầy bán** điều khiển bằng config: `THANHTHI_STALL_NORMAL_MIN/MAX 133/192`, `THANHTHI_STALL_DATAU 30/45`, `THON_STALL_* 29/43 & 22/33`, `MONPHAI_STALL_SIZE 52`
  (`pthanhthi.lua` đọc kèm fallback). Kèm `SHA256_MANIFEST.txt` (51 KB) để verify. Module của pack (`13dd384e…`) khác bản đang chạy **đúng 4 byte `.text`, `.rodata` y hệt**.
  Chi tiết: `skills/jx1-simbot/references/packs-and-stall-shop.md`.
