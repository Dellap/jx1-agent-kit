# Bảng nhiệm vụ (Task Trace) trong cửa sổ `battle_select` — layout chuẩn + quy trình lưu/rollback

> ⚠️ Mọi đường dẫn tuyệt đối trong file này là **ví dụ của một máy cụ thể** (`<GAME_ROOT>`, `<WORK_DIR>`, `<DRIVE>:` …). Máy khác hãy tự xác định *game root* = thư mục cha của `Client/`.


Chốt 17/09/2026. Client: `<GAME_ROOT>\Client` (theme **CTC**, chạy 1600x900 theo `Client/resolution.ini`).

## 1. Cửa sổ `battle_select` — control nào engine VẼ ĐƯỢC

Engine biết **đúng** các section sau (thêm section/control mới → bỏ qua hoàn toàn):
`[Main]` `[btn_close]` `[btn_prevpage]` `[btn_nextpage]` `[info_1]` `[info_2]` `[info_3]` `[info_4]` `[scroll_bar]` `[scroll_bar_Btn]` `[btnShop]`

- **`btn_close` là control DUY NHẤT mà bấm vào engine tự đóng cửa sổ.** ⇒ Muốn có "tiêu đề bấm không mất bảng"
  thì tiêu đề phải nằm ở **ô chữ (`info_*`) hoặc nút page**, không thể ở `btn_close`.
- Control **không có `Image=` vẫn vẽ `Label=`** (đã kiểm thực tế: dải tiêu đề chỉ có Label vẫn hiện).
- Click `btn_prevpage`/`btn_nextpage` → gọi `prev_page()/next_page()` trong `script/tasktrace/ui.lua` (gửi protocol op 2/op 3).
  Click lên ô info (danh sách) → `on_select(nId)`.
- **KHÔNG có control "thu gọn/minimize"** cho cửa sổ này (đã rà cả file loose + trong pak) ⇒ đừng hứa với user là
  làm được collapse; chỉ có 2 lựa chọn thật: (a) kéo khung đi chỗ khác nhờ `Moveable=1`, (b) ẩn bằng nút X rồi mở lại
  (đăng nhập lại, hoặc nhặt bản đồ — server có hook `open_task_trace()` trong `script/item/tasklink_goods*.lua`).

## 2. Layout CHỐT (ini `battle_select.ini` md5 `60b64d14ce51c24aca4ef0db6d6beb2d`)

```
[Main]         Left=1350 Top=150 Width=180 Height=220  Moveable=1
               Image=\spr\Ui4\主界面\任务指南资源\任务追踪底板.spr   (spr 180x220, single frame)
               ScriptFile=\script\tasktrace\ui.lua
[info_2]       Left=8   Top=6   150x22  Image=...\info_gray.spr   → Ô TIÊU ĐỀ (chữ do ui.lua ghi)
[btn_close]    Left=164 Top=2    14x14  Label=X                    → nút đóng thật (bấm mới ẩn)
[info_1]       Left=10  Top=35  160x80  Image=...\info_gray.spr    → nội dung nhiệm vụ
[btn_prevpage] Left=15  Top=195  67x23  Image=\Spr\UI3\arena\btnPage.spr  Label="Nhiệm Vụ"
[btn_nextpage] Left=103 Top=195  67x23  Image=...\btnPage.spr              Label="Đổi Camp"
[info_3]       Left=23  Top=247 218x71  Image=...\info.spr   (nằm dưới khung — giữ theo mod)
[info_4]       Left=23  Top=331 218x71  Image=...\info.spr
[scroll_bar] [scroll_bar_Btn] [btnShop] giữ nguyên khối gốc.
```

**Chữ tiêu đề** = sửa 1 dòng trong `script/tasktrace/ui.lua` (tham số 2 của `PushInfo` chính là `info_2`):

```lua
self:PushInfo(szInfo1, "Nhiệm vụ (TCVN3)", "", "", id1)   -- gốc: self:PushInfo(szInfo1, "", "", "", id1)
```

Backup bản gốc: `Update\_backup_client_truoc_readme_*\ui.lua.goc_mod`.

## 3. Cái KHÔNG thể (đừng thử lại — đã trả giá)

