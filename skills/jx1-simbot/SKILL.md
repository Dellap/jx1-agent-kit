---
name: jx1-simbot
description: Use khi làm việc với SimBot/SimCity JX1 (<GAME_HOST_IP>).
version: 1.0.0
author: Hermes Agent (bóc tách từ server <SERVER_NAME> <GAME_HOST_IP>)
license: MIT
metadata:
  hermes:
    tags: [game-development, jx1, vltk, simbot, simcity, bot-ai]
    related_skills: [vltk-server-ops, jx1-hqvl-knowledge, vltk-skill-data-modding]
---

# SimBot / SimCity — hệ thống NPC mô phỏng của JX1 (<GAME_HOST_IP>)

## ⚠️ QUY LUẬT TÊN FILE CỦA CLIENT JX1 (CTC) — TÊN = MOJIBAKE, KHÔNG PHẢI UNICODE

**Đã kiểm chứng 17/09/2026 trên client bạn:** mọi file/thư mục loose của client (kể cả file do client phát hành) đều có tên ở
**dạng mojibake**: bytes GBK bị hiểu thành Latin-1. Ví dụ sprite dir thật trên đĩa là `°ÚÌ¯` (không phải `摆摊`), `ÂòÂô` (không phải `买卖`),
`½»Ò×` (không phải `交易`), `´¢ÎïÏä` (không phải `储物箱`)… **không tồn tại** thư mục tên Unicode chuẩn nào.
⇒ Engine tra tên **theo bytes GBK** ⇒ khi copy bất kỳ file/thư mục có tên tiếng Trung vào client, **PHẢI đặt tên mojibake**:
`ten.encode('gbk').decode('latin-1')` (file ASCII như `battle_select.ini` thì không ảnh hưởng).
⛔ Kết luận cũ của tôi ("engine tra tên Unicode chuẩn") là **SAI** — copy tên Unicode chuẩn vào client = engine không thấy.

## Shop "đứng bán" của bot không mở ⇒ nguyên nhân ở MODULE ENGINE `vdk` (chốt 17/09/2026)

Triệu chứng: click vào bot đang đứng bán ⇒ **không hiện gì** (không cửa sổ, không báo lỗi).

**Chủ server (người test trực tiếp) kết luận: lỗi do module engine `vdk` — `vdk.dll` (client) / `vdk.so` (server);
KHÔNG phải thiếu file theme.** ⛔ Giả thuyết cũ của trợ lý ("theme `ui/ctc` thiếu cửa sổ `摆摊*`") là **sai/không đủ** —
đã copy đủ 6 ini + 9 sprite (cả tên mojibake lẫn Unicode) vào `ui/ctc` mà vẫn không mở ⇒ loại trừ đường thiếu file.

**Bằng chứng khảo sát 17/09 (đọc lại khi cần):**

| Thứ | Giá trị |
|---|---|
| `Client/vdk.dll` | 5.049.856 B, 21/08/2026 23:53, md5 `52ab92ef32da9519a45be890790f32f8` |
| 3 bản `vdk.dll` (Client, `UI/`, `SV/Client`) | **md5 giống nhau** ⇒ chỉ có 1 phiên bản client |
| `game.exe` | 2.684.872 B, **cùng mtime 21/08 23:53** với `vdk.dll`; trong `game.exe` có chuỗi `vdk.dll` ⇒ **client nạp vdk.dll** (kèm `VLTK_ui.dll`) |
| `JX1Mod.ini [AutoUILayout]` | `StartupDelayMs=6000` — chờ `VLTK_ui` + `vdk.dll` nạp xong rồi mới áp layout |
| `server1/vdk.so` | 54.229 B, 27/07, md5 `d364ec69232b5571af5c9fb10e8fd86a` |
| `server1/vdk.so_goc` | 54.084 B, 04/07, md5 `40420c2c3950ed50744d57bbe782e288` (khác bản đang chạy) |
| API trong **cả 2** bản .so | `SetNpcStall`, `PollTradeStay`, `SetBotStallTier`, `TradeStayClear`, `SendTradeItem`, `PollParty`, `PollDuel`, `SetBotPoints` |

