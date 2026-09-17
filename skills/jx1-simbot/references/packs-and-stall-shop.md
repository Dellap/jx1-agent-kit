# Pack/update SimCity & lỗi "quầy bot không hiện đồ" (JX1)

> Tách từ `SKILL.md` ngày 17/09/2026 (skill gọn lại để tra cứu nhanh). Đây là nhật ký điều tra + số liệu thật.

## Update `NPC PLAYER HIỆN BANG` (17/09/2026) — ĐÃ ÁP, KHÔNG fix lỗi quầy bot

Pack: `<GAME_ROOT>\Update\NPC PLAYER HIỆN BANG\` = **server Lua drop-in** (Lua-only, KHÔNG binary).
- `ORIGINAL-GỐC/` = 19 file — **md5 trùng 19/19 với server đang chạy** ⇒ pack làm riêng cho đúng build này.
- `TEST FIX LỖI/` = 19 file sửa + **file mới `libs/guard.lua`** (174 dòng, md5 `226d6b1b…`).
- Nội dung fix: định danh NPC theo **`GetNpcId`** (không tin `NpcIndex` — index bị engine dùng lại sau khi NPC chết ⇒ timer cũ tác động nhầm NPC/player mới). Hàm chính: `SimCityBindNpcRef` (bind lúc spawn, `sim.entity.lua` dòng 80), `SimCityIsOwnedNpc` (**fail-closed**: thiếu `GetNpcId`/lệch id ⇒ 0), `SimCityIsRealPlayerNpc` (`NpcIdx2PIdx > 0` ⇒ loại), `SimCityDelOwnedNpc`, `SimCitySameNpcInstance`, `SimCityIsNaturalNpcCandidate`. Gate mới cho Combat/Bang/DuelEnd/xoá NPC.
- `GetNpcId` + `NpcIdx2PIdx` do **`server1/jx_linux_y`** cung cấp (KHÔNG có trong `vdk.so` — tra `strings vdk.so` sẽ không thấy, đừng kết luận vội là thiếu API).
- **Bản fix bỏ luôn khối `if _ts > 0 … _ts = 0` trong `sim.core.lua`** (khối này giết mọi giao dịch; xem phép thử #3) ⇒ tác giả mod cũng coi đó là lỗi.
- ⚠️ Gate `UpdateStallFlags` đổi thành `SimCityIsOwnedNpc(fighter, fighter.finalIndex) == 1` trước `SetNpcStall` ⇒ nếu guard fail-closed sai thì **bot không còn được đánh dấu quầy** (triệu chứng y hệt "click không hiện gì") — cần log `owned=` để loại trừ.
- **KẾT QUẢ TEST (bạn test 17/09 ~22:00–22:20): vẫn KHÔNG hiện đồ bot bày bán** ⇒ pack sửa nhóm lỗi khác (index tái dùng / Bang / Camp), KHÔNG phải lỗi này. Đã GIỮ pack (fix thật, có backup + `revert`).
- Test kèm (bạn tự làm, cùng âm tính): tắt hook client `EquipmentCompare=0` và `[OneDLL] Enabled=0` trong `Client\JX1Mod.ini` (ONE.DLL V6.2a có hook **CompareShop** cắm vào cửa sổ shop) → **vẫn không hiện**.

## Pack `CHANGE PRICE SIMCITY SHOP - Do Bao` (17/09/2026) — CƠ CHẾ GIÁ QUẦY BOT

Pack = **3 file, không README**: `vdk.so` + `script/global/nobitaxd/vdk/simcity/{config.lua, head.lua}`.
- `vdk.so` của pack (54.229 B, 27/07, md5 `d364ec69…`) **chính là bản server đang chạy** ⇒ **module sinh quầy + đồ cho bot nằm trong `vdk.so`**.
- `head.lua` (khớp 100% bản đang chạy):
  ```lua
  if SetBotStallTier and BOT_STALL_PRICE_MULTIPLIER then
      SetBotStallTier(0, 1000 + BOT_STALL_PRICE_MULTIPLIER, 1)
  end
  ```
  ⇒ **giá bot bày bán = tier `1000 + BOT_STALL_PRICE_MULTIPLIER`**; biến nằm ở `config.lua` (thang `1..100`, "1 = giá gốc").
  ⚠️ Nếu `BOT_STALL_PRICE_MULTIPLIER` **không tồn tại** ⇒ cả lời gọi bị bỏ ⇒ **tier không được đăng ký** ⇒ quầy bot không có bảng giá/đồ.
  (Giả thuyết đáng test cho lỗi "click bot không hiện đồ": tier sai/thiếu ⇒ module không dựng được nội dung quầy.)
- Pack đặt `BOT_STALL_PRICE_MULTIPLIER = 15`; server đang để `100` (<SMB_USER> 08/09). **Đã đổi về `15` theo pack (17/09 22:27)** — muốn lại `100` thì sửa 1 dòng + restart.
- `config.lua` của pack là **baseline cũ** (300 bot, chat 10, `ENABLE_BANNGUAMIXDEV=0`) ⇒ **KHÔNG ghi đè cả file**, chỉ lấy dòng giá (xem bài học dưới).
- Ghi chú: giá hiển thị ở client còn có `BOT_STALL_PRICE_MULTIPLIER` trong `Client/script/.../simcity/config.lua` (= 100).

## 🔬 CƠ CHẾ "BÀY BÁN" CỦA BOT — đọc từ module (số liệu thật 17/09/2026)

**Ai dựng nội dung quầy?** KHÔNG phải Lua, KHÔNG có file dữ liệu — chính là **module `vdk.so`**:
- `settings/global/vdk/simcity/` chỉ có `chat.txt`, `names.txt`, `npcid2faction.txt`, `pets.txt`, `skills.txt`, `maps/` ⇒ **không có file shop/goods/stall/item** nào.
- `vdk.so` = ELF 32-bit, **stripped**, `.text` 42.676 B, `.rodata` 3.244 B, **`.bss` 9,9 MB** (bảng dữ liệu tĩnh nằm trong module), nạp bằng `LD_PRELOAD` (systemd `vdk.conf` hoặc `boot_all.sh`).
- `.dynsym` **không export hàm nào** (chỉ 3 hàm ngoài: `__divdi3`, `__udivdi3`, `strlen`) ⇒ nó **tự đăng ký hàm vào Lua** bằng constructor `.init_array`; tên hàm nằm trong `.rodata`: `SetNpcStall`, `SetBotStallTier`, `SendTradeItem`, `PollTradeStay`, `TradeStayClear`, `SetNpcCombat`, `SetNpcBang`, `SetNpcDuelEnd`, `NpcSit`, `NpcRun`, `AddNpcStateInfo`, `GetNpcAreaRaw`…
- ⇒ Muốn đổi **giá hoặc danh sách món** của quầy bot **phải build lại module**; chỉ có 1 nút vặn từ Lua: `SetBotStallTier(0, 1000 + BOT_STALL_PRICE_MULTIPLIER, 1)`.
- ⇒ Hệ quả cho lỗi "click bot không hiện đồ": đường dựng/hiện quầy nằm **trong cặp module** (`vdk.so` server ↔ `vdk.dll` client) — mọi thứ sửa được bằng ini/settings/Lua đều **không thể** chạm tới nó.

**Pack `CHANGE PRICE SIMCITY SHOP - Do Bao` = PATCH NHỊ PHÂN, không phải đổi dữ liệu** (đã đo):
- `vdk.so` pack (`d364ec69…`) vs `vdk.so_goc` (04/07, `40420c2c…`): **khác đúng 23 byte trong `.text`, `.rodata` giống hệt**; bản pack thêm 1 đoạn code ở `0xb700` và đổi `0x2144` thành `jmp 0xb700` (nhánh xử lý mã `1000+N`).
- Cách kiểm 1 bản module có gì mới (dùng lại được):
  ```bash
  readelf -SW vdk.so | grep -E "\.text|\.rodata|\.bss"     # kích thước/lệch
  objcopy -O binary --only-section=.text  vdk.so /tmp/a; objcopy -O binary --only-section=.text vdk.so_goc /tmp/b
  cmp -l /tmp/a /tmp/b | head                              # byte nào đổi (offset-1 + 0x1030 = VA)
  objdump -D -M intel --start-address=0x2130 --stop-address=0x2164 vdk.so
  ```
- Client `vdk.dll` (5.049.856 B) = **UPX-packed** (section `UPX0`, `.boot`) ⇒ `strings` ra rác, **đừng mất thời gian tìm từ khoá**; chỉ so được md5 giữa các bản.

**Thành phần dòng Do Bao mà server bạn KHÔNG có (khai quật 17/09)** — pack `DOBAO … Update SIMBOT - VER 3 - MON PHAI KHONG BUON CHAN & CHATBOT` (07/08):
- `gateway/s3relay/simbot_client_bridge_server.py` (UDP **39036**, log `KSG_SimBotClientBridge.log`) nhận gói `CW1` (sự kiện) / `CW2` (kèm **item descriptor 27 trường số**) từ phía client → ghi `server1/data/simbot_world_event.txt`, `simbot_item_offers.txt`.
- `gateway/s3relay/libsimbot_whisper_spawn.so` (19 KB), `script/…/components/sim.whisper.spawn.lua` (54 KB), `data/simbot_{world_event,item_offers,exact_trade,whisper_request,whisper_response}.txt`, cài bằng **systemd unit** `simbot-client-bridge.service`
  ⇒ **WSL của bạn không có systemd ⇒ không bao giờ chạy**; server cũng **không có file nào** trong số này (đã kiểm: `grep whisper/bridge/simbot_item` = 0 kết quả).
- Đây là **CHATBOT + xin vật phẩm** (bridge tên "SimBot Client **ChatWorld** Bridge", khớp `JX1Mod.ini [ChatWorld]` ở client), **KHÔNG phải đường hiển thị quầy bày bán** ⇒ cài cũng không chữa lỗi click (và bản update 2 đã bỏ "xin vật phẩm từ Bot").

## ⛔ BÀI HỌC QUY TRÌNH: pack third-party KHÔNG đảm bảo `ORIGINAL-GỐC` = bản đang chạy

Ca thật 17/09: pack `NPC PLAYER HIỆN BANG` có `ORIGINAL-GỐC/` (baseline 04/07) nhưng server đã chạy **bản mới hơn ở 8 file**
(`config.lua`, `sim.core.lua`, `sim.entity.lua`, `sim.fight.lua`, `sim.fun.lua`, `sim.movement.lua`, `sim.timer.lua`, `ptongkim.lua`).
Ghi đè cả pack ⇒ **mất 24 dòng cấu hình riêng** (`THANHTHI_SIZE 600→300`, `CHANCE_CHAT 200→10`, `ENABLE_BANNGUAMIXDEV 1→0`, mất `BOT_STALL_PRICE_MULTIPLIER`,
cả cụm `LUYENCONG_*`/`PARTY_*`/`REST_*`/`LEVEL_*`/`SKILL_*`/`GEAR_*`/`BIKIP_LV2`) + tụt bản 7 file Lua.
Đã **hoàn nguyên 20/20 file** từ `/home/jxser/_backup_npcguard_20260917_220335` (script `/root/apply_price_shop_pack.sh revert`) và **bỏ `libs/guard.lua`**
⇒ guard NpcId **KHÔNG còn trên server** (chỉ giữ làm kiến thức). Lưu ý: guard dựa vào `SimCityBindNpcRef` gọi trong `sim.entity.lua` —
hoàn nguyên `sim.entity.lua` mà giữ 12 file guard khác ⇒ **mọi cờ Combat/Bang/xoá NPC bị chặn (fail-closed)** = bot thôi đánh nhau. Phải hoàn nguyên cả cụm.

**Quy tắc từ nay (trước khi ghi đè pack):** so **md5 3 chiều từng file** = bản đang chạy ↔ pack `ORIGINAL-GỐC` ↔ pack bản sửa; file nào lệch ⇒ **merge đúng hunk cần**, KHÔNG `cp -r` cả cây.
```bash
for f in $(cd PACK_ORIGINAL && find . -type f); do
  a=$(md5sum "PACK_ORIGINAL/$f"|cut -c1-8); b=$(md5sum "/home/jxser/${f#./}"|cut -c1-8)
  [ "$a" = "$b" ] || echo "LECH BAN: $f"; done
