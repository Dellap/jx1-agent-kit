---
name: jx1-simbot
description: Use khi làm việc với SimBot/SimCity JX1 (<GAME_HOST_IP>).
version: 1.0.0
author: Hermes Agent (bóc tách từ server <SERVER_NAME> <GAME_HOST_IP>)
license: MIT
metadata:
  hermes:
    tags: [game-development, jx1, <SSH_ALIAS>, simbot, simcity, bot-ai]
    related_skills: [<SSH_ALIAS>-server-ops, jx1-hqvl-knowledge, <SSH_ALIAS>-skill-data-modding]
---

# SimBot / SimCity — hệ thống NPC mô phỏng của JX1 (<GAME_HOST_IP>)


## 🔎 Pack/update & lỗi "quầy bot không hiện đồ" → `references/packs-and-stall-shop.md`

Toàn bộ lịch sử 3 pack (NPC PLAYER HIỆN BANG · CHANGE PRICE SIMCITY SHOP · DOBAO SIMBOT VER 3), cơ chế giá quầy bot, ruột module `vdk.so`, bảng 8 phép thử đã loại trừ và trạng thái lỗi **để ngõ** đã tách ra file tham chiếu — đọc file đó TRƯỚC khi thử lại bất cứ hướng nào.

## ⚠️ QUY LUẬT TÊN FILE CỦA CLIENT JX1 (CTC) — TÊN = MOJIBAKE _(bản canonical: skill `<SSH_ALIAS>-client-modding`; đây là bản nhắc lại cho simbot)_

**Đã kiểm chứng 17/09/2026 trên client bạn:** mọi file/thư mục loose của client (kể cả file do client phát hành) đều có tên ở
**dạng mojibake**: bytes GBK bị hiểu thành Latin-1. Ví dụ sprite dir thật trên đĩa là `°ÚÌ¯` (không phải `摆摊`), `ÂòÂô` (không phải `买卖`),
`½»Ò×` (không phải `交易`), `´¢ÎïÏä` (không phải `储物箱`)… **không tồn tại** thư mục tên Unicode chuẩn nào.
⇒ Engine tra tên **theo bytes GBK** ⇒ khi copy bất kỳ file/thư mục có tên tiếng Trung vào client, **PHẢI đặt tên mojibake**:
`ten.encode('gbk').decode('latin-1')` (file ASCII như `battle_select.ini` thì không ảnh hưởng).
⛔ Kết luận cũ của tôi ("engine tra tên Unicode chuẩn") là **SAI** — copy tên Unicode chuẩn vào client = engine không thấy.

## When to Use

- bạn nhắc "simbot", "SimCity", "bot dân thành thị", "kéo xe", "chiến loạn", "Thất Thành Đại Chiến",
  bot bán hàng (stall), bot Tống Kim, vật nuôi/tiểu thiếp.
- Cần sửa/thêm hành vi bot, thêm bản đồ cho bot đi lại, chỉnh giá bot bán, hoặc debug bot đứng im / không đánh.
- Không dùng cho vận hành server thường ngày (→ `<SSH_ALIAS>-server-ops`) hay mod skill (→ `<SSH_ALIAS>-skill-data-modding`).

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

## 📚 Tài liệu HQVL — SimCity/bot (kho cộng đồng)

> **Tài liệu HQVL liên quan** (60 tài liệu cộng đồng đã bóc text). Bản đầy đủ: repo này `sources/hqvl-docs-text/<file>` (trên máy: `~/jx1-knowledge/text/`). Mục lục + trích đoạn: skill `jx1-hqvl-knowledge/references/doc-index.md`.

- `jx1-scripts__0001_simcity__README.md.txt` — **simcity** (vinh-ttn) — README gốc hệ simcity cộng đồng
- `wiki-beta__jx6__share_source_jx_simcity_1.x.html.txt` — share source JX SimCity 1.x
- `wiki-beta__jx6__lua_script_-_keo_xe_npc_1.x.html.txt` — Lua script kéo xe NPC 1.x

## Tham chiếu

- `references/packs-and-stall-shop.md` — **đọc trước khi thử lại bất kỳ hướng nào cho lỗi "quầy bot không hiện đồ"**: 3 pack đã áp/khảo sát, cơ chế giá quầy bot, ruột module `vdk.so`, bảng 8 phép thử đã loại trừ, trạng thái lỗi để ngõ
- `references/engine-api.md` — danh sách hàm engine/native + ngữ nghĩa camp + điểm khác NPC thường
- `references/settings-format.md` — định dạng mọi file settings (thanhthi.txt, nodes, preset, chat, pets, names, npcid2faction, skills) + cách thêm map/đường đi
- `references/lessons.md` — NHẬT KÝ KINH NGHIỆM theo ngày (2026-06-19 → 08-12): từng bug đã gặp và cách xử lý, gồm cả các nhánh đã tắt và lý do