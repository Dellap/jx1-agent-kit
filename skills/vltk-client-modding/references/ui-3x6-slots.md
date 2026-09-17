# UI 3+6 ô đồ nhanh + launcher CTC — số liệu & cách kiểm nền

Bóc thật từ client JX1 bản CTC (theme `CTC`, base 800x600). Nguồn gốc số liệu:
- gốc: 2 file bóc từ `ui.pak` (`玩家信息主界面.ini`, `顶部控制条.ini`)
- mod: bộ "UI 3 + 6 Ô CTC (1024x768) (800x600)" (bản `Ui/ctc` = 800x600 mới dùng được)

Bộ file mẫu (gốc + mod + biến thể 1024 + sprite + config client) và runbook đầy đủ nằm trong repo
`jx1-agent-kit` (`sources/client-sample/`, `skills/runbooks/ui-3x6-slots.md`).

## Bước 0 — BẮT BUỘC: kiểm nền trước khi áp số

```bash
python3 scripts/check-client-base.py "<thư-mục Client>"
```
- exit 0 + "GỐC + CÙNG NỀN" → áp số dưới.
- exit 0 + "ĐÃ ÁP 6 ô" → không cần làm lại.
- exit 1 + MISMATCH → DỪNG: theme/layout khác ⇒ phải diff với file gốc rồi tính lại.

Cách script quyết định: so `顶部控制条.ini` của client với **cả 2 mẫu** (gốc và mod) sau khi strip CRLF/space —
khớp mẫu nào (lệch ≤4 dòng) cũng là cùng nền; khớp cả hai đều không ⇒ nền khác. Nhận cả tên file GBK
(`\xcd\xe6...`) lẫn tên ASCII đã đổi trong repo (`main_player_info.ini`, `toolbar.ini`).

## Số chuẩn (client 800x600)

`ui/ctc/玩家信息主界面.ini` — bỏ `;` ở 6 section, `Width/Height=36`:

| Section | Left | Top | Ghi chú |
|---|---|---|---|
| `[Item_3]` | 282 | 494 | `HaveBgColor=1` |
| `[Item_4]` | 322 | 494 | |
| `[Item_5]` | 362 | 494 | |
| `[Item_6]` | 402 | 494 | |
| `[Item_7]` | 442 | 494 | |
| `[Item_8]` | 482 | 494 | |

Bước 40px. Gốc (comment trong pak): `Top=550`, `Left=129/167/205/243/281/320` → **không dùng số gốc**.

`[InputBack]` (cùng file): `Left=228→221`, `Top=530→491`.

`ui/ctc/顶部控制条.ini` (giữ `Top=534`): `[ItemEx]`301→300, `[ChatRoom]`232→228, `[Status]`255→252,
`[Items]`278→276, `[Task]`497→504, `[Team]`347→348, `[Run]`370→372, `[Faction]`406→408, `[Sit]`429→432,
`[Horse]`451→456.

Sprite nền: `spr/Ui3/thanhhienthi/thanh.spr` — `SPR\0`, 359x67, frameW/frameH = 0,0 (single-frame), 34198 bytes.

Biến thể 1024x768 (`Ui/ctc1024`, `Ui/Ui3`): file lớn hơn (4002 vs 3552 bytes), `Top` khác (ô đầu 661) —
**chỉ dùng khi client nền 1024**.

## Launcher CTC = `HoiQuanVoLam.exe`

| Thành phần | Nội dung |
|---|---|
| `Client/HoiQuanVoLam.ini` | chỉ `[Launcher] Theme=current` — **không chứa IP server** |
| `Client/config.ini` | `[Server] ServerOn=0 / GameServPort=5622 / DenialPort=5623`; `[Client] Theme=CTC`, `ShowMiniskill=1`; `[Launcher] profile=2` |
| `Client/UserData/uicommon.ini` | `[Region_0] Count=8 / 0_Title=<tên server> / 0_Address=<IP>`; `[Login] SelServerRegion=0` |
| khác | `Launcher.exe` (stock), `VLTK_SmoothPlugin_Launcher.exe` (plugin smooth) — đều gọi `game.exe` cùng thư mục |

⚠️ Bộ skin HQVL đi kèm `game.exe` + `one.dll` + `ddraw.dll` + `VLTK_ui.dll` của riêng nó: copy nguyên bộ vào
client sẽ login sai server và hỏng kết nối server nhà. Giữ skin = chỉ lấy launcher + `assets/`, `spr/Ui3/`,
`ui/`, `resolution.jsonc`, `fps_events.ini`. Về stock = phục hồi `game.exe` từ Client sạch + bỏ `one.dll`/`ddraw.dll`.

## Verify sau khi ghi

```bash
python3 -c "d=open('ui/ctc/<file>.ini','rb').read(); print('LF-only', d.count(b'\n')-d.count(b'\r\n'))"   # phải = 0
```
- Tên file phải giữ **GBK** như gốc; file lỏng trong `ui/ctc` đè `ui.pak` (không cần repack).
- Backup trước: `cp <file> <file>.bak-$(date +%Y%m%d)` (rollback = đổi tên ngược).
- Bước test cuối phải do người dùng chạy game — agent không tự mở client.
