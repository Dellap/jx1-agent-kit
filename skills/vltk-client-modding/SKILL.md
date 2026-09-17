---
name: vltk-client-modding
description: Use when modding VLTK/JX1 game client UI (.ini, .spr, pak).
---

# VLTK/JX1 Client Modding

Modding the JX1 (Võ Lâm Truyền Kỳ / Kiếm Thế) Windows client UI. Server addresses/credentials: see memory (client @ <GAME_HOST_IP>, share `VoLamTruyenKy`). All comms with user in Vietnamese, address user as "bạn".

## Client ↔ server kết nối (07/09/2026 — server đã dời sang WSL2)

- **Server "<SERVER_NAME>" chạy TRONG WSL2 (CentOS 7, chỉ yum) trên PC <GAME_HOST_IP>** — không còn trên <GAME_HOST_IP_OLD> (vdk, Ubuntu). Share `VoLamTruyenKy` root giờ gồm: `Client/` (game chính, HQVL skin), `Server/` (chỉ chứa `jxser.tgz` — bộ server), `UI/` (bộ skin "Hội Quán Võ Lâm"). Không còn `CLIENT/SERVER/TOOL` như cũ.
- **Client chọn server ở đâu:** `Client/UserData/uicommon.ini` (GBK) → `[Region_0]` `0_Title=<tên server>` + `0_Address=<IP>`; `[Login] SelServerRegion=0` chọn mặc định. **Lỗi kinh điển: `0_Address=.../` dư dấu `/` cuối → client không kết nối được** (Client1 bản chuẩn không slash thì chạy). Sửa bằng python, giữ CRLF+GBK, backup .bak.
- **WSL2 NAT:** IP 172.26.x.x là IP ảo bên trong WSL2, đổi mỗi lần reboot, máy khác không tới được. Client chạy CÙNG máy <GAME_HOST_IP> → trỏ `127.0.0.1` (Windows localhost relay tự chuyển vào WSL2). Client máy khác → phải portproxy trên host Windows (`netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=<p> connectaddress=<wsl-ip> connectport=<p>` + firewall) rồi trỏ IP LAN host.
- **UI folder = bộ skin HQVL kèm binary riêng:** `game.exe`, `one.dll`, `ddraw.dll`, `VLTK_ui.dll`, `HoiQuanVoLam.exe` (launcher .NET có ô ServerHost/ServerPort + server check timer), `assets/`, `spr/Ui3/`, `ui/` themes. **Copy nguyên bộ vào Client làm thay game.exe + DLL → hỏng kết nối server nhà** (bản mod này sinh ra cho server HQVL riêng). Giữ skin = dùng `HoiQuanVoLam.exe` trỏ server; chạy lại kiểu stock = phục hồi game.exe gốc (copy từ bản Client sạch) + bỏ one.dll/ddraw.dll. Chỉ skin thuần (spr/Ui3, ui/, assets, resolution.jsonc, fps_events.ini) thì vô hại. Launcher.exe 2 bản giống hệt — nó gọi game.exe cùng thư mục nên khác biệt nằm ở game.exe.
- **WinSCP vào WSL2:** cài openssh-server trong WSL2 (`yum install -y openssh-server`; CentOS 7 EOL → sed mirrorlist→vault.centos.org trước; systemd lỗi thì chạy thẳng `/usr/sbin/sshd`; tắt firewalld). Kết nối bằng **IP WSL2 (`hostname -I`), KHÔNG dùng 127.0.0.1:22** — Windows <GAME_HOST_IP> đã có OpenSSH riêng (user <SMB_USER>) chiếm port 22 nên localhost relay không chuyển được. Cách không cần SSH: Explorer `\\\\wsl.localhost\\<distro>\\`.
- **Server file ops = `ssh jx1`** (alias Mac = `root@<GAME_HOST_IP>:2222`, SSH key; portproxy 2222→WSL:22 tự refresh — cơ chế auto-heal xem skill `windows-remote-admin` references/wsl2-jump-access.md). Server = `/home/jxser/server1` (`jx_linux_y` gameserver, `script/`, MySQL :3306, web python2 :80). Không cần IP WSL, không hỏi user.
- **Đè file script khi server ĐANG CHẠY:** script nạp RAM lúc start → đè file an toàn nhưng **phải restart server (jx_linux_y) mới có hiệu lực**. Backup `.bak-YYYYMMDD` trước, verify md5 sau.
- **Diff file .lua mojibake (JX1VN = GBK lẫn, decode thuần fail mọi codec):** đừng diff thô (nhiễu encoding/CRLF → tưởng mọi dòng khác). Decode `latin-1` (1 byte = 1 ký tự, không mất dữ liệu) + strip CR + `difflib.SequenceMatcher` → thấy đúng block thêm/sửa. Hai file fail decode cùng vị trí = cùng encoding → lệch số dòng = có nội dung thêm thật.

## Access (SMB)

- Use `smbclient "//<host>/VoLamTruyenKy" -U "user%pass" -m SMB3 -c "..."`.
- **GBK filenames**: Chinese filenames on the share are GBK. `smbclient get/put` with UTF-8 Chinese names FAILS silently (0 files). Use the raw mojibake name exactly as `ls` prints it (e.g. `¶¥²¿¿ØÖÆÌõ.ini` = 顶部控制条.ini, `ÉúÃüÌõ.spr` = 生命条.spr, folder `Ö÷½çÃæ` = 主界面). Listing + copying the exact byte string works.
- Verify every upload: `get` it back and `diff` against local. `put` success line says "putting file" (not "getting") — grep both.
- `rename` for backup before editing: `rename file.ini file.ini.bak_<tag>`. Silent success — confirm with `ls *bak*`.

## Architecture

- Share root hiện tại (07/09/2026): `Client/` (game), `Server/` (jxser.tgz), `UI/` (skin HQVL) — layout cũ `CLIENT/SERVER/TOOL` đã thay đổi; xem section "Client ↔ server kết nối".
- Game UI = theme folders under `CLIENT/ui/ctc/` (active, from `config.ini [Client] Theme=CTC`) + `CLIENT/spr/Ui3/` + `CLIENT/spr/f3/`.
- UI layout = text `.ini` per window; images referenced as `Image=\Spr\Ui3\主界面\xxx.spr`.
- Data packs: `CLIENT/data/*.pak` (`ui.pak`, `spr.pak`...). **Loose files override .pak** — editing/copying loose files needs NO repack (this is how the 1600x900 "mở rộng màn hình" fix works: unpack pak → copy folder tree into game dir → done).

## Engine render rules (learned the hard way — DO NOT violate)

