# Runbook: UI 3+6 ô đồ nhanh + launcher CTC (HoiQuanVoLam.exe)

## Khi nào dùng
Ai/agent được yêu cầu "thêm UI 3+6 ô", "bật 6 ô đồ nhanh", "chạy client bằng launcher CTC".

## Kết quả cần đạt
1. Màn hình chính có **9 ô đồ nhanh** (`Item_0`..`Item_8`) — 3 ô mặc định + 6 ô bật thêm.
2. Toolbar nút chức năng **không đè** lên dãy ô.
3. Client khởi động bằng **`HoiQuanVoLam.exe`** nhưng vẫn vào **server của mình**.

## Dữ liệu mẫu sẵn trong repo
`sources/client-sample/` (12K, đã lọc tên server):
```
orig/unpack_out/ui/ctc/…      ← 2 file GỐC bóc từ ui.pak (dùng làm chuẩn đối chiếu)
mod3x6/Ui/ctc/…               ← bản mod 800x600 (bản dùng được)
mod3x6/Ui/ctc1024/… mod3x6/Ui/Ui3/…  ← biến thể 1024x768 (KHÔNG dùng)
mod3x6/spr/Ui3/thanhhienthi/thanh.spr ← sprite nền đi kèm mod (359x67, single-frame)
config/{config.ini,package.ini,uicommon.ini,resolution.ini,HoiQuanVoLam.ini,fps_events.ini}
```
Tên file GBK ↔ ASCII trong repo: `toolbar.ini` = `顶部控制条.ini`, `main_player_info.ini` = `玩家信息主界面.ini`.
Khi ghi lên client phải dùng **tên GBK gốc** (`ls` share sẽ in ra dạng `¹¤¾ß¿ØÖÆÌõ.ini`).

## Bước 0 — BẮT BUỘC: kiểm "nền" client trước khi áp

```bash
python3 scripts/check-client-base.py <đường-dẫn-thư-mục-Client>
```
- `exit 0` + **"GỐC + CÙNG NỀN"** → áp bộ số bên dưới.
- `exit 0` + **"ĐÃ ÁP 6 ô"** → không cần làm lại (muốn về gốc thì rollback backup).
- `exit 1` (**MISMATCH**) → **DỪNG**: client nền khác (theme khác CTC, resolution/layout khác, toolbar khác
  version) ⇒ số `Left/Top` trong runbook **sẽ lệch**. Phải `diff` 2 ini của máy đó với
  `sources/client-sample/orig/unpack_out/ui/ctc/*` rồi tự tính lại, hoặc lấy đúng biến thể
  (`sources/client-sample/mod3x6/Ui/{ctc,ctc1024,Ui3}`).

⚠️ Repo **không kèm `unpack.exe`** (binary Windows) — nếu client chỉ có file trong `ui.pak`, hoặc tự bóc bằng
`Tools/unpacktool/unpack.exe`, hoặc chỉ cần **đặt file lỏng** vào `ui/ctc` (file lỏng đè pak, không cần bóc).

## Các bước (client nền 800x600)

1. **Backup** (rollback = rename ngược):
   ```bash
   cd <GAME_ROOT>/Client
   cp "ui/ctc/Íæ¼ÒÐÅÏ¢Ö÷½çÃæ.ini" "ui/ctc/Íæ¼ÒÐÅÏ¢Ö÷½çÃæ.ini.bak-$(date +%Y%m%d)"
   cp "ui/ctc/¹¤¾ß¿ØÖÆÌõ.ini"     "ui/ctc/¹¤¾ß¿ØÖÆÌõ.ini.bak-$(date +%Y%m%d)"
   ```

2. **Bật 6 ô** trong `ui/ctc/玩家信息主界面.ini`: bỏ dấu `;` ở 6 section `[Item_3]`..`[Item_8]` và set đúng số (bản mod 800x600):

   | Section | Left | Top | Ghi chú |
   |---|---|---|---|
   | `[Item_3]` | **282** | **494** | `HaveBgColor=1` |
   | `[Item_4]` | **322** | 494 | |
   | `[Item_5]` | **362** | 494 | |
   | `[Item_6]` | **402** | 494 | |
   | `[Item_7]` | **442** | 494 | |
   | `[Item_8]` | **482** | 494 | |

   `Width=36 Height=36` mỗi ô, **bước 40px**. Gốc trong pak để 6 section này ở dạng comment với `Top=550`, `Left=129/167/205/243/281/320` → **không dùng số gốc**, dùng bảng trên.

3. **Dời nền ô nhập chat** — cùng file, section `[InputBack]`: `Left=228→221`, `Top=530→491` (nhường chỗ cho dãy ô).

