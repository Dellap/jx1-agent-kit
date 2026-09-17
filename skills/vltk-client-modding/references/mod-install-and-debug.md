# Cài mod vào client/server JX1 + debug khi user báo "không thấy gì"

Rút ra từ ca cài mod **"Theo dõi nhiệm vụ" (task trace)** ngày 17/09/2026 — trong đó trợ lý báo "đã cài xong"
nhưng bạn vào game không thấy bảng, và lỗi thật là **1 dòng chèn sai vị trí làm hỏng cả file Lua**.

## 1. Sửa script client `.lua` — LUÔN kiểm cú pháp trước khi báo "xong"

- Client Lua **KHÔNG phải Lua 5.1 chuẩn** — là bản engine lai đời cũ (`getn`/`tinsert`/`format` global,
  `for key,v in tbl do`; nghi **không có `pcall`**). Dùng `luajit -bl <file> /dev/null` **chỉ để kiểm CÚ PHÁP**
  (`brew install luajit`); im lặng = parse OK. Check **trước khi đẩy** và **sau khi đẩy** (pull về check lại).
  ⛔ Vì dialect khác 5.1 nên **đừng bọc `pcall` trong script client** — xem mục 2.
- **Chèn entry vào bảng `Def` của `script/protocol.lua` phải nằm TRONG bảng** — chèn ngay TRƯỚC dòng đóng `\t}` của bảng,
  **KHÔNG** chèn trước `ScriptProtocol:RegProtocolSet(Def)` (giữa 2 dòng đó là `}` đóng bảng ⇒ entry rơi ra ngoài).
  Chèn sai ⇒ `unexpected symbol near '{'` ⇒ **file lỗi cú pháp ⇒ TOÀN BỘ bảng protocol client không reg** (mọi tính năng
  protocol chết im lặng, không riêng cái mình thêm). Triệu chứng user báo chỉ là "vào game không thấy bảng X".
- Cách sửa an toàn: dựng lại từ bản backup gốc + `raw.rfind(b'\n\t}\n\tScriptProtocol:RegProtocolSet(Def)')` để tìm đúng
  dòng đóng bảng rồi chèn, check luajit, push, so md5. **Đừng chèn theo "trước RegProtocolSet"**.
- Client script **loose thắng pak** (bằng chứng: `emSCRIPT_PROTOCOL_EXPRANK` chỉ có trong loose `script/protocol.lua`, mà
  `Client/Logs/expranking.txt` vẫn được ghi bởi `script/ui/ranking.lua`) ⇒ sửa loose là đủ, **không phải đóng gói lại pak**.

## 2. Chẩn đoán khi user báo "không thấy gì" (không đoán mò)

Client không có log sẵn ⇒ **tự gắn log trong script** rồi nhờ user vào game đúng 1 lần:

```lua
local f = openfile(".\\logs\\tasktrace.txt", "a")       -- Client\Logs có sẵn
if f then write(f, msg .. "\r\n"); closefile(f) end
if Msg2Player then Msg2Player("[Debug] " .. msg) end    -- Msg2Player dùng được ở CLIENT → hiện thẳng trong game
```

- Log `type(<TenHamNative>)` để biết hàm engine có tồn tại (an toàn, chỉ đọc).
  ⛔ **KHÔNG bọc lời gọi native trong `pcall`** — 17/09/2026 làm đúng vậy và **script dừng im lặng ngay tại dòng
  `pcall(OpenBattleSelect)`**: log cụt đúng sau dòng `type: OpenBattleSelect=function …`, không log, không popup,
  client vẫn chạy bình thường ⇒ suýt kết luận sai là "engine crash". Đúng ra phải **kẹp log trước/sau** lời gọi
  (`CALL` … `CALL-DONE`) và giữ nguyên code gọi handler — xem `scripts/instrument-client-protocol.py`.
  Muốn biết dialect thì log `tostring(pcall)` / `tostring(call)` / `tostring(getn)`, đừng gọi.
  Cây đọc log: không `LOOSE loaded` = client đang dùng bản trong pak; `hasHandler=nil` = lệch số/thiếu Def;
  `CALL` mà cụt = chết trong handler; có `CALL-DONE` = mod chạy trọn ⇒ vấn đề **hiển thị của engine**.