```

### Kinh nghiệm dùng lại được (chưng từ pack + điều tra 17/09)

- **`NpcIndex` bị engine TÁI DÙNG** sau khi NPC chết ⇒ timer/AI chỉ giữ index sẽ tác động nhầm NPC hoặc player mới (Bang/Camp/Combat/AI sai, xoá nhầm). Mẫu fix đúng: lưu `finalIndex` + `finalNpcId = GetNpcId(idx)` lúc spawn, trước mỗi tác động kiểm lại **id còn khớp** — **fail-closed** (thiếu API/lệch id ⇒ KHÔNG tác động, `DropNpcRef`).
- **Phân biệt player thật ↔ bot**: `NpcIdx2PIdx(idx) > 0` ⇒ là người chơi, không bao giờ coi là NPC bot.
- **Vị trí API engine** (đừng tìm sai chỗ): `GetNpcId`, `NpcIdx2PIdx`, `GetNpcKind`, `GetNpcSettingIdx`, `GetNpcParam` do **`server1/jx_linux_y`** cấp; `SetNpcStall`, `SetBotStallTier`, `PollTradeStay`, `TradeStayClear`, `SendTradeItem` do **`vdk.so`** (nạp qua `LD_PRELOAD`) cấp. `strings vdk.so` không thấy `GetNpcId` là **bình thường**, không phải thiếu API.
- **Đường bot bày bán (server)**: spawn data `stall = 1` (`plugins/pthanhthi.lua`) → `sim.entity.lua` gọi `SetNpcStall(idx,1)` + `SetBotStallTier(idx,0,1)` → mỗi 3s `SimCitizen:UpdateStallFlags` (gọi từ `plugins/pworld.lua`) gọi `SetNpcStall(finalIndex,1)`. Giá bot bán = `BOT_STALL_PRICE_MULTIPLIER` (`config.lua`, mặc định 100).
- **Máy trạng thái giao dịch** (`sim.core.lua`): `_ts = PollTradeStay(idx)`; `_ts == 2` ⇒ `SendTradeItem` (gửi hàng cho người xem), `_ts == 1/3/4` ⇒ `TradeStayClear`. Ép `_ts = 0` = huỷ mọi giao dịch ⇒ **không bao giờ làm**.

## 📦 Pack `DOBAO – Jx1 Offline – Update SIMBOT – VER 3 – MON PHAI KHONG BUON CHAN & CHATBOT` (07/08/2026)

**Kiểu pack:** ALL-IN-ONE "copy-only + REBOOT" (không cần terminal). Cấu trúc: `COPY_VAO_THU_MUC_GOC_SERVER/{etc,home}` → chép vào `/`.
Kèm 4 tài liệu: `HUONG_DAN_COPY_ONLY.txt`, `THONG_SO_SIMCITY.txt`, `ETC_DA_GOP.txt`, **`SHA256_MANIFEST.txt` (51 KB — sha256 mọi file, dùng để verify sau khi chép)**.
Đối chiếu với server hiện tại (17/09): **343 file — 17 MỚI, 14 KHÁC, 312 giống**.

**Chuỗi AUTOLOAD (ghi nhớ để chẩn đoán):**
```
systemd jxgame.service                     → /home/jxser/server1/jx_linux_y
  └─ drop-in jxgame.service.d/vdk.conf     → LD_PRELOAD=/home/jxser/server1/vdk.so   (module vdk)
