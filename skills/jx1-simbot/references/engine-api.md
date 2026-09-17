# Engine API / native — SimBot (bóc từ code <GAME_HOST_IP>)

## ⚠️ ĐÍNH CHÍNH sau khi đối chiếu server thật (17/09/2026)

- §2: **`BT_SetData` KHÔNG tồn tại** → tên đúng là **`BT_SetData(data, value)`** (`plugins/ptongkim.lua:145,180`); đi kèm `BT_SortLadder()`, `BT_BroadSelf()` (luôn gọi sau khi ghi điểm).
- §1: thêm số liệu — `BOT_STALL_PRICE_MULTIPLIER = 15` (thang tối đa 100) ⇒ bot bán giá ×15; bot `daTau=1` dùng tier 0, shop thường qua `head.lua`.
- §3.1: `PARAM_TYPE = 2` khi `role == "keoxe"` (SimTheoSau); **= 1 cho mọi role khác kể cả `child`**; và **param 4 = 1** là cờ "NPC do SimCity quản lý" (`sim.entity.lua:93-100`).
- Mọi hàm engine bot đều được guard kiểu `if SetBotPoints then …` ⇒ **engine có thể thiếu hàm**, giữ thói quen guard khi viết code mới.


## 1. Nhóm hàm CHỈ có cho bot (vdk.so mở rộng)

| Hàm | Ý nghĩa / tham số quan sát được trong code |
|---|---|
| `SetBotFaction(npcIdx, factionIdx)` | Gán phái cho bot (visual + skill) |
| `SetBotWeaponView(npcIdx, weaponClassIdx)` | Đổi hình vũ khí hiển thị (khớp skill búa) |
| `SetBotSpeed(npcIdx, 15, 24)` | Tốc chạy/đi (dùng lại sau mỗi lần respawn/party end) |
| `SetBotPoints(mapIdx, S, J)` | Ghi điểm Tống(S)/Kim(J) của map → nguồn cho BXH Tống Kim + `simtk.lua` |
| `SetBotStallTier(npcIdx, tier, flag)` | Tier giá shop bot. `head.lua` dùng mã `1000 + BOT_STALL_PRICE_MULTIPLIER` (vdk.so V4 xử lý riêng, KHÔNG sửa tier/item gốc) |
| `BotLadderClear(mapIdx)` | Xoá bảng xếp hạng bot của map (khi clear map / kết thúc chiến) |
| `BotDoSkill`, `BotDuelDisarm` | Bot chủ động dùng skill / hạ vũ khí khi kết thúc duel |
| `PollParty(npcIdx)`, `PartyRebind`, `PartyClear` | Đội nhóm bot (theo player) — `PollParty <= 0` nghĩa là hết party |
| `PollDuel(npcIdx)`, `SetNpcDuelEnd` | Duel player↔bot |
| `PollTradeStay(npcIdx)` → 0/1/2, `TradeStayClear(npcIdx)` | Trạng thái "đứng bán": 2 = đang giao dịch/bày hàng; code phải clear state trước khi bot đổi mục tiêu (xem `sim.core.lua` quanh dòng 859–931) |
| `PollSayForBot(npcIdx)` → category, `HasPlayerSay()` | Player nói gần → bot trả lời theo category (`SIM_SAY_REPLY`: 0 rep_chung, 1 rep_ok, 2 rep_no, 3 rep_chao, 4 rep_giaodich, 5 rep_boss) |
| `SetNpcBang(npcIdx, bangIdx)` | Gán bang cho bot (Thất Thành Đại Chiến) |
| `GetTmpCamp(npcIdx)` / `SetTmpCamp(npcIdx, camp)` | Camp tính damage (camp tổng đã đăng ký, ≥5) |
| `GetCurCamp()` / `GetNpcCurCamp` / `SetNpcCurCamp(npcIdx, camp)` | Camp hiển thị/AI (1–3 hợp lệ để đánh nhau; 4 = sát thủ không combat) |
| `GetNpcLastAttacker(npcIdx)` | Dùng để chống "bu vào player vô cớ": chỉ nhắm player nào thực sự đã đánh bot |