- Hàm native có trong engine? `grep -l -a "<TenHam>" Client/*.exe Client/*.dll`
  (17/09: `OpenBattleSelect`, `SetBattleSelectInfo`, `SetBattleSelectPage`, `battle_select` đều có trong `game.exe`).
- **Pak đã NÉN ⇒ grep tên/nội dung trong `*.pak` trả RỖNG — đừng kết luận "không có file đó"** (kể cả tên file có thật
  trong pak, như `tasktrace/ui.lua` nằm trong chính `ui.pak` mà grep không thấy). Muốn biết file ở pak nào:
  `cd Client/data && ../../Tools/unpacktool/unpack.exe -i <pak> -p "<path trong pak>" -o ../../unpack_x` → `[OK] Extracted` = có.
  - `ui/...` → `ui.pak`; `script/protocol.lua` + `script/lib/objbuffer_head.lua` + `script/script_protocol/protocol_def_c.lua` → **`slistcache.pak`**.
  - ⚠️ unpack.exe là binary Windows ⇒ `-o` phải là đường dẫn **Windows thấy được** (tương đối từ CWD); `-o /tmp/...` im lặng không ghi.
- `Client/package.ini` = thứ tự nạp pak (`0=ui.pak`, `1=slistcache.pak`, … `2=updatejx14.pak` mới nhất) — pak nạp sau đè pak trước.
- Xong việc **gỡ debug**; giữ bản gốc (`.goc`/`.bak`) cạnh backup để revert.

## 3. Gói mod kiểu `1_client/` + `2_server/` — coi chừng "file ghi chú"

- Trong `2_server`, file chỉ chứa vài dòng kiểu *"Add vao script: Include(...)"* là **mẩu HƯỚNG DẪN, KHÔNG phải file thật**
  (17/09: `script/protocol.lua`, `script_protocol/protocol_def_gs.lua`, `global/login.lua`, `global/seasonnpc.lua`).
  Copy đè = mất sạch danh sách protocol + `login.lua` ⇒ server không chạy. ⇒ đọc file trước, chỉ đè file có code thật,
  phần còn lại **merge** (grep xem server đã có hook chưa).
- **Đối chiếu md5 server ↔ mod trước mọi lần đè** — trùng md5 = server đã có bản đó, khỏi đè
  (17/09: `script/tasktrace/{tasktrace,protocol_gs}.lua` trùng md5; hook đã nằm sẵn trong `login.lua` ~dòng 143,
  `seasonnpc.lua` ~345, `item/tasklink_goods*.lua` ~64).
- User có thể yêu cầu thẳng *"cứ chép đè theo hướng dẫn"* → làm phần an toàn, **nói 1 câu rõ vì sao KHÔNG đè file ghi chú**.
- Tên thư mục/file tiếng Trung trong gói mod là **byte GBK** → copy **trực tiếp trên WSL** (`cp -r`),
  **đừng tar qua macOS** (tên bị double-encode thành `\303\226...`).

## 4. Đọc chữ TCVN3 trong mod/README cũ

Chữ Việt trong README/comment mod đời cũ ở **bảng mã TCVN3 (ABC)** → đọc thẳng ra `toµn bé c¸c folder`.
Chuyển bằng npm `vietnamese-conversion` (Node ≥18; đừng dùng python):

```bash
cd /tmp && npm i vietnamese-conversion
node -e 'const vc=require("vietnamese-conversion"),fs=require("fs");
         const [f,m]=process.argv.slice(2),b=fs.readFileSync(f);
         process.stdout.write(vc.toUnicode(b.toString(m==="raw"?"latin1":"utf8"),"tcvn3"))' <file> utf8
```

- `.txt/.html` (UTF-8 chứa ký tự bảng TCVN3) → `utf8`; `.lua/.ini` client trong gói mod (byte thô, `file` báo ISO-8859) → `raw`.
- Script Lua **server** là **GBK** → `iconv -f GBK -t UTF-8`; đừng trộn 2 bảng mã trong 1 lần chuyển.
