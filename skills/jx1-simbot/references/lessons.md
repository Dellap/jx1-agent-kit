# Nhật ký kinh nghiệm SimBot (<GAME_HOST_IP>) — bóc từ comment có ngày trong code

Đây là "kinh nghiệm" thật của người dev server, ghi lại theo ngày trong chính source. Đọc trước khi sửa
hành vi bot — mỗi dòng là một bug đã trả giá.

## 1. Mốc thời gian (2026-06 → 2026-08)

| Ngày | Việc / bài học |
|---|---|
| **06-19 STALL FIX** | **TẮT stuck-respawn cho bot ngồi bán**: bot stall đứng yên 1 chỗ là đúng thiết kế; trước bị nhầm "lag/kẹt" → respawn sau vài phút → `dwID` đổi → sập + tin tức rớt (tìm theo dwID cũ không thấy). Nếu cần lại stuck-recovery thì phải **gate theo cờ stall** (chỉ áp cho bot có di chuyển). |
| **06-20 DẠ TẦU** | Thêm stall tụ tập quanh Dạ Tầu: đặt `daTau=1` → `sim.entity` dùng `daTauNodes`. |
| **06-20 COMBAT** | **Đuổi NPC địch gần nhất bằng `NpcRun`** → 2 bot đánh nhau di chuyển mượt như player. **KHÔNG đuổi player** (để bot đánh NHAU sôi nổi, không bù theo người chơi — player vẫn bị bám nếu tự gây chiến). |
| **06-20 AGGRO** | `SIMBOT_AGGRO_PLAYER = 1`: bot nhắm + đánh player khác camp **dù player chưa bật chiến đấu**. |
| **06-21 CHAT REPLY** | Bot **trả lời player nói gần**: `HasPlayerSay()` + `PollSayForBot(idx)` → category → `SIM_SAY_REPLY` (rep_chung/ok/no/chao/giaodich/boss) → random câu trong `chat.txt`. Ghi chú: tạm dùng `NpcChat` (bong bóng); muốn `CH_NEARBY` phải fix client DLL (`BotSayLocal` — để sau). |
| **06-23 ƯU TIÊN PLAYER** | ~25% bot gần player khác camp nhắm **player trước** (`CHANCE_PREFER_PLAYER=25`), còn lại đánh NPC như cũ. Không có NPC địch → **bám theo player**. |
| **06-24 SELF-DEFENSE** | Bị đánh (`selfDefTick` còn hiệu lực) → nhắm **BẤT KỲ player gần**, kể cả **cùng camp** (= kẻ tấn công), bỏ qua `IsAttackableCamp`. |
| **06-25 BỎ BÁM PLAYER** | **Không đi theo player nữa**: bot cùng camp không bám; engage CHỈ khi bị đánh (self-def). Thay bằng **lang thang ngẫu nhiên quanh chỗ đứng** → bot có "việc làm", không bám, không đứng im frozen. Respawn-quá-xa vẫn kéo bot về gần player để populate map. |
| **06-25 BỎ GetFightState** | Bot **chỉ đánh trả khi BỊ ĐÁNH**, không aggro chỉ vì player đang ở fight-mode đánh con khác. |
| **06-26 BỎ bypass selfDefTick** | `SimCityCanFight` đã bao self-def ngoài thành (1) + hoà bình trong thành (0) → bỏ điều kiện bypass. Và **chỉ nhắm THỦ PHẠM THẬT**: `GetNpcLastAttacker(idx) == player đó` — bot-vs-bot tụt máu thì thủ phạm là bot, KHÔNG bù vào player dù player ở combat-mode. |
| **06-26 ENGINE RESIST** | **`SetTmpCamp` không "stick"** (engine ghi đè) → phải enforce qua watchdog sweep mỗi tick. |
| **06-27 TẮT FAST-CAST** | Tắt `FastCastTick` + `SetNpcFightTarget` (ghi đè target của engine-AI mỗi 0.7s → **phá bot-vs-bot vừa chạy được hôm trước**) → trả về engine-AI tự nhiên. Fast-cast chuyển vào `mainLoop` (bỏ timer riêng vì không ổn định). |
| **06-28 TRAIN + TK ACTIVE** | train bot proximity-aggro player tới gần (thành/thôn vẫn peace). **train + Tống Kim bot LUÔN active** → đánh nhau liên tục dù xa player (trước: TK xa player → inactive → march không đánh). |
| **06-28 THEO SAU** | player **DI CHUYỂN** + bot cách xa → chạy theo; player **ĐỨNG** → đứng im (đa số), chỉ ~15% bot dịch nhẹ ±2 cho tự nhiên. Trước: wander ±4 mỗi 4–10 tick → 10 con nhúc nhích rất khó chịu. |
| **06-28 TK RALLY** | Điều hướng bot Tống Kim khi không đánh: có **boss MÌNH** → về THỦ; **boss ĐỊCH** → qua ĐÁNH; chưa có boss → **dồn giữa map** (sôi động, hết idle/march chờ cũ). |

## 2. Bài học Thất Thành Đại Chiến (`simsevencity.lua`, 3587 dòng)

- **Tick math**: "Cũ dùng tick math sai unit → 30s thành 180s" — luôn quy đổi theo `REFRESH_RATE = 18` (18 frame = 1s),
  đừng trộn giây với frame.
