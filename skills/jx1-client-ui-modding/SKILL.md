---
name: jx1-client-ui-modding
description: Use when modding the VoLamTruyenKy (JX1) client UI/sprites.
---

# JX1 / Võ Lâm Truyền Kỳ Client UI Modding

Game client JX1 (Kingsoft 2004 engine). UI = text `.ini` themes + proprietary `.spr` sprites.
Loose files on disk OVERRIDE `.pak` — no repack needed (bài học cốt lõi).

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