## 2. Hàm engine dùng chung (NPC thường cũng có)

`AddNpc`, `AddNpcEx`, `DelNpc`, `IsNpcExist`, `GetNpcPos`, `GetNpcParam`/`SetNpcParam`, `GetNpcKind`/`SetNpcKind`,
`GetNpcName`/`SetNpcTitle`, `SetNpcLevel`, `SetNpcAI`, `SetNpcCombat`, `SetNpcAtkSpeed`, `SetNpcTimer`,
`SetNpcScript`/`SetNpcDeathScript`, `SetNpcAuraSkill`, `AddNpcSkillState`, `NpcCastSkill`, `NpcChat`, `NpcRun`,
`NpcWalk`, `NpcSit`, `NpcDropMoney`, `DropItem`, `GetNpcAroundPlayerList`, `GetNpcAroundNpcList` (có fallback
trả `{},0` trong `libs/common.lua` khi engine thiếu), `GetWorldPos`, `GetAroundNpcList`,
`CallPlayerFunction(pID, fn, ...)`, `PIdx2NpcIdx`, `NpcIdx2PIdx`, `SubWorldID2Idx`, `SubWorldIdx2ID`,
`NPCINFO_GetNpcCurrentLife`, `NPCINFO_SetNpcCurrentLife`, `NPCINFO_GetNpcCurrentMaxLife`, `SetMissionV`,
`RemoteExecute`, `TabFile_Load/GetRowCount/GetCell` (đọc settings dạng TSV), `Msg2Map`, `Msg2Player`, `OutputMsg`,
`AddTimer(frame, fnName, self)`, `GetGameTime`, `GetPlayerPkMode`, `GetCash`, `Pay`, `BT_GetData/GetTypeBonus/BattleParam/GetGameData` (Tống Kim).

## 3. Ba điểm khác biệt so với NPC thường

1. Bot dùng **param riêng**: `GetNpcParam(idx, PARAM_LIST_ID=1)` → id trong `fighterList`; `PARAM_TYPE=3`
   → 1 = `SimCitizen`, 2 = `SimTheoSau`; `PARAM_CHILD_ID=2` → id cha của sim con.
2. Bot có **bảng xếp hạng + điểm phe** nội bộ (`SetBotPoints`, `BotLadderClear`) — Tống Kim đọc lại điểm này
   trong `server1/script/battles/marshal/simtk.lua` (`g_simBotPointS`, `g_simBotPointJ`).
3. Bot có **shop riêng (stall)**: bot `stall = 1` đứng một chỗ bán hàng, giá do `SetBotStallTier` quyết định,
   trạng thái giao dịch đọc bằng `PollTradeStay`; khi bot rời chỗ bán phải gọi `TradeStayClear` và xoá
   `tradeStay*`, `tradePostUntil`, `greetStayDeadline`, `tradeItemSent/At` (đây chính là fix mới thêm vào
   `sim.core.lua` so với bản `_goc`).

## 4. Chỗ "engine không nghe lệnh" (đã kiểm chứng trong code)

- `SetTmpCamp` bị engine ghi đè sau khi bot rời combat (`SimMovement.Citizen` có thể reset CurCamp=6, TmpCamp=0)
  → phải có watchdog sweep mỗi tick từ `fighterList`, và guard idx tái sử dụng.
- `SetNpcPos` **không tồn tại** trên JX1 → mọi "dịch chuyển" bot phải làm lúc tạo nhân vật
  (override `goX32/goY32` trong hook `CreateChar`).
- Timer/env khác: closure Lua 4.x **không giữ upvalue** và env timer **không thấy global** →
  cache ref vào table (`self.m_RefSimCitizen`, `FIELD_LIST` cache) trước khi dùng trong hook.