- **Watchdog sweep mỗi tick (~0.22s)** từ `fighterList` là bắt buộc: `SimMovement.Citizen` có thể reset
  `CurCamp=6`, `TmpCamp=0` khi bot rời combat; orphan scanner cũ (chỉ check registry) bỏ sót bot bị tái dùng idx.
- **Idx tái sử dụng**: bot defender chết → `fighter.finalIndex` stale → cùng idx có thể được cấp cho sim khác
  (vd sim kéo xe) → phải guard bằng `m_NpcIdx2BangIdx` trước khi đổi camp/state.
- **Pillar detection**: match **STRICT `killed_index`** với idx đã cache — KHÔNG match `m_NpcIndex = 0`
  (false-positive cho mọi map có trụ tạm chưa set). Dùng `attackerIndex` khi engine truyền; engine có thể trả 0.
- **Suppress bot-kill trong lúc setup/cleanup**: `DelNpc` trigger `OnDeath` → false-positive "bot giết trụ".
- **Không dùng `m_MapNpcs`** để đếm/duyệt bot (dễ stale) → dùng `fighterList`.
- **Cross-env**: timer/scheduler chạy env khác **không thấy global** (`SimCitizen`, `SimFight`, `SimThatThanh`)
  và closure Lua 4.x không giữ upvalue → cache refs trên `self.m_Ref*` / table (`FIELD_LIST` cũng phải cache).
- **Batch respawn theo đợt** thay vì respawn lẻ: trigger khi bot sống ≤ 50% (`BATCH_TRIGGER_RATIO`),
  cooldown 30s/map, spawn 5 bot mỗi tick (`BATCH_STAGGER_PER_TICK`) cho mượt, có announce tuỳ chọn.
- **Formation/chống cluster**: spawn 50% gần + 50% xa, random hướng 0–360° (thay 4 hướng cardinal),
  `KEOXE_SPREAD_MIN/MAX_DIST` (3–6 ô), formation scale + jitter; `KEOXE_CHILDREN_CHECK_DIST` gốc 8 ⇒ sim luôn bị
  kéo gần player dù `parentAppointPos` ở xa (tăng/để 0 nếu muốn giãn).
- **Bot không attackable** nếu spawn nhầm `kind = 1` → force lại `kind = 0` (quái mode) + `AI = 1` ngay sau spawn.

## 3. Khác biệt bản gốc vs bản đang chạy (mẹo kiểm tra)

Server giữ file gốc song song: `sim.core.lua_goc` vs `sim.core.lua`; `config.lua.<SMB_USER>.<timestamp>.bak` là backup
tự động khi sửa qua webpanel. **Muốn biết đã sửa gì: diff `_goc` ↔ bản hiện tại.**
Ví dụ đã phát hiện (diff 24 dòng): bản hiện tại thêm block **clear toàn bộ state stall/giao dịch** khi bot có
`PollTradeStay > 0` (gọi `TradeStayClear` + xoá `tradeStayDeadline/Bye/ByeUntil`, `tradePostUntil`,
`greetStayDeadline`, `tradeItemSent/At`, đặt `_ts = 0`) → chống bot "dính" trạng thái bán hàng khi đổi mục tiêu.

## 4. Làm mới mirror (khi code trên server đã thay đổi)

```bash
ssh jx1 'bash -lc "cd /home/jxser && tar czf /tmp/simbot.tgz \
  server1/script/global/nobitaxd/vdk/simcity server1/settings/global/vdk \
  gateway/s3relay/script/simcity.lua server1/script/battles/marshal/simtk.lua \
  server1/script/missions/sevencity/simsevencity*.lua"'
scp jx1:/tmp/simbot.tgz ~/jx1-knowledge/simbot/ && tar xzf ~/jx1-knowledge/simbot/simbot.tgz -C ~/jx1-knowledge/simbot/
```
File Lua/settings là **iso-8859-1 / TCVN3**, thường KHÔNG decode được UTF-8 → đọc bằng `latin-1` (1 byte = 1 ký tự)
rồi `iconv`/bảng mã khi cần xem chữ có dấu, hoặc coi phần code là ASCII và bỏ qua comment mojibake.

## 5. Khi cần thêm hành vi mới — checklist

1. Xác định tầng: hành vi di chuyển → `sim.movement.lua`; chiến đấu/buff → `sim.fight.lua`; sinh/nhân dạng →
   `sim.entity.lua`; nói/tương tác → `sim.fun.lua`; sự kiện theo map → `plugins/p*.lua`; tham số → `config.lua`.
2. Ưu tiên **cờ config** (kiểu `SIMBOT_XXX = 0/1`) để tắt nhanh khi lỗi — server này toàn làm vậy
   (`SIMBOT_AGGRO_PLAYER`, `SIMBOT_TRANPHAI`, `SIMBOT_BUFF_REALCAST`, `SIMBOT_NOFIGHT_MAPS`…).
3. Đừng tin state engine sau 1 lần gọi — cần **enforce mỗi tick** + guard idx tái dùng.
4. Test trong game bằng menu Triệu Mẫn / lệnh GM, rồi restart `jx_linux_y`.
