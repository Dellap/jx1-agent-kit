# START HERE — đọc file này trước (1 trang, ~2k token)

Repo này để **AI/agent đọc nhanh rồi sửa JX1/VLTK**, không phải để người mới học từ đầu.
Mục tiêu: **rút ngắn đường mò và tiết kiệm token**. Đọc đúng 1–2 file là đủ cho 90% việc.

## 0. Luật tiết kiệm token (bắt buộc)

1. **Grep trước, đọc sau** — `search_files pattern="..." path=skills/|sources/` rồi mới `read_file`.
   Không bao giờ `cat`/đọc cả file 10k token để tìm 1 hàm.
2. **Đọc theo offset** — file dài (>=300 dòng) chia 2–3 lần đọc, bám theo số dòng grep trả về.
3. **Code đã có sẵn ở `sources/`** — grep local thay vì SSH `cat` từng file (SSH chỉ để sửa/ghi).
4. **Đúng 1 file skill cho 1 việc** — theo bảng định tuyến dưới đây, đừng load cả bộ.
5. **Xong việc → cập nhật lại skill** (patch file tương ứng). Kinh nghiệm không ghi lại = lần sau trả giá lại.

## 1. Bảng định tuyến: việc gì → đọc file nào

| Việc cần làm | Đọc file | Ghi chú |
|---|---|---|
| Vận hành/khởi động/sửa lỗi server JX1 (WSL2) | `skills/vltk-server-ops/SKILL.md` | 5 service, thứ tự start, FixIp, log chẩn đoán |
| Bot/SimCity/SimBot: dân thành thị, kéo xe, chiến loạn, TTDC, bot bán hàng | `skills/jx1-simbot/SKILL.md` + `references/engine-api.md` | `references/lessons.md` = nhật ký bug đã trả giá |
| Sửa skill/giá trị theo cấp (Lua `.lua`, `skills.txt`, `Missile.txt`) | `skills/vltk-skill-data-modding/SKILL.md` + `references/*.md` | 3 lớp phải khớp: skills.txt ↔ .lua ↔ Missile.txt |
| Mod UI client (.ini, .spr, pak, GBK filename) | `skills/vltk-client-modding/SKILL.md`, `skills/jx1-client-ui-modding/SKILL.md` | Engine chỉ render control đã khai báo |
| Cài bản JX6/JX8/JXWin, shop `goods/buysell`, mission, Tống Kim, auto/RE, inject DLL | `skills/jx1-hqvl-knowledge/SKILL.md` + `references/script-api.md` | Kho tri thức cộng đồng HQVL, index 66 tài liệu |
| Thêm 6 ô đồ nhanh (UI 3+6 ô) / launcher CTC | `skills/runbooks/ui-3x6-slots.md` + `sources/client-sample/` | **chạy `scripts/check-client-base.py <Client>` trước** để biết có lệch hay không |
| **Cài 1 mod client** từ `Update/<tên mod>/` (đọc README của mod rồi copy/ghi đè) + chẩn đoán "bấm không thấy gì" | `skills/vltk-client-modding/references/mod-install-and-debug.md` | Kiểm cú pháp Lua trước khi đẩy; nhiều file trong `2_server/` của mod chỉ là **ghi chú**, đè là mất file thật |
| Bảng nhiệm vụ TaskTrace / cửa sổ `battle_select` (ca 17/09) | `skills/vltk-client-modding/references/jx1-battleselect-taskextrace.md` + `skills/jx1-client-ui-modding/references/tasktrace-panel-layout.md` | `battle_select.ini` là cửa sổ **NEO dùng chung** — KHÔNG đè ini gốc |
| Bot **đứng bán** không mở / theme thiếu cửa sổ UI | `skills/jx1-simbot/SKILL.md` (mục quy luật tên file) + `skills/jx1-simbot/scripts/fix_shop_stall_theme.py` | Theme đang chạy thiếu cửa sổ `摆摊*`; tên file phải là **mojibake** |
| Tra cứu EbookJx 3.0 (cài server JX offline, goods/shop, spr, font TQ…) | `skills/jx1-hqvl-knowledge/references/ebookjx3-notes.md` | 682 dòng / 26 bài, có mục "tài liệu không nói rõ" |
| Vào máy Windows `<GAME_HOST_IP>` / WSL2 từ xa (SSH, portproxy, wsl.exe) | `skills/windows-remote-admin/SKILL.md` + `references/wsl2-jump-access.md` | |

## 2. Checklist sửa bất kỳ thứ gì (đừng bỏ bước)

```
1. Xác định file thật trên server   → grep trong sources/ hoặc ssh jx1 'grep -rn ...'
2. Backup                           → cp f f.bak-$(date +%Y%m%d_%H%M%S)   (hoặc rename trên share SMB)
3. Sửa (giữ encoding + CRLF)         → .lua/settings = iso-8859-1/TCVN3; .ini client = CRLF
4. Verify nội dung                   → md5 / diff trước–sau, đếm {} cân bằng với Lua
5. Restart đúng cấp                  → script nạp RAM lúc start ⇒ PHẢI restart jx_linux_y
6. Test trong game                   → user tự test (agent không tự mở client)
7. Ghi lại kinh nghiệm               → patch skill tương ứng (1–3 dòng)
```

## 3. Không được làm

- ❌ Không đọc/ghi bừa khi server đang chạy mà không backup (mất rollback = mất buổi).
- ❌ Không tin state engine sau 1 lần gọi (`SetTmpCamp` không stick, idx NPC bị tái dùng).
- ❌ Không sửa `skills.txt` mà không đối chiếu `.lua` + `Missile.txt` (thuộc tính rỗng âm thầm).
- ❌ Không dùng file đã patch/hex của người lạ (rủi ro mã độc) — tự patch.
- ❌ Không hardcode IP LAN vào file daemon WSL nội bộ (chỉ `bishop.cfg` được dùng IP LAN).
- ❌ Không dán thông tin riêng (IP nội bộ, tên máy, mật khẩu, tên người) vào tài liệu khi chia sẻ cho người khác
  — repo này đã được lọc bằng `scripts/audit.sh`, phần bạn tự thêm cũng phải sạch.
- ❌ Không đặt **tên Unicode** cho file/thư mục tiếng Trung khi copy vào client: mọi tên trong client là **mojibake**
  (bytes GBK đọc như Latin-1) — đặt sai tên là engine không tìm thấy (xem `vltk-client-modding`).
- ❌ Không dùng `pcall` trong script client (engine Lua đời cũ, `pcall` làm script dừng giữa chừng); kéo cửa sổ = `Moveable=1`;
  chữ hiển thị trong `.ini` client = **TCVN3**, không phải UTF-8/GBK.
- ❌ Không đè `ui/<theme>/battle/battle_select.ini` của client (cửa sổ neo dùng chung: pet, kỹ năng sống, vòng quay, PK Tống Kim, shop động).

## 4. Nếu chỉ có 60 giây

```
skills/vltk-server-ops/SKILL.md   # server chạy thế nào, restart ra sao
skills/CHEATSHEET.md              # path, port, log, lệnh hay dùng (trang facts)
```