1. **`Image=` only renders `.spr`** — PNG/BMP silently ignored (579/579 refs in inis are .spr). Convert PNG→spr (user's tool, or SPRViewer) before referencing.
2. **Only controls the engine instantiates render.** Adding an arbitrary new `[MySection]` to an existing window's .ini does NOTHING. Known render paths:
   - Sections declared in `[Main]` via `Button0=...ButtonN=...` (with full button pattern: `Image` + `Up/Down/Over/OverFrame` + `Tip`, optionally `ClassType=Player_Xxx`).
   - Data-bound sections with `ClassType=` (e.g. `[Life] ClassType=Player_Life`) — these DO move when you change their `Left/Top` (bars relocated to corners = proof).
   - `[X_Image]`/`[X_Text]` children of a bound section.
3. **`.ini` files must be CRLF.** Appending sections with LF-only line endings gets swallowed by the 2004-era parser. Always emit `\r\n`.
4. **Sprite header fields 8-11 = frame size. `0,0` = single frame** (correct, like original `生命条.spr` 106x11). Non-zero (e.g. 64,64 or 115,115 on a 128² / 230² image) → engine reads it as a sprite SHEET → images duplicated/stretched in a row. **Do NOT patch fields to 0,0 on a sheet-encoded file — game crashes** (pixel data is frame-encoded; header-only patch breaks frame math).
5. UI element positions are relative to window `[Main] Left/Top`. Extend `[Main] Height` if children move outside the rect (clip risk).

## .spr format (verified)

```
0x00 "SPR\0" | 0x04 w(2 LE) | 0x06 h(2 LE) | 0x08 frameW(2) | 0x0A frameH(2) | 0x0C tail 0100000101000100
pixel data: RLE runs — count(1B; 0=1 transparent px) + BGR(3B)
```
Original bar `spr/Ui3/主界面/ÉúÃüÌõ.spr` (生命条, máu, 106x11, 2004B) = reference template. 内力条.spr (mana) identical size. When user's tool produces sheet-encoded output, the correct fix is re-packing as single frame in the TOOL, not binary patching.

## Workflow (each iteration)

1. Read current file (iconv GBK→UTF-8 for reading: `iconv -f GBK -t UTF-8`), edit bytes in Python preserving CRLF + GBK.
2. Backup on server via `rename ... .bak_<tag>`.
3. Upload, then `get` back + `diff` (also assert CRLF count: `LF-only == 0`).
4. User runs game, reports: hiện/đúp/cắt/crash → iterate. Rollback = rename .bak back.

## Tools on server (TOOL/)

- `Unpack/unpack.exe` — .pak extractor (CLI: `-i file.pak -p path -a -l list.txt -o outdir`), keep pak list/hashes. **Đường dẫn thật hiện nay: `/mnt/e/Game/jx1/VoLamTruyenKy/Tools/unpacktool/unpack.exe`** (cùng thư mục có `Decoder.exe`, `paths.txt`).
- **unpack.exe là binary WINDOWS — từ WSL KHÔNG nhận đường dẫn Linux**: `-i /mnt/e/...` hay `-o /tmp/...` fail "Cannot open file"/ghi sai chỗ. Cách chạy đúng: `cd` vào thư mục chứa pak (vd `Client/data`) rồi dùng `-i ui.pak -o ../../unpack_out` — output phải là đường dẫn tương đối Windows-visible từ CWD.
- **Unpack 1 file cụ thể từ pak:** `unpack.exe -i ui.pak -p ui/ctc/¹¤¾ß¿ØÖÆÌõ.ini -o ../../unpack_out` (`-p` = path trong pak, dùng tên GBK mojibake đúng như `ls` in ra). Báo `Files: 3381 [OK] Extracted`.
- **NƠI GHI OUTPUT GIẢI NÉN (bạn yêu cầu 17/09/2026):** đừng để thư mục giải nén rải rác trong `VoLamTruyenKy/`
  (làm rối share root) — gom hết vào **1 chỗ: `E:\Game\jx1\_unpack\<tên>`**, kèm `_README.txt` nói rõ từng thư mục là gì.
  Giải nén xong thì `mv` vào đó; `_unpack/` KHÔNG phải phần của client nên xoá được khi hết cần.
- `SPRViewer/` — .NET SPR viewer (user runs it; may export/import PNG→SPR — confirm capabilities before assuming).
- `ResolutionHook.0.0.2/` — window size hook (`resolution.ini` Width/Height + filtertext.dll proxy; `Log=0` to stop log spam).
- `UI+3/` — reference mod showing the correct "add button" pattern (Button<N> decl + full section) and how 1600x900 theme swaps the `[Main]` background image.

## Resolution hook + uiLayout (resolution.jsonc) — client base 800x600

- **Client chạy NỀN 800x600** (config.ini `Theme=CTC`; file UI gốc trong `ui.pak` có `[Main] Width=800 Height=600`). ResolutionHook (`filtertext.dll`/VLTK_ui + `resolution.jsonc` width/height) patch cửa sổ lên 1920x1080 rồi `autoUiLayout` + `uiLayout` tự scale/dời UI cho khớp. File UI gốc KHÔNG được sửa sang 1024 — cứ giữ 800x600, hook lo phần scale.
- **`uiLayout` = list JSON** (trong resolution.jsonc): mỗi entry `{ "file": "<tên ini GBK mojibake>", "sections": { "<TênSection>": { "trueW"/"trueH": số, "keys": { "<KeyINI>": slot }, "children": {...} } } }`. Slot hợp lệ: `none | adjust | ratio | center | left|right (X) | top|bottom (Y)` — `center` giữa màn, `ratio` nhân theo tỉ lệ phân giải, `adjust` cộng delta, `left/right/top/bottom` bám lề (tự đọc Width/Height UI, có thể cần `trueW`/`trueH` khi UI chưa load), số cứng = cách mép N px. Keys cũng nhận array (key 2 giá trị như `LeftBtnPos`) và object `ref{file,section,at,offset,fallback}` = neo vào UI khác. Hot-reload ~1s khi sửa jsonc.
- **Entry 玩家信息主界面.ini (màn hình chính):** `Main` → `Left center, Top bottom` (PlayerBar bám đáy giữa) + children `DateTime` left/top. File này chứa các `[Item_0]..[Item_8]` = ô đồ nhanh (36x36, Top~550, Left tăng dần) — **bản gốc trong pak để Item_3..8 dạng COMMENT (tắt), mod "UI 3+6 ô" chỉ bật chúng** (uncomment + chỉnh Left/Top + kèm sprite `spr/Ui3/thanhhienthi/thanh.spr` cho InputBack).
- **Mod skin có nhiều biến thể tọa độ** (vd folder "UI 3 + 6 Ô CTC (1024x768) (800x600)": `Ui/ctc` = 800x600, `Ui/ctc1024` + `Ui/Ui3` = 1024x768 giống hệt nhau): client base 800x600 → **CHỈ dùng bản 800x600**, bản 1024 sẽ lệch. Verify bằng diff với file gốc unpack từ pak (mod 800x600 chỉ khác vài Left + bật Item_3-8).

### UI 3+6 ô đồ nhanh + launcher CTC (số đã bóc thật — chi tiết `references/ui-3x6-slots.md`)

Mod "UI 3 + 6 Ô CTC (1024x768) (800x600)" bật thêm 6 ô `[Item_3]..[Item_8]` (36x36) trên màn hình chính, dời
nền ô nhập chat và chỉnh nhẹ 10 nút toolbar. Số chuẩn cho client nền 800x600 (`Width/Height=36`, bước 40px):

| Section | Left | Top | | Section | Left | Top |
|---|---|---|---|---|---|---|
| `[Item_3]` | 282 | 494 (`HaveBgColor=1`) | | `[Item_6]` | 402 | 494 |
| `[Item_4]` | 322 | 494 | | `[Item_7]` | 442 | 494 |
| `[Item_5]` | 362 | 494 | | `[Item_8]` | 482 | 494 |

Gốc trong pak để 6 section **comment** với `Top=550`, `Left=129/167/205/243/281/320` → đổi sang hàng trên.
Kèm theo: `[InputBack] Left=228→221, Top=530→491`; `顶部控制条.ini` sửa `Left` (giữ `Top=534`): ItemEx 300,
ChatRoom 228, Status 252, Items 276, Task 504, Team 348, Run 372, Faction 408, Sit 432, Horse 456; sprite nền
`spr/Ui3/thanhhienthi/thanh.spr` (359x67, single-frame).

**Bắt buộc kiểm "nền" client đích trước khi áp số**: theme phải `CTC`, base 800x600, toolbar cùng version.
Khác nền (theme khác / base 1024 / toolbar khác) ⇒ số sẽ lệch → phải diff với file gốc bóc từ pak rồi tính lại.
Script kiểm nền + bộ mẫu gốc/mod/biến thể 1024 nằm trong repo `jx1-agent-kit`
(`scripts/check-client-base.py`, `sources/client-sample/`).

**Launcher CTC = `HoiQuanVoLam.exe`**: `HoiQuanVoLam.ini` chỉ có `[Launcher] Theme=current` — launcher **không
giữ IP**. Nó lấy server từ `Client/config.ini` (`[Server] ServerOn / GameServPort=5622 / DenialPort=5623`,
`[Launcher] profile=2`) + `Client/UserData/uicommon.ini [Region_0] 0_Title/0_Address` (client cùng máy ⇒
`127.0.0.1`). ⚠️ Bộ skin HQVL kèm `game.exe`/`one.dll`/`ddraw.dll` riêng — chỉ copy launcher + skin, không copy
3 file đó kẻo client login sang server khác.

- Sprite tham chiếu trong ini có cả `\Spr\...` (hoa S) lẫn `\spr\...` — thư mục thật trên đĩa là `Client/Spr/Ui3/` (hoa S). Backup sprite cũ `.bak-YYYYMMDD` trước khi đè.

## Protocol id: LẤY TỪ FILE NÀO (17/09/2026 — đọc kỹ, đã từng sửa sai vì so nhầm bảng)

JX1 đánh số protocol **theo VỊ TRÍ trong bảng `KE_SCRIPT_PROTOCOL`** (`ScriptProtocol[name]=index`, 1-based).
**Cả client LẪN server đều lấy bảng này từ CÙNG MỘT file dùng chung: `script/protocol.lua`**
(server: `/home/jxser/server1/script/protocol.lua`; `protocol_def_gs.lua` chỉ `Include` nó rồi khai báo `Def`).
⇒ Hai bên **đã khớp sẵn**, ví dụ thật: `TASKTRACE = #17`, `EXPRANK = #18`, `EXPRANK_STRING = #19`.

- ⛔ **ĐỪNG so số protocol với `script_protocol/protocol_def_gs.lua`** — đó là **bảng handler (Def)**,
  không phải bảng số. Bản liệt kê bên trong nó (11–12 mục) KHÔNG phải enum.
  (17/09 trợ lý so nhầm sang file này, tưởng server `TASKTRACE=#12` vs client `#17` → sắp lại bảng enum của
  client → server gửi 17, client hiểu thành `KICHCLIENT` → mod chết thêm 3 lần test của bạn.)
- Kiểm đúng: `grep -A24 KE_SCRIPT_PROTOCOL /home/jxser/server1/script/protocol.lua` rồi so với
  `Client/script/protocol.lua` — hai danh sách phải **giống y từng dòng**.
- **Việc thật cần làm với mod mới = thêm 1 dòng `Def` (`Nội dung` trong `references/mod-install-and-debug.md`),
  KHÔNG đổi thứ tự enum.** Nếu tên protocol đã có trong enum thì chỉ cần Def.
- `luajit -bl file.lua /dev/null` để kiểm cú pháp trước khi đẩy (enum thuần Lua; exe/dll client không chứa tên protocol).

### Gỡ lỗi "mod im lặng, không thấy gì" — gắn log vào chính `protocol.lua` (cách DUY NHẤT hiệu quả)

JX client có API ghi file: `openfile(".\\logs\\x.txt","a")` / `write(f, s.."\n")` / `closefile(f)`
(ví dụ gốc: `script/ui/ranking.lua` → `Logs/expranking.txt`) và `Msg2Player()` hiển thị được ở client.
Dùng `scripts/instrument-client-protocol.py <protocol.lua vào> <ra>` để tự gắn 3 mốc log:
1. sau `ScriptProtocol:_InitProtocolEnum()` → `LOOSE loaded. TASKTRACE_id=N ... | engine: pcall=.. call=.. getn=..`
   (chứng minh bản **loose** được nạp — nếu file log rỗng thì client đang dùng bản trong pak `slistcache.pak`
   và phải đóng gói lại vào pak)
2. đầu `ProtocolProcess` → `RX id=N name=... hasHandler=1/nil` cho **mọi** protocol nhận được
   (đây là bằng chứng quyết định: thấy được server thật sự gửi số nào, client hiểu thành tên gì)
3. quanh lời gọi handler → `CALL <file> <fun>` … `CALL-DONE <fun>` (code gọi handler giữ **NGUYÊN XI**, chỉ kẹp 2 dòng log)

⛔ **TUYỆT ĐỐI KHÔNG bọc `pcall` trong script client để debug** (bài học 17/09/2026, tốn 3 lần test của bạn):
engine script là **Lua đời cũ, KHÔNG phải Lua 5.1** (`getn`/`tinsert`/`format` global, `for key,v in tbl do`),
nghi **không có `pcall`**. Bọc `pcall(...)` ⇒ script **dừng NGAY tại dòng đó, im lặng tuyệt đối** (không log, không popup)
→ log cụt đúng sau dòng liền trước ⇒ dễ kết luận sai là "hàm engine bị crash". Muốn biết dialect thì **log `tostring(pcall)`**
chứ đừng gọi. Cần bắt lỗi thì dùng `call()` nếu có, còn không thì **chỉ log trước/sau** rồi suy ra từ chỗ log cụt.

Đọc log (cây quyết định):
- không có dòng `LOOSE loaded` = client nạp bản trong pak ⇒ phải đóng gói lại vào pak
- có `RX id=N` + `hasHandler=nil` = lệch số / thiếu Def
- có `CALL ...` mà **cụt** (không `CALL-DONE`) = chết bên trong handler (hàm hiển thị của engine hoặc ui.lua của mod)
- có `CALL-DONE` = mod chạy trọn vẹn ⇒ không hiện bảng là vấn đề **hiển thị** (tọa độ/theme/ảnh nền/engine không vẽ)

Sau khi xong **gỡ log, trả về bản sạch** (giữ backup `*.bak_<ts>`).

- Ca thật 17/09: log cho thấy `RX id=19 EXPRANK_STRING hasHandler=1` (khớp số 19 ⇒ enum 2 bên giống nhau)
  và `RX id=17` bị hiểu nhầm = bằng chứng đanh thép rằng server dùng số 17 cho TASKTRACE.

## ⛔ 2 điều CẤM khi mod client JX1 (17/09/2026 — đã trả giá)

1. **KHÔNG đè `ui/<theme>/battle/battle_select.ini`** trên client của bạn — đây là **cửa sổ neo dùng chung**:
   `btn_prevpage` = Hệ Thống Pet, `btn_nextpage` = Kỹ Năng Sống, `btnShop` = Vòng Quay (spr `\Spr\update\`),
   `info_1..info_4` neo lệch (Left âm, vd -630) cho **thông báo PK Tống Kim / PK thường / icon lientram / khung màu quái**,
   và `ScriptFile` **đã trỏ sẵn** `\script\tasktrace\ui.lua`. Đè bằng ini của mod (info ở 10,35…) ⇒ bảng nhiệm vụ dồn ra
   giữa màn hình, mất 3 nút, **shop động SimBot không hiện vật phẩm**. Mod Task Trace chỉ cần `script/tasktrace/*` + protocol;
   **giữ nguyên ini gốc client** (bản sạch: `Update\_backup_client_truoc_tasktrace_20260917_1800\battle_select.ini.tu_pak`, 1975B).
2. **Engine Lua client KHÔNG có `pcall`** (dialect đời cũ: có `getn`, `tinsert`, `mod`, `format`). Chèn `pcall(...)` vào script
   client ⇒ script **dừng im lặng** ngay tại dòng đó (không log, không báo lỗi) — chính là thứ làm mod "không hiện" cả buổi 17/09.
   Muốn bọc lỗi dùng `call(f, ...)`.

## Chẩn đoán protocol client JX1 (17/09/2026 — cách tìm ra bug trên)

1. Log bằng `openfile(".\\logs\\protocol_log.txt","a")` + `write(f,msg.."\n")` + `closefile(f)` (như `script/ui/ranking.lua` ghi `Logs/expranking.txt`).
2. Gắn log trong `ScriptProtocol:ProtocolProcess(nProtolId, nHandle)` (file `script/protocol.lua` loose): in `id`, `self.KE_SCRIPT_PROTOCOL[nProtolId]`,
   `hasHandler`, và trước/sau `Require(szFile); DynamicExecute(szFile, szFun, ...)` trong nhánh `MODEL_GAMECLIENT == 1`.
3. Đọc `Client\logs\protocol_log.txt` sau khi user đăng nhập: rỗng = không nạp loose / không có protocol nào tới; có `RX id=N` = tới nơi.
4. **Bảng số protocol dùng CHUNG file `script/protocol.lua` cho cả 2 phía** (server `protocol_def_gs.lua` chỉ `Include` file đó rồi khai báo handler)
   ⇒ `protocol_def_gs.lua` KHÔNG phải bảng số, đừng so số ở đó (17/09 trợ lý từng so nhầm rồi "sửa" bảng client → phá mod).
5. Gỡ log sau khi xong: trả `protocol.lua` về bản chỉ gồm enum + Def TASKTRACE.

> ⚠️ **Lỗi "click bot đứng bán không xem được hàng" KHÔNG phải do thiếu ini theme** — nguyên nhân nằm ở module engine
> `vdk.dll` (client) / `vdk.so` (server): xem skill `jx1-simbot`, mục "Shop đứng bán … module ENGINE vdk". Đừng đuổi theo hướng copy cửa sổ theme nữa.

## ⚠️ Quy luật TÊN FILE trong client JX1 — tên "mojibake" mới khớp (kiểm chứng 17/09/2026)

- **Bằng chứng (quét toàn bộ `spr/` client):** MỌI file/thư mục tiếng Trung do client phát hành đều mang tên **mojibake**
  = bytes GBK bị hiểu thành Latin-1: `°ÚÌ¯` (không phải `摆摊`), `ÂòÂô` (`买卖`), `½»Ò×` (`交易`), `Ö÷½çÃæ` (`主界面`)…
  **không tồn tại** thư mục tên Unicode chuẩn nào. `ui/ctc/*.ini` cũng vậy.
- **⇒ Copy file/thư mục tên tiếng Trung vào client thì đặt tên mojibake**: `name.encode('gbk').decode('latin-1')`.
- **An toàn nhất khi chưa chắc: đặt CẢ HAI tên** (mojibake + Unicode) — rẻ, không hại gì.
  ⛔ Câu cũ "*copy tên mojibake là sai chỗ, phải đặt tên Unicode*" là **suy đoán chưa kiểm chứng** — bỏ.
- **Tên file ASCII** (`battle_select.ini`, `info_gray.spr`, `uicommon.ini`) không bị ảnh hưởng.

## Bẫy thứ 2 — theme

- **README ghi `/ui/` nhưng mod đóng gói cho theme `ui3`** (`1_client/1_ui/ui3/battle/battle_select.ini`).
  Client của bạn chạy theme **CTC** (`Client/config.ini: Theme=CTC`; thư mục loose là `ui/ctc`, `ui/ui_ctc_v2`, `ui/ui_vlmp`,
  `ui/one` — **không có `ui/ui3`**). ⇒ đặt ini vào `ui/ctc/battle/` (theme đang chạy) và copy thêm `ui/ui3/battle/` cho đúng nguyên văn README.
  (`spr` thì ngược lại: theme spr là `Ui3`/`Ui4` chữ hoa, đúng như mod ghi.)

## Quy tắc cài mod theo README (bạn chốt 17/09/2026 — bắt buộc)

- **Đọc README trong thư mục mod rồi làm ĐÚNG như nó ghi: copy & ghi đè. Không tự chế cách khác, không sửa
  nội dung file của mod.** bạn nói thẳng: *"m ko cần sửa gì cả, đọc readme … rồi làm theo cho t"* — khi đã có
  hướng dẫn thì thực thi, đừng phân tích lại từ đầu. (Bản debug trợ lý tự gắn vào file mod → phải gỡ, trả về nguyên gốc.)
- **Server: nhiều file trong `2_server/` chỉ là GHI CHÚ** ("Add vao script: …", 7–12 dòng), KHÔNG phải file thật —
  đè vào là mất `protocol.lua`/`login.lua` của server. Việc đúng: đối chiếu từng mục README với file thật trên server
  bằng `grep -n` + `md5sum` rồi **báo bạn bằng chứng** (file nào đã khớp, mục nào còn thiếu).
- Ghi rõ cho bạn cái nào trợ lý phải lệch khỏi nguyên văn README vì máy bạn khác bối cảnh mod
  (theme CTC vs `ui3`, tên folder spr mojibake) — không lặng lẽ làm khác.
- Backup trước mỗi lần đè (`Update/_backup_client_truoc_<việc>_<ts>/`, `*.bak_<ts>`), verify md5 sau khi đẩy.

## Mod "Theo dõi nhiệm vụ" (Task Trace) — 17/09/2026

Nguồn: `Update/Theo_doi_nhiem_vu/` (bạn bỏ vào 17/09) + `Theo_doi_nhiem_vu.7z`. Gồm `1_client/` + `2_server/` + README (README viết **TCVN3**, đọc bằng
`npm i vietnamese-conversion` → `toUnicode(s,'tcvn3')`; file .lua/.ini client cũng TCVN3-raw, server lua là **GBK**).

**Trạng thái: server <GAME_HOST_IP> ĐÃ có mod này từ 2022** (không cần làm gì):
`script/tasktrace/{tasktrace.lua, protocol_gs.lua}` (md5 khớp bản mod), `script/protocol.lua` có `emSCRIPT_PROTOCOL_TASKTRACE`,
`script_protocol/protocol_def_gs.lua` có Def, `global/login.lua` (Include + `open_task_trace()`), `global/seasonnpc.lua`
(`nt_setTask(5123,1)` + `open_task_trace()`), `item/tasklink_goods(.secret).lua` có hook ở dòng ~64.

**Client thì THIẾU — đã bổ sung 17/09** (đây là lý do tính năng không hiện dù server có sẵn):
- `Client/script/tasktrace/{ui.lua, task_random.lua, task_messenger.lua}`
- `Client/spr/Ui3/battle/info_gray.spr`, `Client/spr/Ui4/任务指南资源/任务追踪底板.spr` (**tên folder GBK** — copy bằng `cp -r` **trực tiếp trên WSL**;
  tar qua macOS sẽ double-encode tên → sai)
- `Client/ui/ctc/battle/battle_select.ini` (theme đang dùng là **CTC**) — ⚠️ bản trong `ui.pak` trước đó đã bị tùy biến (3 nút pet/kỹ năng
  sống/vòng quay + ô thông báo PK, info dời ra ngoài màn) và cũng trỏ `ScriptFile=\script\tasktrace\ui.lua`; bản mod thay bằng layout
  "Theo dõi nhiệm vụ". Backup bản cũ: `Update/_backup_client_truoc_tasktrace_<ts>/battle_select.ini.tu_pak`.
- `Client/script/protocol.lua`: thêm 1 Def vào bảng `Def` (trước `ScriptProtocol:RegProtocolSet(Def)`):
  `{"emSCRIPT_PROTOCOL_TASKTRACE", "\\script\\tasktrace\\ui.lua", "TaskTrace:OpenUI", {OBJTYPE_NUMBER}}` — file này **LF (không CRLF)**, sửa bằng Python bytes, push lại rồi so md5.
- `settings/task/tasklink_*.txt` đã có sẵn trong client (task_random.lua cần).
- Client **không có** `script/lib/objbuffer_head.lua` / `script_protocol/protocol_def_c.lua` viết rời (Include trong ui.lua fail im lặng;
  `ObjBuffer`/`OB_*` do `lualibdll.dll` của engine cấp). Đừng đi tìm trong pak — không có.

**Cơ chế**: server giữ nhiệm vụ đang theo dõi ở **task slot 5123** (5123 là SLOT, **không phải số protocol**);
`open_task_trace()` gửi protocol TASKTRACE (**số #17** — xem mục "Protocol id") xuống client →
`ui.lua` gọi `OpenBattleSelect()` rồi đổ text vào `SetBattleSelectInfo(0..3)`. Nút **prev = menu chọn nhiệm vụ** (`choose_task_trace` → Say
"Dã Tẩu"/"Bỏ chọn tất cả" → `SetTask(5123,n)`), nút **next = đổi Camp** (`SetCurCamp/SetCamp` mod 5), click = `tl_moveToTaskMap()`.
Nội dung text: `task_random.lua` (nhiệm vụ Dã Tẩu, task 1021/1025-1028/1030, đọc `settings/task/tasklink_*.txt`) + `task_messenger.lua`
(nhiệm vụ sứ giả: Thiên Bảo Khố/Phong Kỳ/Sơn Thần Miếu, task 1201-1207). Hook mở UI: khi đăng nhập, khi nhặt bản đồ <SERVER_NAME>,
và trong `Task_MainDialog` của `seasonnpc.lua`.

**✅ TRẠNG THÁI 17/09/2026 (cuối buổi): BẢNG ĐÃ HIỆN.** Chuỗi nguyên nhân, học theo thứ tự:
1. Client **thiếu file mod** (script tasktrace + 2 spr + Def protocol) → cài đủ.
2. Trợ lý tự chèn 1 dòng `Def` **sai vị trí** (ngoài bảng) → protocol.lua lỗi cú pháp → cả hệ protocol client chết.
3. Trợ lý bọc **`pcall`** trong script client (engine Lua đời cũ **không có pcall**) → script dừng im lặng đúng dòng đó
   ⇒ 3 lần test của bạn đều thất bại vì **chính bản debug của trợ lý**, không phải mod.
   → Bỏ hết `pcall`, chỉ chèn `__LOG` (log thuần) là bảng hiện ngay.
Log xác nhận lúc chạy được: `RX id=17 name=emSCRIPT_PROTOCOL_TASKTRACE hasHandler=1` +
`CALL … tasktrace\ui.lua TaskTrace:OpenUI` + `CALL-DONE`.
4. Còn lại thuần **vị trí/khung hiển thị** — xem mục dưới.

### Vị trí khung bảng nhiệm vụ (17/09/2026 — đang chỉnh)

- Ini gốc client đặt `info_1..4` **lệch ra ngoài khung** (Left âm, vd -630) ⇒ engine **không vẽ** phần đó
  ⇒ bảng nhiệm vụ **không hiện**; khôi phục ini gốc một mình là không đủ.
- Cách chữa (2 bước, bước 2 mới là bản đúng):
  1. `scripts/jx1_merge_battleselect.py` (bản nháp, giữ ini client + chỉ đưa `info_1` vào khung): **KHÔNG ĐỦ** —
     bạn báo *"chỉ hiện text 'Nhiệm vụ Dã Tẩu', không hiện hết UI"* vì `info_2..info_4` vẫn lệch ra ngoài khung.
  2. `~/.hermes/scripts/jx1_build_full_panel.py` = **dùng nguyên layout mod** (`Main` 180x220 + Image 底板,
     `info_1..4` (10,35 / 10,120 / 23,247 / 23,331), `btn_prevpage` "Nhiệm Vụ", `btn_nextpage` "Đổi Camp",
     `btn_close`, `scroll_bar`, `scroll_bar_Btn`) **+ thêm `[btnShop]` (Vòng Quay) của client** ở đúng vị trí
     tuyệt đối cũ, rồi dời `Main` sang mép phải. In bảng `rel/abs` từng section và **exit 1 nếu thiếu section**.
     ⇒ **LUẬT: panel phải đủ CẢ 5 khối** (`info_1..4` + 2 nút trang) trong màn hình mới gọi là "hiện đầy đủ";
     chỉ kéo 1 khối vào là hiện mỗi dòng chữ trơ.
  - Dời `[Main]` phải **dịch bù delta** cho mọi child cần giữ chỗ (`child.rel_new = child.rel_old − delta`),
    rồi **assert `Main_new + rel_new == Main_old + rel_old` cho từng child** (sai 1px là fail).
  - `Main.Left` phải ≤ `1600 − 218 − 10` = **1372** vì `info_3/info_4` rộng 218 và nằm dưới khối 180x220.
- **Bản đang chạy (cuối 17/09)**: layout mod + `[btnShop]` abs (1000,332) + `Main` **(1350,150)**,
  md5 `7d00fae1db11585ce4340c9404fe2a57`. Backup: `Update/_backup_client_truoc_tasktrace_20260917_1800/
  battle_select.ini.tu_pak` (ini gốc client) + `_backup_client_truoc_readme_20260917_1841/*` (merge v1, bản log).
- ⚠️ **Trùng tên section**: nút Pet/Kỹ Năng Sống của client dùng đúng `btn_prevpage`/`btn_nextpage` — cùng tên
  với 2 nút của bảng nhiệm vụ ⇒ **không thể cùng tồn tại** trong 1 cửa sổ (engine chỉ có 1 bộ callback
  `prev_page/next_page`). Bản hiện tại dùng nút của mod; đã nói rõ với bạn, **chờ bạn quyết**.
- ⛔ Đừng "sửa" bằng cách sắp lại bảng enum hay chế cơ chế mới — bạn đã yêu cầu làm ĐÚNG README; muốn đổi hướng thì HỎI bạn trước.
- Chi tiết đầy đủ cả ca (3 nguyên nhân xếp chồng, state, script kèm): `references/jx1-battleselect-taskextrace.md`.
- ⚠️ File ini trộn GBK + bytes tiếng Việt hỏng ⇒ xử lý **bytes qua latin-1**, chỉ encode GBK cho đường dẫn ảnh;
  `re.sub` với replacement chứa `\` **phải dùng `lambda`** (không thì `bad escape \s`).
- bạn chơi ở màn **1920x1080** nhưng game chạy nội bộ **1600x900** (`resolution.ini`) — hỏi bạn khi cần tính lại toạ độ.
- Bản tham chiếu API cửa sổ này: `script/missions/battle/protocol_c.lua` (trong `slistcache.pak` — hàm `show_battle_select`,
  callback `on_select/prev_page/next_page/mouse_wheel`) và các section mà `battle_select.ini` cần:
  `[Main] [btn_close] [btn_prevpage] [btn_nextpage] [info_1..4] [scroll_bar] [scroll_bar_Btn]`.

## Pitfalls

- **Chèn entry vào bảng `Def` của `script/protocol.lua`: PHẢI nằm TRONG bảng**, tức là trước dòng `}` đóng bảng
  (`\t}` ngay trên `ScriptProtocol:RegProtocolSet(Def)`), **không phải trước dòng `RegProtocolSet`**.
  Chèn sai vị trí = entry nằm ngoài bảng = **lỗi cú pháp Lua → TOÀN BỘ hệ protocol của client chết im lặng**
  (không log, không popup; triệu chứng: mọi tính năng dùng protocol ngừng, không riêng mod mới).
  Luôn `luajit -bl <file>.lua /dev/null` trước khi đẩy (file này LF, có thể lẫn `\r\n` — Lua chấp nhận cả hai,
  nhưng anchor tìm kiếm phải tính tới).
- Don't binary-patch .spr headers to fake single-frame — crash (see rules #4).
- Don't reference PNG/BMP in `Image=` — invisible.
- Don't append LF-only sections — ignored.
- Don't assume new sections render — engine instantiates only declared/bound controls.
- Crash logs: `CLIENT/resolution_hook.log` records Access Violations; stale entries from earlier sessions are common — check timestamps before blaming a new change.

See `references/jx1-ui-engines-notes.md` for full session detail (file inventory, ini section anatomy, crash incident timeline, UI+3 diff analysis).

## 📎 Phần gộp từ `jx1-client-ui-modding` (17/09/2026)
> Gộp nguyên văn từ skill cũ `jx1-client-ui-modding` (đã xoá). Chủ đề nào trùng với phần trên thì **phần trên là bản chính**.

## Client layout (máy <GAME_HOST_IP>, share `VoLamTruyenKy` = E:\Game\jx1)

```
VoLamTruyenKy/
  CLIENT/   <- game (game.exe, data/*.pak, spr/, ui/, script/, resolution.ini)
  SERVER/   <- server files
  TOOL/     <- ui1600 (UI unpack sẵn), ResolutionHook.0.0.2, VLTK_Launcher.rar
```

- Truy cập: `smbclient "//<GAME_HOST_IP>/VoLamTruyenKy" -U "<SMB_USER>%<pass>" -m SMB3` (pass trong memory; mount_smbfs FAIL trên Win11 — luôn dùng smbclient)
- Access nhanh: `cd CLIENT\ui\ctc; get <file> /tmp/x.ini; put /tmp/y.ini <file>`

## Cơ chế theme + resolution (đã solve 8/2026)

1. **Theme**: `CLIENT/config.ini` → `[Client] Theme=CTC` → game load `ui/ctc/*.ini` (tên folder = theme, thường)
2. **UI unpack**: `TOOL/ui1600/` chứa cây đã giải nén (`Spr/` + `ui/ctc1024/`) — copy thẳng vào game là UI mới hoạt động (loose file override pak)
3. **Resolution**: `resolution.ini` + `filtertext.dll` (proxy hook, bản gốc = `filtertext_orig.dll`) — `[Resolution] Width=1600 Height=900 Log=0 PatchGameInit=1`
4. **dgVoodoo** (`ddraw.dll` + `D3DImm.dll` + `dgVoodoo.conf`) kèm client — wrapper DirectDraw cho Win11

## UI .ini structure (vd `顶部控制条.ini` = top bar, GBK name `¶¥²¿¿ØÖÆÌõ.ini`)

```ini
[Main]            ; Left/Top = vị trí window, Width/Height = vùng clip
Left=524 Top=0 Width=552 Height=130
Button0=Life Button1=Mana ...   ; khai báo control engine sẽ khởi tạo

[Life]            ; toạ độ TƯƠNG ĐỐI với [Main] (abs = Main.Left + Life.Left)
Left=-504 Top=60 Width=104 Height=14
Part=1 ClassType=Player_Life    ; bind dữ liệu game (máu)

[Life_Image]      ; ảnh của control — sub-section đặt tên theo pattern <Parent>_Image
Left=-8 Top=-53 Width=120 Height=120
Image=\Spr\Ui3\主界面\生命条.spr
PartType=0        ; fill theo % (ĐÃ XÁC NHẬN 8/2026): 0=ngang HP, 1=ngang MP, 3=DỌC
```

### ⚠️ PartType quyết định hướng fill (ĐÃ MAP ĐẦY ĐỦ 8/2026 — test lần lượt 0→7, user xác nhận từng giá trị)

- **0 = ngang giữ TRÁI** (life bar), **1 = ngang giữ PHẢI** (mana gốc — "mất phần qua bên trái")
- **2 = dọc giữ TRÊN, cắt DƯỚI** — orb đứng yên hoàn hảo, nhưng nước rút từ DƯỚI lên (ngược ý "tụt xuống")
- **3 = dọc giữ DƯỚI, cắt TRÊN** — nước tụt từ TRÊN xuống ✓ đúng hướng, NHƯNG engine **neo đỉnh**: phần còn lại luôn bám Top control → orb trồi lên theo % mana mất
- **4,5,6,7 = fallback về NGANG** — engine CHỈ nhận 0-3 (test cả 4, user báo "vẫn thế" = vẫn ngang)
- **KẾT LUẬN (hard limit engine)**: KHÔNG có chế độ "dọc + neo đáy" → không thể đạt "nước tụt xuống + orb cố định" qua ini. Dời `Top` để bù anchor vô ích (bám đỉnh là hành vi cố định, không phải offset). Lựa chọn duy nhất: PartType=2 (orb yên, nước rút từ dưới) hoặc PartType=3 (nước tụt đúng hướng, orb trồi lên). Muốn chuẩn hơn → patch engine (filtertext.dll / binary UI), ngoài tầm ini.
- **PITFALL — control dims phải ≈ sprite dims**: bar dọc chuẩn của game `防沉迷进度条.ini` → `[OnlineTime_Image] Width=10 Height=306` với sprite 9x307 (gần bằng nhau). Đặt control `14x104` trong khi sprite 128x128 → engine cắt sai tỉ lệ → orb "giật lên". Khi thay sprite vuông: set `[X]` + `[X_Image]` = đúng kích thước sprite (128x128).
- **PITFALL — có 2 chỗ `PartType=1`** trong 顶部控制条.ini (Mana + Stamina): khi patch bytes phải định vị bằng context (tìm `[Mana_Image]` trước, rồi replace `PartType` đầu tiên SAU vị trí đó), không replace toàn file.

[Life_Text]       ; text con
```

## Bảng nhiệm vụ (Task Trace) trong cửa sổ `battle_select` (17/09/2026)

Control engine biết cho cửa sổ này: `Main, btn_close, btn_prevpage, btn_nextpage, info_1..4, scroll_bar, scroll_bar_Btn, btnShop`
— thêm section mới KHÔNG render. **`btn_close` là control DUY NHẤT bấm vào tự đóng cửa sổ** ⇒ tiêu đề phải nằm ở
ô chữ `info_*` (chữ do `script/tasktrace/ui.lua` ghi qua tham số 2 của `PushInfo`) hoặc ở nút page, KHÔNG được ở `btn_close`.
Không có control collapse/minimize cho cửa sổ này — đừng hứa "thu gọn": chỉ có kéo khung (`Moveable=1`) hoặc ẩn bằng X rồi mở lại.
Layout chốt đầy đủ toạ độ, danh sách "cái KHÔNG thể", sprite không tồn tại, và **quy trình lưu bản tốt + rollback có verify md5**:
xem `references/tasktrace-panel-layout.md`. Sửa ini an toàn (bytes GBK/TCVN3 + CRLF): `scripts/ini_edit.py`.

## Chữ tiếng Việt trong `.ini` = **TCVN3** (17/09/2026)

`Label=`/`Tip=` trong ini client là **TCVN3** (font v3 ABC), KHÔNG phải UTF-8/GBK. Muốn đổi chữ:
encode bằng `vietnamese-conversion` (npm): `toTCVN3('Nhiệm vụ','unicode')` → `"NhiÖm vô"` (bytes `4e6869d66d2076f4`), luôn
`toUnicode(x,'tcvn3')` để verify roundtrip. Ví dụ: `Đổi Camp` → `§æi Camp` (`a7e669...`).
⚠️ Nhãn nhận từ mod/tác giả khác có thể **sai chính tả sẵn** — ca thật: mod Task Trace ghi `Theo dâi nhiÖm vô`
(TCVN3 của "Theo dâi" = typo của "Theo dõi") → user báo sai chính tả; phải decode ra UTF-8 rồi sửa, đừng copy byte thô.

## Kéo/di chuyển cửa sổ trong game = `Moveable=1` trong `[Main]` (17/09/2026)

Muốn 1 cửa sổ **di chuyển được bằng chuột trong game** (như thanh máu): thêm/đổi `Moveable=1` trong `[Main]` của ini cửa sổ đó.
Bằng chứng trong client bạn: `ui/ctc/Íæ¼ÒÐÅÏ¢Ö÷½çÃæ.ini` (cửa sổ chứa thanh máu — `DummyWnd=1`, `Trans=0`,
`ToolBoxSchema=¹¤¾ß¿ØÔ´Ìõ.ini`) có `Moveable=1`; các cửa sổ khác (`工具控制条.ini`, `battle_select.ini`) đều `Moveable=0`.
Không thấy file lưu vị trí kéo trong `Client/` (chưa xác nhận engine có nhớ vị trí sau khi thoát game — cần user test rồi
kiểm lại mtime/nội dung ini: nếu engine tự ghi lại toạ độ thì file ini sẽ đổi mtime).

## ⚠️ PITFALL — KHÔNG thêm section mới vào .ini

Engine **chỉ render các control nó đã biết**: section khai trong `Button0..N` + sub-section theo pattern `X_Image`/`X_Text`. Thêm section lạ (`[BgLife]`, `[BgMana]`) vào cuối file → **engine bỏ qua hoàn toàn**, kể cả khi:
- CRLF đúng chuẩn
- Thêm `Button6=BgLife` vào [Main]
- Ảnh trỏ tới .spr hợp lệ

**Cách đúng để thêm/đổi visual:** chỉ sửa section ĐÃ tồn tại (đổi `Left/Top/Width/Height/Image`) HOẶC thay file .spr bằng file khác cùng tên.

**⚠️ ĐANG TEST (8/2026) — thêm control MỚI qua `Button<N>`:** skill `vltk-client-modding` rule #2 khẳng định "sections declared in [Main] via Button0..N WITH full button pattern DO render" (lấy từ reference mod UI+3) — mâu thuẫn với kinh nghiệm "Button6=BgLife không render" ở trên. Thí nghiệm đang chạy: thêm **2 orb góc dưới màn hình** (orb đỏ máu trái, orb xanh mana phải) bằng:
- `Button6=OrbLife` + `Button7=OrbMana` trong `[Main]`
- Section `[OrbLife]` đầy đủ: `Left/Top/Width/Height=128/128/Part=1/ClassType=Player_Life` + sub `[OrbLife_Image]` (`Image=\Spr\Ui3\主界面\orb_mau.spr`, `PartType=2`)
- Sprite mới copy vào `spr/Ui3/主界面/` với **tên ASCII** (`orb_mau.spr`, `orb_xanh.spr`) — né GBK hoàn toàn

Kết quả chưa xác nhận (user chưa test khi session kết thúc). Nếu render → new control qua ini KHẢ THI (cần Button<N> + section đủ `ClassType` + `_Image` con) → sửa rule này. Nếu không → xác nhận hard limit, giữ nguyên "chỉ sửa section có sẵn".

## ⚠️ PITFALL — Image= chỉ nhận .spr

Verify: 579/579 tham chiếu `Image=` trong toàn bộ ui/ctc đều `.spr` — PNG/BMP không load được qua Image= (dù game.exe có strings `.bmp`/`.jpg`). Muốn ảnh mới → cần convert sang .spr (tool SPR editor cộng đồng JX1) hoặc dùng sprite có sẵn.

## .spr format (header)

```
53 50 52 00        "SPR\0"
xx xx              width  (uint16 LE)
yy yy              height (uint16 LE)
zz zz zz zz        field 8-11 (uint32 LE): 0 = SINGLE FRAME (an toàn), nonzero = sprite sheet
...data nén riêng của game (chưa reverse)
```

- **Field 8-11 = 0 → 1 frame duy nhất → load được.** Nonzero = sprite sheet → engine đúp hình ngang; zero hóa sheet → crash game.
- Thanh máu/mana mặc định: `spr/Ui3/主界面/生命条.spr` (HP, 106x11, GBK `ÉúÃüÌõ.spr`) và `内力条.spr` (MP, `ÄÚÁ¦Ìõ.spr`). Sprite tròn có sẵn: `spr/Ui3/minimap/frame_all.spr` (176x147), `spr/Ui3/self_info/frame_sel_avata.spr`.
- ✅ **8/2026: user đã có tool convert riêng — orb.spr/orb_mana.spr 128x128 (14255B, single frame) do user tự convert thay vào thanh máu/mana CHẠY ĐƯỢC.** Vậy sprite hợp lệ KHÔNG nhất thiết phải lấy từ game — miễn đúng header + single frame. Pitfall "tool ngoài crash" hôm 5/8 là do tool đó xuất header/encoding khác, không phải mọi tool đều hỏng.
- Thay sprite: backup trước (`rename 生命条.spr 生命条.spr.bak`), `put` file mới cùng tên, giữ `.bak` để rollback.

## ⚠️ PITFALL — GBK filename + CRLF

- Tên file Trung trên share là **GBK**. smbclient với tên UTF-8 → `NT_STATUS_OBJECT_NAME_NOT_FOUND`. **Phải dùng đúng byte GBK** — lấy chuỗi mojibake từ `ls` output (vd `¶¥²¿¿ØÖÆÌõ.ini`) rồi dùng nguyên chuỗi đó trong `cd`/`get`/`put`.
- Decode tên file: bytes → `decode('utf-8')` → `encode('latin-1')` → `decode('gbk')` = tên thật.
- `.ini` dùng **CRLF**. Sửa bằng Python: đọc bytes, `replace` giữ nguyên `\r\n`, KHÔNG append block LF-only (nghi ngờ parser nuốt section lạ line-ending). Kiểm tra sau khi sửa: `d.count(b'\n') - d.count(b'\r\n') == 0`.
- File nội dung cũng GBK — khi grep/iconv dùng `iconv -f GBK -t UTF-8`.

## Workflow an toàn (luôn làm)

1. Download file về `/tmp` (`get`)
2. Sửa bằng Python bytes (preserve CRLF + GBK), assert mỗi replace count==1
3. **Backup bản gốc trên server**: `rename x.ini x.ini.bak_<tag>` — rollback = rename ngược
4. `put` lên, rồi `get` lại + `diff` verify upload khớp
5. User chạy game test (không thể tự verify visual)

## Verification sau khi user thay .spr

`xxd` 8 byte đầu: check `SPR\0` + width/height khớp section trong ini (vd 120x120).

## Tham khảo
- `references/gbk-smbclient.md` — recipe decode tên file GBK + ví dụ mojibake