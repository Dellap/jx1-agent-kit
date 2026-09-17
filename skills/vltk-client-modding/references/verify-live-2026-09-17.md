# Kiểm chứng chỉ-đọc (17/09/2026) — số/đường dẫn THẬT, và các câu trong SKILL.md đã LỖI THỜI

> ⚠️ Mọi đường dẫn tuyệt đối trong file này là **ví dụ của một máy cụ thể** (`<GAME_ROOT>`, `<WORK_DIR>`, `<DRIVE>:` …). Máy khác hãy tự xác định *game root* = thư mục cha của `Client/`.


Rà soát chỉ-đọc (nc / `ssh <SSH_ALIAS>` / ls / grep / md5 / od — không sửa gì) nhằm chốt lại số liệu sau khi
SKILL.md gộp từ skill cũ `jx1-client-ui-modding`. **Ô nào đánh ⛔ là câu trong SKILL.md đang SAI/đã cũ — sửa khi có dịp.**

## Layout share THẬT (`$GAME_ROOT/`)

```
Client/    Server/(chỉ jxser.tgz)    UI/    Tools/(chỉ unpacktool)    Update/    + vài .rar/.zip
```

- ⛔ Không tồn tại `TOOL/`, `CLIENT/`, `SERVER/` như block "Client layout" ở PHẦN GỘP ghi. Không có `ui1600`.
- ⛔ **`SPRViewer/`, `ResolutionHook.0.0.2/`, `UI+3/`, `TOOL/ui1600/` KHÔNG tồn tại** (find tới maxdepth 6 trên
  `$WORK_DIR`). Mục "Tools on server (TOOL/)" trong SKILL.md mô tả đồ đã bị xoá.
  Resolution hook hiện là **file trong Client/**: `filtertext.dll` + `filtertext_orig.dll` + `resolution.jsonc` + `resolution.ini`.
- Tool dùng được: `Tools/unpacktool/{unpack.exe, Decoder.exe, paths.txt}` ✅ (khớp dòng "đường dẫn thật hiện nay" của SKILL.md).
- `UI/` = bộ skin HQVL: `game.exe, one.dll, ddraw.dll, D3DImm.dll, VLTK_ui.dll, HoiQuanVoLam.exe, HoiQuanVoLam.ini,
  assets/, spr/, ui/, dgVoodoo.conf, resolution.jsonc, fps_events.ini, vdk.dll, filtertext*.dll` ✅ (khớp mô tả cũ).
- Nơi gom giải nén `<UNPACK_DIR>\` ✅ tồn tại.

## Số đã verify ✅

| Hạng mục | Giá trị thật |
|---|---|
| `resolution.ini` | `Width=1600 Height=900 Log=0 PatchGameInit=1` |
| `config.ini` | `[Server] ServerOn=0 GameServPort=5622 DenialPort=5623`; `[Client] Theme=CTC`; `[Launcher] profile=2` |
| `HoiQuanVoLam.ini` | chỉ `[Launcher] Theme=current` ✅ (launcher không giữ IP — đúng) |
| `uicommon.ini` | `[Region_0] Count=8 / 0_Title=<SERVER_NAME> / 0_Address=127.0.0.1` (KHÔNG dư `/`); `[Login] SelServerRegion=0` |
| Enum protocol | server/client giống y từng dòng; `TASKTRACE=#17 EXPRANK=#18 EXPRANK_STRING=#19` (19 entry, có `emSCRIPT_PROTOCOL_COUNT`@8) |
| md5 `protocol.lua` | server `dcad3236…` 4232B ≠ client `c6f4b262…` 4353B — **enum giống, md5 khác; đừng so md5** |
| Line ending | `Client/script/protocol.lua` = 179 LF, 0 CRLF (thuần LF ✅) |
| `battle_select.ini` đang chạy | md5 **`60b64d14ce51c24aca4ef0db6d6beb2d`** 2025B — ⛔ md5 `7d00fae1…` trong SKILL.md đã cũ |
| `thanh.spr` | `53 50 52 00 \| 67 01 \| 43 00 \| 00 00 00 00 \| 01 00 00 01` → 359x67, single frame ✅ (khớp SKILL.md) |
| `生命条.spr`/`内力条.spr` | `ÉúÃüÌõ.spr` 2004B, `ÄÚÁ¦Ìõ.spr` 2004B ✅ |

Sprite có mặt: `spr/Ui3/minimap/frame_all.spr` ✅, `spr/Ui3/self_info/frame_sel_avata.spr` ✅,
`spr/Ui3/Ö÷½çÃæ/·À³ÁÃÔ½ø¶ÈÌõ.spr` (防沉迷进度条) ✅, `spr/Ui3/thanhhienthi/thanh.spr` ✅.

## Câu LỖI THỜI cần sửa

1. ⛔ "không có `ui/ui3`" → thật ra `Client/ui/` = `ctc, one, ui3, ui_ctc_v2, ui_vlmp`; `ui/ui3/battle/battle_select.ini` đang tồn tại.
2. ⛔ md5 battle_select.ini `7d00fae1…` → `60b64d14…` (kèm snapshot mới `Update/_SAVE_tasktrace_working_20260917_1930/`
   có `md5.txt` + `restore_working.sh`; cây `removed_*` trong đó là ảnh chụp file đã gỡ, KHÔNG có nghĩa client đang thiếu).
3. ⛔ "60 tài liệu HQVL" → `~/jx1-knowledge/text/` hiện có 92 file (bỏ con số cứng).
4. ⛔ Res-hook "patch cửa sổ lên 1920x1080" → cửa sổ game = **1600x900** (`resolution.ini`); 1920x1080 là màn hình Windows.
5. ⛔ `select */script_protocol/protocol_def_gs.lua` → đường dẫn thật `/home/jxser/server1/script/script_protocol/protocol_def_gs.lua`.
6. ⛔ Vị trí chèn `Def` nói 2 kiểu: "(trước `ScriptProtocol:RegProtocolSet(Def)`)" (mục Task Trace) vs Pitfalls
   ("PHẢI TRONG bảng, trước `}` đóng bảng, KHÔNG phải trước RegProtocolSet"). **Pitfalls đúng** — bản kia gây chết protocol.
7. ⛔ Luật tên file "MỌI tên tiếng Trung đều mojibake, `ui/ctc` cũng vậy" → đúng với `spr/`
   (có `Ö÷½çÃæ`, KHÔNG có `主界面`), SAI với `ui/ctc/` (lẫn cả `npc摆摊界面.ini` UTF-8 thật).
8. ⛔ "Tools on server (TOOL/)" → tool nằm trên share Windows (`Tools/`), không phải trong server CentOS.
9. ⛔ Hai luật `Image=`/pcall/workflow/protocol-id bị lặp 2-3 lần ở 2 nửa file sau gộp — gom về phần trên theo đúng
   ghi chú "phần trên là bản chính" ở đầu phần gộp.

## Mâu thuẫn CHƯA GIẢI QUYẾT (cần quyết trước khi mod tiếp)

**Thêm control MỚI qua `Button<N>` có render không?**
- Rule #2 (phần gốc): "Sections declared in [Main] via Button0..N WITH full button pattern DO render" — nói chắc.
- Pitfall ở phần gộp: "Button6=BgLife KHÔNG render… thí nghiệm 2 orb CHƯA có kết quả test".
⇒ Phải chốt sau khi bạn test orb. Trước khi có kết quả: coi như **KHÔNG render**, chỉ sửa section đã có.

**`battle_select.ini` — "CẤM đè" vs thực tế đã đè:** mục "⛔ 2 điều CẤM" cấm ghi đè, nhưng mục Task Trace ghi đã cài
bản mod vào `ui/ctc/battle/` (và `ui/ui3/battle/`). Luật đúng cần phát biểu có điều kiện: đè được, NHƯNG phải giữ
`[btnShop]` (Vòng Quay) ở toạ độ tuyệt đối cũ + `info_1..4` bên trong khung.

## Kiểm tra lại khi cần (lệnh chỉ-đọc, an toàn)

```bash
ssh <SSH_ALIAS> 'ls $GAME_ROOT/Client/ui/'                  # theme list
ssh <SSH_ALIAS> 'md5sum /mnt/e/.../Client/ui/ctc/battle/battle_select.ini'     # md5 bản đang chạy
ssh <SSH_ALIAS> 'od -A d -t x1 -N 16 <file>.spr'                               # header sprite (xxd KHÔNG có trên CentOS 7)
ssh <SSH_ALIAS> 'grep -a -A24 KE_SCRIPT_PROTOCOL /home/jxser/server1/script/protocol.lua'
```