- Đường đi "click xem hàng" nằm trong **engine**, không phải Lua: phía client `script/global/nobitaxd/vdk/simcity/**`
  chỉ đặt `stall=1` + gọi `SetNpcStall`/`NpcSit` (+ `SendTradeItem`/`PollTradeStay`), **không có** code mở cửa sổ khi click.
- Bản update mod 28/08 (`SV/update/VLTK HKMP/update lan 2_…rar`) **chỉ kèm Lua cho cả Client và jxser**, **không kèm binary**
  `vdk.*` ⇒ không có sẵn cặp binary thay thế trong máy.

**ĐÃ THỬ — KHÔNG PHẢI NGUYÊN NHÂN Ở BẢN `vdk.so` (17/09 21:36–21:44):**
- Đổi `vdk.so` sang bản `_goc` (04/07, md5 `40420c2c…`) + restart `jx_linux_y` (5 service UP, 0 người online) ⇒
  **chủ server vào click bot vẫn KHÔNG mở** ⇒ loại trừ bản `.so`. Đã rollback về bản 27/07 (`d364ec69…`).
- Script test để lại: `/root/test_vdk_goc.sh` (`swap` | `rollback`, tự chặn khi có người online, tự backup + verify md5).
  ⚠️ Bài học: script CHỈ nhận đúng tham số — chạy với tham số lạ từng làm nó tự `swap` (đã thêm chốt chặn).

**⇒ Còn lại nghi vấn ở phía CLIENT (cặp binary client) — bước kế tiếp:**
1. `game.exe` có 2 bản khác md5: `SV/Client/game.exe` **09/06/2026** (`e652eeea…`) vs bản đang chạy **21/08/2026** (`d48a6d19…`).
   Cả 2 bản đều có chuỗi `摆摊`/`摆摊物品`/`买卖` + `OpenShop`/`Stall` (đếm bằng nhau) ⇒ khác biệt không nằm ở tên cửa sổ.
   Test rẻ: backup `Client/game.exe` → chép bản 09/06 vào → tắt/mở client → click bot (1 file, đảo ngược được).
2. Test tách CLIENT vs BOT: nhờ người chơi thật dựng quầy (acc thứ 2) → nếu quầy **người thật mở được** mà quầy **bot không**
   ⇒ lỗi ở nhánh bot (server/giao dịch bot), không phải client engine; nếu cả hai đều không mở ⇒ lỗi client engine.
3. `vdk.dll` chỉ có 1 phiên bản trên toàn máy (md5 `52ab92ef…`, cả `SV/Client`, `UI/`, `Client/`) ⇒ không có bản khác để A/B.
4. Muốn có cặp đúng bản: hỏi nhà phát hành mod (bản update 28/08 chỉ kèm Lua, KHÔNG kèm binary).

## When to Use

- bạn nhắc "simbot", "SimCity", "bot dân thành thị", "kéo xe", "chiến loạn", "Thất Thành Đại Chiến",
  bot bán hàng (stall), bot Tống Kim, vật nuôi/tiểu thiếp.
- Cần sửa/thêm hành vi bot, thêm bản đồ cho bot đi lại, chỉnh giá bot bán, hoặc debug bot đứng im / không đánh.
- Không dùng cho vận hành server thường ngày (→ `vltk-server-ops`) hay mod skill (→ `vltk-skill-data-modding`).

