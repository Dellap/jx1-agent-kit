# Mod "Theo dõi nhiệm vụ" (TaskTrace) trên client CTC — ca 17/09/2026 (đầy đủ)

Ghi lại nguyên văn ca khó nhất: mod Task Trace không hiện suốt buổi vì **3 nguyên nhân xếp chồng**,
tất cả đều do thao tác mod, không phải mod hỏng.

## Mod nằm ở đâu (nguồn)

`Update\Theo_doi_nhiem_vu\` (share `VoLamTruyenKy` trên PC <GAME_HOST_IP>):
`1_client/{1_ui/ui3/battle/{battle_select.ini,battle_select_origin.ini},2_spr/{ui3/battle/info_gray.spr,Ui4/主界面/任务指南资源/任务追踪底板.spr},3_script/{protocol.lua,tasktrace/{ui.lua,task_random.lua,task_messenger.lua}}}`,
`2_server/script/{tasktrace/{tasktrace.lua,protocol_gs.lua},…}`, `README.txt` (TCVN3).

README (dịch): client → chép `/ui/`, `/spr/`, `/script/tasktrace/`; **bước 2: chép protocol mới VÀO
`protocol.lua`, đừng copy file**. Server → copy `/script/tasktrace/`, các script còn lại **chép nội dung
vào file có sẵn, tuyệt đối không copy trực tiếp**.

**4 file trong `2_server/` chỉ là ghi chú** (`protocol.lua`, `script_protocol/protocol_def_gs.lua`,
`global/login.lua`, `global/seasonnpc.lua` — mỗi file 7–12 dòng kiểu "Add vao script: Include(...)").
Copy đè = **mất danh sách protocol + login.lua của server**. Server <GAME_HOST_IP> đã có sẵn đủ (md5 khớp mod cho
`script/tasktrace/*`; hook ở `login.lua:26,143`, `seasonnpc.lua:15,345-346`, `item/tasklink_goods*.lua:10,65-66`,
`protocol_def_gs.lua:75`).

## 3 nguyên nhân làm mod không hiện (theo thứ tự phát hiện)

1. **Chèn Def sai vị trí trong `protocol.lua`** → `{"emSCRIPT_PROTOCOL_TASKTRACE",…}` nằm NGOÀI bảng `Def`
   (sau dòng `}` đóng bảng) → file Lua lỗi cú pháp → cả hệ protocol của client không nạp.
   Kiểm bằng `luajit -bl file.lua /dev/null` (luajit: `brew install luajit`).
2. **Bọc `pcall` vào script client** → engine Lua đời cũ **không có `pcall`** (có `getn`, `tinsert`,
   `format`, `mod`) → script dừng IM LẶNG ngay tại dòng đó. Đây là thứ phá mod dai dẳng nhất: log cho thấy
   `RX id=17 … hasHandler=1` rồi đứt ở dòng tiếp theo. Xem `references/` của SKILL.md phần "Chẩn đoán protocol".
3. **Sửa "bảng enum cho khớp server" bằng cách so sai file** → so `KE_SCRIPT_PROTOCOL` của client với danh
   sách handler trong `protocol_def_gs.lua` (KHÔNG phải bảng số) → thấy "lệch 12 vs 17" → sắp lại → phá mod.
   Sự thật: bảng số nằm ở `script/protocol.lua` **dùng chung cho cả client và server**, hai bên y hệt nhau,
   TASKTRACE = **#17** (log chứng minh: server gửi EXPRANK_STRING = 19 khớp, và gửi 17 cho TASKTRACE).

## Layout cửa sổ `battle_select` — KHÔNG đè ini gốc của client

`ui/ctc/battle/battle_select.ini` (1975B, bản trong `ui.pak`) là **cửa sổ neo tùy biến** của bạn:
`btn_prevpage` = Hệ Thống Pet, `btn_nextpage` = Kỹ Năng Sống, `btnShop` = Vòng Quay (spr `\Spr\update\`),
`info_1..info_4` đặt **Left âm** để neo vùng khác của màn hình (thông báo PK Tống Kim / PK thường /
icon lientram / khung màu quái), `ScriptFile` **đã trỏ sẵn** `\script\tasktrace\ui.lua` (client đã chuẩn bị
cho mod). Ini của mod (`1_ui/ui3/battle/battle_select.ini`) là layout 10 section: `Main`(180x220, Image=底板),
`btn_close`, `btn_prevpage`(Label "Nhiệm Vụ"), `btn_nextpage`(Label "Đổi Camp"), `info_1..4`
(`info_gray.spr` 160x71 / `info.spr` 218x71), `scroll_bar`, `scroll_bar_Btn`.

Hệ quả thật khi đè bằng ini mod (`info` ở 10,35 / 10,120 / 23,247 / 23,331):
bảng nhiệm vụ dồn ra **giữa màn hình**, mất 3 nút, và **shop động SimBot không hiện vật phẩm**.

**Luật rút ra**: chỉ cần `script/tasktrace/*` + protocol + `ScriptFile` (đã có sẵn) — ini gốc giữ nguyên.
Muốn panel hiện ở chỗ khác thì **merge**, đừng đè.

## Toạ độ: `abs = [Main].Left + [child].Left`

- Child nằm **ngoài** khung `[Main]` ⇒ engine không vẽ ⇒ chữ nhiệm vụ "không hiện" (info_1 ở -630,-100).
  Đưa child vào trong khung (như mod: 10,35 …) là hiện.
- Muốn **dời khung** mà giữ nguyên vị trí tuyệt đối của các child khác (3 nút, vùng neo):
  `child.rel_new = child.rel_old − delta` với `delta = Main_new − Main_old`. Viết script rồi **assert**
  `Main_new.Left + child.rel_new == Main_old.Left + child.rel_old` cho TỪNG child — sai 1 pixel là fail.
- Panel của mod trải rộng hơn khung: `info_3/info_4` nằm **dưới** khối `Main` (Top 247/331 với Main cao 220)
  và rộng 218 > 180 ⇒ đặt `Main.Left ≤ 1600−218−10 = 1372` để không tràn mép phải màn 1600x900.

## Môi trường & state hiện tại (17/09/2026, tối)

- `.ini` client là **GBK**, nhưng có bytes **không phải GBK** (comment tiếng Việt) ⇒ `decode('gbk')` **nổ**.
  Cách đúng: đọc/ghi bằng **latin-1** (byte-preserving), chỉ encode GBK cho phần tên tiếng Trung mình chèn
  (`'\\spr\\Ui4\\主界面\\…'.encode('gbk').decode('latin-1')`), ghi lại `encode('latin-1')`. Giữ CRLF.
- `re.sub(pattern, 'Image='+IMG, …)` **lỗi `bad escape \s`** khi repl chứa backslash ⇒ dùng `lambda m: …`.
- Client: `Client/config.ini` `Theme=CTC`; `resolution.ini` `Width=1600 Height=900`; màn bạn 1920x1080
  (chưa chốt toạ độ theo 1920). Tool unpack: `Tools/unpacktool/unpack.exe -i <pak> -p <path> -o <dir tương đối>`.
- Spr hợp lệ phải **single frame** (field 8–11 = 0): 底板 180x220 ✓, info_gray 160x71 ✓, info 218x71 ✓.
- Bản ĐANG CHẠY (verify lại 17/09/2026 tối, đọc trực tiếp client): `battle_select.ini` md5 **`60b64d14ce51c24aca4ef0db6d6beb2d`**,
  `Main` ở **(1350,150)**, `Width/Height=180x220`, `Moveable=1`, `Image=\spr\Ui4\主界面\任务指南资源\任务追踪底板.spr`;
  `script/protocol.lua` md5 **`c6f4b2628a58b1730311c03dad072b82`**, `script/tasktrace/ui.lua` md5 **`bf3e3cd59aa732bfa4fedf664b519bc1`**
  (`config.ini: Theme=CTC`, `resolution.ini: 1600x900`). ⚠️ md5 cũ `7d00fae1…` trong bản ghi trước là **bản đã bị thay** —
  đối chiếu lại trước khi tin bất kỳ số md5 nào trong tài liệu này.
  Backup để rollback: `Update\_backup_client_truoc_tasktrace_20260917_1800\battle_select.ini.tu_pak` (ini gốc client),
  `…\_backup_client_truoc_readme_20260917_1841\`, và bản chạy tốt `Update\_SAVE_tasktrace_working_20260917_1930\` (+`restore_working.sh`).
- **Đã chốt**: vị trí panel = `Main` (1350,150) (giữ nguyên từ 17/09).
- **Còn mở**: Pet/Kỹ Năng Sống trùng tên section `btn_prevpage/btn_nextpage` với 2 nút của mod ⇒ không cùng tồn tại.
- ✅ **"Shop SimBot không hiện đồ" KHÔNG liên quan mod này** (đã trả giá kiểm tra: rollback mod vẫn lỗi) — lỗi nằm ở cặp module
  `vdk.so`/`vdk.dll`, trạng thái **để ngõ**: xem `jx1-simbot/references/packs-and-stall-shop.md` (đọc trước khi thử lại).

## Script kèm (chạy lại được)

- `~/.hermes/scripts/jx1_build_full_panel.py` — dựng ini layout mod + `[btnShop]`, dời `Main`, in bảng
  `rel/abs` từng section và **exit 1 nếu thiếu section**.
- `~/.hermes/scripts/jx1_merge_battleselect.py` — merge kiểu cũ (giữ ini client, chỉ đưa `info_1` vào khung)
  — giữ lại làm ví dụ toán `delta` + assert vị trí tuyệt đối.
- `~/.hermes/scripts/jx1_proto_log.py` / `jx1_proto_debug.py` — gắn log chẩn đoán vào `script/protocol.lua`
  (bản `log-only` KHÔNG pcall là bản dùng được; bản `debug` dùng pcall chỉ để tham khảo, gây đứt script).