4. **Chỉnh toolbar** `ui/ctc/顶部控制条.ini` (giữ `Top=534`), sửa `Left`:

   | Section | Gốc | Mod | | Section | Gốc | Mod |
   |---|---|---|---|---|---|---|
   | `[ItemEx]` | 301 | **300** | | `[Team]` | 347 | **348** |
   | `[ChatRoom]` | 232 | **228** | | `[Run]` | 370 | **372** |
   | `[Status]` | 255 | **252** | | `[Faction]` | 406 | **408** |
   | `[Items]` | 278 | **276** | | `[Sit]` | 429 | **432** |
   | `[Task]` | 497 | **504** | | `[Horse]` | 451 | **456** |

5. **Sprite nền**: chép `thanh.spr` vào `Client/spr/Ui3/thanhhienthi/thanh.spr` (tạo thư mục nếu chưa có).

6. **Ghi lên client**: đặt 2 file `.ini` vào `Client/ui/ctc/` — **file lỏng đè lên `ui.pak`, không cần repack**. `package.ini` load `0=ui.pak` trước nhưng file trên đĩa thắng.

7. **Verify**:
   ```bash
   python3 - <<'EOF'
   d=open('ui/ctc/Íæ¼ÒÐÅÏ¢Ö÷½çÃæ.ini','rb').read()
   print('LF-only =', d.count(b'\n')-d.count(b'\r\n'))   # phải = 0
   print('Item_8 bật:', b'[Item_8]' in d)
   EOF
   ```
   Đối chiếu với `sources/client-sample/mod3x6/Ui/ctc/main_player_info.ini` (diff phải chỉ khác encoding/CRLF).

8. **Test**: vào game xem 9 ô + toolbar. Người dùng tự chạy client (agent không mở client).

## Launcher CTC = `HoiQuanVoLam.exe`

- `Client/HoiQuanVoLam.ini` chỉ chứa `[Launcher] Theme=current` → **launcher không giữ IP server**.
- Nó lấy server từ: `Client/config.ini` → `[Server] ServerOn=0 / GameServPort=5622 / DenialPort=5623`
  và `Client/UserData/uicommon.ini` → `[Region_0] 0_Title=<tên server> / 0_Address=<IP>` (`[Login] SelServerRegion=0`).
  Client chạy cùng máy server ⇒ `0_Address=127.0.0.1`; máy khác ⇒ IP LAN.
- `config.ini [Launcher] profile=2` chọn profile giao diện launcher; `[Client] Theme=CTC` chọn theme UI.
- ⚠️ **Bộ skin HQVL đi kèm `game.exe` + `one.dll` + `ddraw.dll` + `VLTK_ui.dll` của riêng nó.** Chỉ lấy
  **launcher + skin** (`HoiQuanVoLam.exe`, `HoiQuanVoLam.ini`, `assets/`, `spr/Ui3/`, `ui/`, `resolution.jsonc`,
  `fps_events.ini`). **KHÔNG copy `game.exe`/`one.dll`/`ddraw.dll`** từ bộ HQVL — client sẽ login vào server HQVL
  và hỏng kết nối server nhà (đã từng dính lỗi này).
- Chạy lại kiểu stock: phục hồi `game.exe` từ bản Client sạch + bỏ `one.dll`/`ddraw.dll` (Launcher.exe cũng gọi
  `game.exe` cùng thư mục → khác biệt nằm ở `game.exe`, không ở launcher).
- Các launcher gặp trong bản này: `Launcher.exe` (stock), `HoiQuanVoLam.exe` (CTC), `VLTK_SmoothPlugin_Launcher.exe` (plugin smooth).

## Rollback
1. `rename`/`mv` file `.bak-YYYYMMDD` về tên gốc.
2. Xoá `Client/spr/Ui3/thanhhienthi/thanh.spr` nếu vừa thêm (hoặc phục hồi bản cũ).
3. Nếu đã copy nhầm `game.exe`/`one.dll`/`ddraw.dll` của HQVL → phục hồi từ bản Client sạch.

## Pitfalls (đã trả giá)
- **Chỉ dùng biến thể 800x600.** Bản `ctc1024`/`Ui3` là 1024x768; client nền 800x600 + ResolutionHook tự scale →
  dùng bản 1024 là lệch hết.
- Engine chỉ render control nó đã biết: `Item_N` là control có sẵn (đang bị comment), **đừng thêm section mới lạ**.
- `.ini` phải **CRLF**; ghi qua SMB/WinSCP phải giữ **tên file GBK** và không đổi encoding (iso-8859-1).
- `Image=` chỉ nhận `.spr` (PNG/BMP bị bỏ qua âm thầm).
- Đừng sửa header `.spr` sang `0,0` cho file sheet-encoded (crash game) — sprite nền ở đây vốn đã single-frame
  (`frameW/frameH = 0,0`, 359x67).