ActivitySys 801 ServerStart
  └─ script/global/nobitaxd/vdk/main.lua   → simcity/main.lua → simcity/head.lua
       └─ mainLoop(): SimBotWhisperPoll() → SimCitizen:ATick() → SimTheoSau:ATick()   (mỗi REFRESH_RATE)
          worldLoop(): SimCityWorld:ATick(20)                                          (mỗi 3×REFRESH_RATE)
systemd jxs3relay.service (+ override)     → LD_PRELOAD=…/s3relay/libsimbot_whisper_spawn.so
systemd simbot-client-bridge.service       → python3 simbot_client_bridge_server.py  (UDP 39036)
```
⚠️ Server bạn dùng `boot_all.sh` (WSL **không có systemd**) ⇒ mọi thứ cài bằng unit systemd **không tự chạy** — muốn dùng phải port sang script boot.

**Số lượng bot/quầy của VER 3 (`THONG_SO_SIMCITY.txt` + `config.lua`) — bảng điều khiển SỐ QUẦY BÁN:**
| Khu | Bot | Quầy (shop) |
|---|---|---|
| Thành thị (7) | 500 | thường **133–192**, dã tẩu **30–45** |
| Thôn (8) | 50 | thường **29–43**, dã tẩu **22–33** |
| Môn phái | 350 luyện công (150 solo + 200 vào 35 party) | **52** |
| Map luyện công | 70 | — |
Biến trong `config.lua`: `THANHTHI_STALL_NORMAL_MIN/MAX`, `THANHTHI_STALL_DATAU_MIN/MAX`, `THON_STALL_NORMAL_MIN/MAX`, `THON_STALL_DATAU_MIN/MAX`, `MONPHAI_STALL_SIZE`, `MONPHAI_TRAIN_SIZE/SOLO_SIZE/PARTY_COUNT`, `LUYENCONG_SIZE/SOLO_SIZE/PARTY_COUNT`.
`plugins/pthanhthi.lua` đọc biến kèm fallback (`random(THANHTHI_STALL_NORMAL_MIN or 68, …MAX or 98)`) ⇒ **đổi số quầy bot chỉ cần sửa config**, không phải build lại module.
(bản server bạn: `pthanhthi.lua` cũ hơn, hard-code `random(45,65)`/`random(20,30)`, **không** dùng biến `STALL_*`.)

**Subsystem CHATBOT / WHISPER (mới hoàn toàn so với server bạn):**
- `script/.../components/sim.whisper.spawn.lua` (54 KB, "SimBot Whisper Spawn Bridge Build 0.2", include từ `head.lua`) — API: `SimBotWhisperPoll/TakeRequest/WriteResponse/ClassifyInbox/RenderRuleReply/ApplyIntentToSession/ValidateOfferDescriptor/LoadItemOffer/AttachTradeOffer/WriteExactTradeRequest/ConsumeWorldEvents/LoadStaticCenters/LoadInboxRules`.
- `settings/global/vdk/simcity/simbot_inbox_rules.txt` (**TCVN3**) — cột: `RuleId⇥IntentCode⇥IntentName⇥ActionCode⇥MatchMode(exact|contains|default)⇥UserInbox⇥FirstReply⇥WaitingReply⇥BusyReply`.
- `settings/global/vdk/simcity/simbot_social_centers.txt` — cột: `Category⇥WorldId⇥Label⇥SpawnX⇥SpawnY⇥NpcCount⇥Ref1X⇥Ref1Y⇥Ref2X⇥Ref2Y⇥Source` (vd `city 1 city_1_1 1603 3216 9 …`) ⇒ **bot được spawn/mời tới chỗ người chơi đang chat**.
- `data/simbot_{whisper_request,whisper_response,world_event,item_offers,exact_trade}.txt` — file đệm do cầu UDP ghi/đọc (trong pack = rỗng 0 B, tự sinh khi chạy).
- Nhánh giao dịch trong `sim.core.lua` (VER 3): khi `tbNpc.whisperActionCode == "TRADE"` → `SimBotWhisperWriteExactTradeRequest(tbNpc)` (ghi `simbot_exact_trade.txt`) → `SendTradeItem(idx)`, có guard `whisperExactTradeGiven`, log `EXACT_TRADE_BLOCKED_NO_OFFER Build=0.3.9` → tức **"xin vật phẩm từ bot" = người chơi WHISPER con bot, bot trao ĐÚNG món** (khác hẳn "bày bán").
- `libsimbot_whisper_spawn.so` (19 KB, gateway/s3relay) + `simbot_client_bridge_server.py` (UDP 39036, gói `CW1`/`CW2`) — xem mục cầu client ở trên.

**Module `vdk.so` bản VER 3 = `13dd384e9bc3c1a5a7494de8095530ae`** (07/08) so với bản đang chạy `d364ec69…` (27/07) và `_goc 40420c2c…` (04/07):
cùng 54.229 B, **`.rodata` GIỐNG HỆT, `.text` chỉ khác 4 byte** ⇒ module gần như y hệt; khác biệt VER 3 nằm ở **Lua**, không ở module.

## ⏸️ TRẠNG THÁI LỖI QUẦY BOT (17/09/2026): **ĐỂ NGÕ — CHƯA RÕ NGUYÊN NHÂN**

Đã loại trừ **tất cả** các hướng sau (đừng thử lại, mất thời gian):

| # | Phép thử | Kết quả |
|---|---|---|
| 1 | Copy đủ 6 cửa sổ `摆摊*` + `npc买卖界面` + sprite vào `ui/ctc` (cả tên mojibake lẫn Unicode) | ✗ |
| 2 | Quét `ui.pak` (266MB) xem có sẵn cửa sổ cho theme ctc | ✗ (không có, nhưng cũng không phải nguyên nhân) |
| 3 | Đổi `vdk.so` ↔ `vdk.so_goc` + restart | ✗ |
| 4 | Comment khối `if _ts > 0 … _ts = 0` trong `sim.core.lua` | ✗ |
| 5 | So Lua server ↔ 2 pack update 28/08 | trùng md5 (đã update đủ) |
| 6 | Áp pack `NPC PLAYER HIỆN BANG` (guard NpcId + bỏ khối `_ts`) | ✗ (đã **HOÀN NGUYÊN** 17/09 22:27 — pack dựa baseline cũ, ghi đè 8 file mới hơn) |
| 7 | Tắt hook client `EquipmentCompare=0` / `[OneDLL] Enabled=0` | ✗ |
| 8 | Đổi giá quầy bot `BOT_STALL_PRICE_MULTIPLIER` 100 → 15 (theo pack Do Bao) + `vdk.so` của pack (đã là bản đang chạy) | ✗ (không hiện đồ) |
| 9 | **Cắm log `PollTradeStay` trong `SimCore:OnTimer`** (`sim.core.lua`, in khi `_ts ~= 0`) → chủ server đăng nhập, bấm vào bot đứng bán nhiều lần | **0 dòng log** ⇒ cú bấm **không** tạo trạng thái trade-stay cho bot |

### ✅ Kết luận từ phép thử #9 (17/09/2026, đo thật)

Log đặt tại đúng dòng `local _ts = … PollTradeStay(tbNpc.finalIndex) … 0` trong `SimCore:OnTimer` (hàm tick mỗi bot).
Chủ server online + bấm bot nhiều lần ⇒ **không lần nào `_ts` khác 0**. Vì `OnTimer` chạy cho mọi bot mỗi tick, nếu cú bấm có tới được nhánh quầy thì `_ts` **phải** khác 0 ⇒

1. Hoặc **client không gửi** yêu cầu mở quầy cho NPC-bot, hoặc
2. **engine không gắn cú bấm với bot đó** (không coi NPC là quầy) — cả hai đều nằm ở **cặp module `vdk.so` (server) ↔ `vdk.dll` (client)**, KHÔNG nằm ở Lua simbot.

⇒ Mọi thay đổi trong `simcity/**` (Lua) **không thể** sửa lỗi này. Đường còn lại duy nhất: tác giả mod / cặp module khác.
**Phép thử còn giữ được để phân biệt (a) và (b):** cần **2 tài khoản online** — A cắm quầy người thật, B bấm vào quầy đó, cùng lúc cắm log `PollTradeStay` (nếu quầy người thật cũng ra `_ts = 0` thì `PollTradeStay` là **sai chỗ đo**, phải tìm API khác).
**Bài học quy trình:** log chèn vào file Lua server phải là **cú pháp Lua 4** — dùng `mod(a,b)`, KHÔNG dùng `%`; luôn `luajit -bl <file> /dev/null` trước khi restart (17/09 đã tự bắn vào chân: `%` ⇒ `sim_citizen.lua` không nạp ⇒ `SimCitizen = nil` ⇒ mất sạch bot).

**Bằng chứng tách hướng (mạnh nhất, vẫn đúng):** quầy **người thật mở được**, quầy **bot không** ⇒ lỗi ở nhánh bot, không phải engine client chung.
**Hướng còn lại chưa thử:** (a) hỏi tác giả mod (link Facebook trong `SV/_Thông tin.docx`); (b) chạy client cũ `SV/Client/game.exe` (09/06, md5 `e652eeea…`) với server hiện tại để A/B bản client; (c) chấp nhận bot đứng bán chỉ để làm cảnh.
⛔ KHÔNG kết luận bằng ghi chú docx của pack update ("Bỏ chức năng xin vật phẩm từ Bot") — user đã bác: **xin vật phẩm ≠ bày bán**.
- Script áp: `/root/apply_npc_guard.sh check|apply|revert`; backup `/home/jxser/_backup_npcguard_20260917_220335`.

**⛔ BẪY RESTART SERVER (tốn thời gian 17/09):** `<PORTABLE_DIR>/panel_restart.sh` **CHỈ restart WEB PANEL (:80)**, KHÔNG đụng service game.
Muốn nạp lại script Lua server:
```bash
pkill -x jx_linux_y; sleep 2; bash <PORTABLE_DIR>/boot_all.sh /home/jxser   # start lại cái thiếu (idempotent)
```
(`boot_all.sh` chạy game server bằng `setsid env LD_PRELOAD=./vdk.so ./jx_linux_y` trong `server1/`.)
Kiểm tra đã restart thật: `ps -o lstart -p $(pgrep -x jx_linux_y)` — phải khớp giờ vừa restart.
Log Lua `print(...)` của server → `server1/Logs/KSG_ScriptOutputLog_<ngày>.txt` (KHÔNG phải `logs/gameserver.log`).
`UpdateStallFlags` chỉ chạy theo tick thế giới (`pworld.lua` OnTimer) ⇒ **cần người chơi online** mới thấy log.

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

## ⛔ ĐÃ THỬ HẾT — KẾT LUẬN 17/09/2026: tính năng "bấm bot đứng bán để xem/mua hàng" KHÔNG có trong bản mod hiện tại

Bảng 4 phép thử đã làm (tất cả đều **KHÔNG sửa được lỗi** — đừng thử lại):

| # | Phép thử | Kết quả |
|---|---|---|
| 1 | Copy đủ 6 cửa sổ `摆摊*`/`npc买卖界面` + 9 sprite vào `ui/ctc` (cả tên mojibake lẫn Unicode) | ✗ không mở |
| 2 | Đổi `vdk.so` sang bản `_goc` (04/07) + restart | ✗ không mở (⇒ không phải bản `.so`) |
| 3 | Comment khối `if _ts > 0 then … _ts = 0 end` trong `sim.core.lua` (= về đúng hành vi `_goc`) + restart | ✗ không mở (⇒ nhánh giao dịch chưa từng chạy: `PollTradeStay` luôn = 0 cho bot) |
| 4 | Đối chiếu Lua server vs pack update 2 | trùng md5 (server đã update đủ) |

**Phép thử tách hướng (chủ server làm):** quầy **người chơi thật MỞ ĐƯỢC**, quầy **bot KHÔNG** ⇒ engine client + bản `.so` đều ổn;
thiếu **cầu nối "click bot → mở giao dịch/bày hàng"**, và cầu nối đó **không nằm trong Lua** (client lẫn server Lua đều không có
code mở cửa sổ khi click) ⇒ phải nằm trong module `vdk` (client `vdk.dll` + server `vdk.so`).

⛔ **SAI — đừng dùng lập luận này:** `_Thông tin update 2.docx` có ghi *"Bỏ chức năng xin vật phẩm từ Bot"*, nhưng
**"xin vật phẩm từ bot" ≠ "bot bày bán/đứng bán"** (chủ server đã đính chính 17/09) — đó là 2 chức năng khác nhau, KHÔNG liên quan
đến lỗi click bot đứng bán. Đừng lấy ghi chú đó làm bằng chứng.
(`vdk.dll` 5.049.856 B, 21/08/2026, md5 `52ab92ef…`; `game.exe` 21/08 cùng mtime ⇒ cặp client cùng đợt update.)

**Việc nên làm tiếp (không phải mò code nữa):**
1. Hỏi tác giả mod (link Facebook trong `_Thông tin.docx`) xem bản hiện tại còn hỗ trợ bấm bot để xem/mua đồ không, và nếu bỏ thì
   bật lại thế nào.
2. Nếu muốn tính năng: thử bộ client/server **trước update 2** (bản `update lan 1` / client cũ trong `SV/Client` — `game.exe` 09/06
   md5 `e652eeea…`) trên môi trường test riêng.
3. Chấp nhận: bot chỉ để làm cảnh; muốn mua/bán với bot thì dùng cơ chế khác (nếu tác giả có).

## 🎯 NGHI PHẠM ĐÃ LOẠI (giữ để tham chiếu): khối `_ts > 0` trong `sim.core.lua`

Trong **file đang chạy** `server1/script/global/nobitaxd/vdk/simcity/components/sim.core.lua` (16/08/2026, md5 `4f08c10e0a0f736b515303c49cdd61ec`)
có một khối **KHÔNG có trong bản gốc** `sim.core.lua_goc` (04/07/2026, md5 khác) — chèn ngay sau dòng `PollTradeStay`:

```lua
local _ts = (PollTradeStay and ...) and PollTradeStay(tbNpc.finalIndex) or 0
if _ts > 0 then                      -- <<< khối thêm vào (dòng 862-876)
    if TradeStayClear then TradeStayClear(tbNpc.finalIndex) end
    tbNpc.tradeStayDeadline = nil ... tbNpc.tradeItemAt = nil
    _ts = 0                          -- <<< ÉP VỀ 0: huỷ tương tác ngay lập tức
end
if _ts == 2 then ... (nhánh gửi hàng SendTradeItem)
```

⇒ Mỗi khi engine báo "đang có người giao dịch/bày hàng với bot" (`PollTradeStay > 0`), code **xoá trạng thái + ép `_ts = 0`**
⇒ nhánh `_ts == 2` (gửi hàng cho người chơi) **không bao giờ chạy** ⇒ **bấm vào bot đứng bán không hiện gì**.

**Khớp 100% với thực nghiệm:** quầy **người chơi thật mở được**, quầy **bot thì không** (17/09) — lỗi nằm ở nhánh bot,
không phải engine client (`vdk.dll`) và không phải bản `vdk.so`.

**Vì sao khối đó được thêm:** chắc để chữa "bot kẹt đứng bán" (state 1/2 treo). Nhưng code GỐC **đã có timeout** rồi
(`tradeStayDeadline` 38s, `tradeStayBye` 10s, `tradePostUntil` 27s ở các nhánh `_ts==1/2/3`) ⇒ khối này là **thừa và phá tính năng**.

**Cách test (script đã để sẵn trên server, chưa chạy):** `/root/fix_bot_stall_test.sh apply` (backup + comment khối 862-876 + restart `jx_linux_y`)
→ vào game bấm bot; `revert` để trả lại. Sau khi xác nhận, nên viết lại khối đó **chỉ clear khi bot cần rời chỗ** (thay vì cắt mọi giao dịch).

**⇒ Nếu test này vẫn không được, còn lại nghi vấn phía CLIENT:**
1. `game.exe` có 2 bản khác md5: `SV/Client/game.exe` **09/06/2026** (`e652eeea…`) vs bản đang chạy **21/08/2026** (`d48a6d19…`).
   Cả 2 bản đều có chuỗi `摆摊`/`摆摊物品`/`买卖` + `OpenShop`/`Stall` (đếm bằng nhau) ⇒ khác biệt không nằm ở tên cửa sổ.
   Test rẻ: backup `Client/game.exe` → chép bản 09/06 vào → tắt/mở client → click bot (1 file, đảo ngược được).
2. Test tách CLIENT vs BOT: nhờ người chơi thật dựng quầy (acc thứ 2) → nếu quầy **người thật mở được** mà quầy **bot không**
   ⇒ lỗi ở nhánh bot (server/giao dịch bot), không phải client engine; nếu cả hai đều không mở ⇒ lỗi client engine.
3. `vdk.dll` chỉ có 1 phiên bản trên toàn máy (md5 `52ab92ef…`, cả `SV/Client`, `UI/`, `Client/`) ⇒ không có bản khác để A/B.
4. Muốn có cặp đúng bản: hỏi nhà phát hành mod (bản update 28/08 chỉ kèm Lua, KHÔNG kèm binary).