- Chèn `pcall` vào bất kỳ script client nào → engine Lua đời cũ không có `pcall`, script **chết im lặng** ngay dòng đó
  (xem `vltk-client-modding`). Đây chính là thứ làm mod "không hiện" suốt 17/09 dù protocol đã tới đúng chỗ.
- Đặt tiêu đề vào `btn_close` rồi mong "bấm không mất bảng": engine đóng cửa sổ là hành vi cứng.
- Thêm section/control mới vào ini (kể cả có ảnh + Label) → engine bỏ qua.
- Chỉ đưa **1** ô info vào khung ⇒ user chỉ thấy 1 dòng chữ ("không hiện hết UI"). Muốn "đầy đủ" phải có mặt đủ
  `info_1..4` + 2 nút page + close + scroll (kiểm bằng script, assert không thiếu section nào).

## 4. Spr KHÔNG tồn tại trong client (ini gốc client trỏ tới — nút đã chết từ trước)

`\Spr\update\vongquay.spr`, `\Spr\update\pet.spr`, `\Spr\update\kynangsong.spr` — **không có loose, không có trong bất kỳ pak**
(đã probe từng pak) ⇒ nút Vòng Quay / Pet / Kỹ Năng Sống **vốn đã không hiển thị**, không phải do mod nhiệm vụ.
⇒ Khi user báo "thiếu nút", luôn probe sprite trước khi đổ lỗi cho thay đổi của mình.

## 5. Quy trình lưu bản tốt + ROLLBACK (đã dùng, user xác nhận hài lòng)

1. **Lưu bản đang chạy tốt**: `Update\_SAVE_<mod>_<ts>\client\...` (protocol.lua, `script/<mod>/`, ini, spr, `ui/ui3/`) +
   `md5.txt` (`find . -type f -exec md5sum {} \; | sort -k2`) + `restore_working.sh` (copy ngược đúng đường dẫn).
2. **Rollback**: copy lại từ `Update\_backup_client_truoc_<mod>_<ts>\` (vd `protocol.lua.bak`, `battle_select.ini.tu_pak`),
   và **`mv`** (KHÔNG `rm`) mọi file mod đã thêm vào `_SAVE.../removed_*`.
   ⚠️ `mv` vào thư mục chưa `mkdir` → lỗi `Not a directory` nhưng `echo` vẫn chạy ⇒ luôn kiểm lại file còn sót.
3. **Verify sau mỗi bước bằng md5** (in bảng ✅/❌) — đây là thứ khiến user tin. Rollback đạt = md5 client **khớp bản gốc**
   + `grep -c 'TaskTrace:OpenUI' protocol.lua` = 0.
4. **Trả cả server** nếu đã đụng: backup ở `_backup_server_truoc_<mod>_<ts>\` trên share → đẩy vào server bằng
   `ssh jx1 'cat <bak>' > /tmp/x` rồi `ssh -p 2222 root@<GAME_HOST_IP> 'cat > /path'` (WSL2 không đọc /mnt/e ổn định).
   Server `<GAME_HOST_IP>` KHÔNG cần restart khi nội dung 2 bản tương đương.
5. Rollback sạch xong mới được khẳng định "lỗi có từ trước": test tính năng khác rồi kết luận.
   Ca này: **shop xem hàng rao bán của SimBot lỗi sẵn có, không liên quan mod nhiệm vụ** (user tự xác nhận sau rollback).

## 6. Vị trí / toạ độ

- Toạ độ ini tính theo độ phân giải client (1600x900), không phải màn hình vật lý 1920x1080 của user.
- `Client/JX1Mod.ini` có `[AutoUILayout]` (tự canh giữa thanh máu Boss/NPC/PK + ghim LienTram sát phải) = cơ chế
  "chỉnh UI theo độ phân giải" có sẵn của client; **chỉ** hỗ trợ các phần tử đó, không nhận cửa sổ tuỳ ý.
- Dời khung: đổi `[Main] Left/Top` rồi **dịch bù `Left/Top` của MỌI child khác** để vị trí tuyệt đối không đổi
  (`abs = Main + rel`). Kiểm bằng script: in bảng "gốc vs sau khi sửa" và fail nếu lệch 1 px.