**Nguồn:** mirror local `~/jx1-knowledge/simbot/` (tar từ server: `/tmp/simbot.tgz`), gồm
`server1/script/global/nobitaxd/vdk/simcity/**` (42 file Lua, 592K), `server1/settings/global/vdk/simcity/**`
(1.7M: maps/thanhthi/*.txt, chat.txt, names.txt, npcid2faction.txt, skills.txt, pets.txt),
`simtk.lua` (Tống Kim), `simsevencity.lua` (Thất Thành Đại Chiến, 135KB), `gateway/s3relay/script/simcity.lua`.
Cập nhật lại: tar + scp như lệnh ở `references/lessons.md`.

## Boot chain (server <GAME_HOST_IP>)

```
activitysys/config/801/head.lua        ← pActivity id 801 "Simcity" (nVersion 5, ngày 2024→3024 = luôn bật)
  InitAddNpc() → Include(\\script\\global\\nobitaxd\\vdk\\main.lua) → simcity_addNpcs()
  ClearTkNpc() → simcity_clearTongKim()
        └── nobitaxd/vdk/main.lua            ← entry: Include simcity\main.lua + eventsys (EnterMap/LeaveMap)
              └── simcity/main.lua           → AddTimer(REFRESH_RATE) mainLoop + worldLoop (mỗi 3×)
                    ├── head.lua             (IncludeLib + SetBotStallTier cho giá shop BOT)
                    ├── config.lua           (mọi tham số vận hành)
                    ├── plugins/index.lua    (12 plugin)
                    └── libs/data.lua        → nạp maps/thanhthi.txt + nodes/preset
```
`REFRESH_RATE = 18` → 18 frame = 1 giây; `mainLoop` chạy `SimCitizen:ATick()` + `SimTheoSau:ATick()`,
`worldLoop` chạy `SimCityWorld:ATick(20)` mỗi 3 nhịp.

## Kiến trúc file

| File | Vai trò |
|---|---|
| `components/sim.core.lua` | Lõi: `SimCore:initCharConfig/Remove/OnDeath`, chọn phái–hệ–skill búa–vũ khí, tầm cast theo skill (`SIMBOT_SKILL_RANGE`), taunt queue, `SimDuelEnd`, `PartyEnd/SimPartyFollow` |
| `components/sim.movement.lua` | AI di chuyển: `IsActive`, walk node graph, chase bằng `NpcRun`, chế độ train/Tống Kim, theo sau player, kéo xe formation |
| `components/sim.entity.lua` | Sinh/hồi sinh nhân vật: `execCreateChar`, `SimEntitySys` (đặt vị trí, `SetBotFaction`, `SetBotWeaponView`, `SetBotStallTier`) |
| `components/sim.fight.lua` | Chiến đấu: `LeaveFight`, `execCastNormalSkill`, buff (`SIMBOT_NGAMI_BUFF`, `SIMBOT_TRANPHAI`), debuff, HP cap |
| `components/sim.fun.lua` | Chat (`execChat` → `PollSayForBot` → category `SIM_SAY_REPLY`), rơi tiền, hồi sinh |
| `components/sim.timer.lua` | `OnDeath(nNpcIndex, attackerIndex)` → dispatch theo `PARAM_TYPE` (1 = Citizen, 2 = TheoSau) |
| `class/sim_citizen.lua` | Dân thành thị: vòng đời, `ClearMap`, `UpdateBotLadder`/`SetBotPoints` (điểm Tống/Kim), BXH |
| `class/sim_theosau.lua` | Sim theo sau (kéo xe / tiểu thiếp / vật nuôi) — dùng lại `SimCore` |
| `class/group_fighter.class.lua` | Đội hình nhóm (1.9k dòng) + 2 timer script (`group_fighter.timer[.child].lua`) |
| `plugins/pthanhthi.lua` | Thành thị: spawn theo batch, stall/dạ tầu, patrol, auto-add khi player vào map |
| `plugins/pchientranh.lua` | Chiến loạn (2 phe đánh nhau trong thành / công thành) |
| `plugins/ptongkim.lua` | Bot Tống Kim: rank, drop table, marshal, điểm |
| `plugins/pkeoxe.lua`, `ptieuthiep.lua`, `pvatnuoi.lua`, `pbatanh.lua` | Kéo xe (menu Vô Kỵ), tiểu thiếp, vật nuôi (mua/bán, gán skill), bá tánh (đi theo bảo vệ) |
| `plugins/pngoaitrang.lua` | Ngoại trang bot: 6 nhóm (áo/nón/vũ khí/ngựa × nam/nữ), theo cấp |
| `plugins/pnpcinfo.lua` | Thông tin NPC/template, blacklist, `SIMBOT_UNIFY_2000` (đồng nhất bộ NPC 2000+) |
| `plugins/pworld.lua` | World info: `initThanhThi`, đổi map Tống Kim dùng chung node map 10000, `SimBotTauntDrain` |
| `plugins/pname.lua` / `pchat.lua` | Kho tên người VN hoá + câu chat |
| `libs/walk.lua`, `walk_chientranh.lua`, `data.lua`, `common.lua` | Pathfinding node, đường đi chiến tranh, nạp settings, helper (`fixName`, `GetDistanceRadius`, `IsAttackableCamp`, `SimCityIsPeaceZone`) |
| `controllers/*.lua` | Menu GM gọi từ lệnh bài: `main_trieuman` (Triệu Mẫn), `main_voky` (kéo xe), `main_tieuthiep`, `main_vatnuoi`, `main` |

## Engine API (vdk.so) — bot không phải NPC thường

Bot dùng các hàm native riêng: `SetBotFaction`, `SetBotWeaponView`, `SetBotSpeed(idx,15,24)`, `SetBotPoints(mapIdx,S,J)`,
`SetBotStallTier(idx, tier, flag)` (đặt tier giá shop bot; `1000+N` = hệ số giá), `BotLadderClear(mapIdx)`,
`BotDoSkill`, `BotDuelDisarm`, `PollParty`, `PollDuel`, `PartyRebind/PartyClear`, `PollTradeStay`/`TradeStayClear`
(cơ chế đứng bán + phát item), `PollSayForBot`/`HasPlayerSay` (bot nghe chat player), `SetNpcBang`,
`GetTmpCamp`/`SetTmpCamp` + `GetCurCamp`/`SetNpcCurCamp`, `GetNpcLastAttacker`, `NpcRun/NpcWalk/NpcSit/NpcChat`,
`NPCINFO_GetNpcCurrentLife`, `AddNpcEx`, `RemoteExecute`.
Bảng đầy đủ + hàm nào bị engine bỏ qua: `references/engine-api.md`.

## Cơ chế cốt lõi (nhớ 6 điều này)

1. **Hai hệ camp**: `CurCamp` (1–3, chỉ visual/AI) và `TmpCamp` (camp tổng đã đăng ký, ≥5) quyết định
   **damage check**. Server cho camp 1/2/3 đánh nhau; camp 4 = sát thủ không combat.
2. **Bot là "npc kind 0" + param riêng**: `PARAM_LIST_ID=1`, `PARAM_CHILD_ID=2`, `PARAM_TYPE=3`
   (1 = SimCitizen, 2 = SimTheoSau). Muốn bot bị đánh được → `kind = 0`, `AI = 1`.
3. **Vòng đời**: `SimCitizen:New(fighter)` → `initCharConfig` → `movementSys:resetPos` →
   `entitySys:CreateChar` → tick `movementSys`/`fightSys`/`funSys` → `OnDeath` → `Respawn` hoặc `Remove`
   (id trả về `removedIds` để tái dùng).
4. **Di chuyển bằng node graph**: settings `maps/thanhthi/<id>_<ten>_nodes.txt` (node → node liên kết) và
   `_preset.txt` (tên path → chuỗi node); `walkMode` = `random` (bơi trong walkAreas) / `preset` (đi theo path) /
   `formation` (theo parent). Thành thị = 600 bot, thôn = 100 (`THANHTHI_SIZE`/`THON_SIZE`).
5. **Chat 2 chiều**: bot nói ngẫu nhiên (`CHANCE_CHAT`) và **trả lời player** khi player nói gần
   (`PollSayForBot` trả category → map sang `rep_chung/rep_ok/rep_no/rep_chao/rep_giaodich/rep_boss` trong `chat.txt`);
   chửi nhau (taunt) đi qua queue rate-limit `SimBotTaunt`/`SimBotTauntDrain`.
6. **Giá shop bot**: `config.lua` → `BOT_STALL_PRICE_MULTIPLIER` (1–100) → `head.lua` gọi
   `SetBotStallTier(0, 1000 + N, 1)` lúc boot; bot dạ tầu (`daTau=1`) dùng `daTauNodes` quanh Dạ Tầu.

## Knobs hay dùng

`config.lua`: `STARTUP_AUTOADD_THANHTHI`, `THANHTHI_SIZE`, `THON_SIZE`, `LUYENCONG_AUTOADD`,
`RADIUS_FIGHT_PLAYER/NPC/SCAN`, `CHANCE_*`, `BOT_VS_BOT`, `BOT_COMBAT_RADIUS`, `BOT_STALL_PRICE_MULTIPLIER`,
`TIME_FIGHTING/TIME_RESTING`, `DISTANCE_FOLLOW_PLAYER/TOOFAR`, `LIFE_RESTORE_PERCENT`, `LEVEL_TRACK_PLAYERS`,
`BOT_FLEE_HP`, `NEWBIE_PROTECT_LEVEL`, `PARTY_OPEN_GROUPS/CHILDREN`, `ENABLE_BANNGUAMIXDEV`.
`simsevencity.CFG`: `BANG_NAMES` (7 bang giả, prefix `@SIMBOT@`), `CENTER_BOTS_PER_BANG=50`,
`INVADER_GATE_BOTS=80`, `AGGRO_RADIUS_*`, `BATCH_RESPAWN_ENABLED`+`BATCH_TRIGGER_RATIO=0.5`+`BATCH_COOLDOWN_SEC=30`
+`BATCH_STAGGER_PER_TICK=5`, `RESPAWN_MIN/MAX_SEC`, `NPC_POOL` (2000–2023), `KEOXE_SPREAD_*`, `KEOXE_FORMATION_*`,
`KEOXE_CHILDREN_CHECK_DIST`.

## Pitfalls (từ chính lịch sử dev của server)

- **Lua 4.x**: KHÔNG có `string.match/gsub`; **timer env không thấy global** → hook trong file timer phải
  cache ref (`self.m_RefSimCitizen = ...`) hoặc gán lên table, nếu không sẽ nil âm thầm.
- **JX1 không có `SetNpcPos`** → muốn bot hiện đúng chỗ phải override `goX32/goY32` **trước** `CreateChar`
  (pre-spawn), không teleport sau.
- **`SetTmpCamp` không "stick"** (engine ghi đè) → phải enforce lại mỗi tick qua watchdog sweep `fighterList`
  (~0.22s), và cẩn thận idx bot bị tái dùng cho sim khác (kéo xe) → kiểm `m_NpcIdx2BangIdx` trước khi ghi.
- **Sửa file script phải restart `jx_linux_y`** mới có hiệu lực; backup `.bak` trước, verify md5 sau.
- Đè/đổi thứ tự NPC hay map ID trong `maplist/worldset/npcs` → bot spawn sai chỗ hoặc không thấy.
- Debug: `OutputMsg` (hiện luôn), `SimThatThanh.DEBUG_LOG = 1` (bật log file), các lệnh GM kiểm tra:
  `/Lua SimTDC_InspectBots()`, `...InspectBots(926)`, `Status`, `FixAll`.

## Tham chiếu

- `references/engine-api.md` — danh sách hàm engine/native + ngữ nghĩa camp + điểm khác NPC thường
- `references/settings-format.md` — định dạng mọi file settings (thanhthi.txt, nodes, preset, chat, pets, names, npcid2faction, skills) + cách thêm map/đường đi
- `references/lessons.md` — NHẬT KÝ KINH NGHIỆM theo ngày (2026-06-19 → 08-12): từng bug đã gặp và cách xử lý, gồm cả các nhánh đã tắt và lý do
