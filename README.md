# jx1-agent-kit — bộ não cho AI sửa JX1/VLTK

Repo này là **bộ skill + dữ liệu thật** để một AI/agent (Claude Code, Codex, Cursor…) đọc vào là
**hiểu ngay hệ thống Võ Lâm Truyền Kỳ / JX1 đang chạy** và **sửa được trong vài phút**, thay vì mò 30–60 phút.

> Mục đích duy nhất: **rút ngắn đường mò và tiết kiệm token.**

## Dành cho AI: bắt đầu ở đâu

1. Đọc `START-HERE.md` (1 trang): bảng định tuyến *việc gì → đọc file nào* + checklist sửa an toàn.
2. Tra facts (path/port/log/lệnh) ở `skills/CHEATSHEET.md` — không cần dò lại server.
3. Mở đúng **1** skill theo bảng định tuyến, grep trong `sources/` thay vì SSH `cat` từng file.
4. Sửa xong → patch lại skill tương ứng 1–3 dòng (kinh nghiệm không ghi lại là lần sau trả giá lại).

Prompt gợi ý:

```text
Đọc START-HERE.md và skills/CHEATSHEET.md trong repo này.
Nhiệm vụ: <mô tả việc>. Chỉ mở file cần thiết theo bảng định tuyến, grep trước khi đọc.
Trước khi sửa: nêu file sẽ đổi + backup + cách verify. Không dùng file patch của người lạ.
```

## Cấu trúc

```
START-HERE.md                 # đọc đầu tiên: định tuyến + luật tiết kiệm token + checklist
skills/
  CHEATSHEET.md               # facts: máy, port, path, log, đơn vị (frame=1/18s), lệnh hay dùng
  vltk-server-ops/            # vận hành server <GAME_HOST_IP> (WSL2): 5 service, FixIp, chẩn đoán log
  jx1-simbot/                 # SimBot/SimCity: kiến trúc, engine API, settings, nhật ký bug
  vltk-skill-data-modding/    # sửa skill 3 lớp: skills.txt ↔ .lua ↔ Missile.txt (+ 3 từ điển cột)
  vltk-client-modding/        # mod UI client (.ini/.spr/pak, GBK, pak override)
  jx1-client-ui-modding/      # mod UI/SPR client bản khác (mapping PartType, layout)
  jx1-hqvl-knowledge/         # kho tri thức cộng đồng HQVL (66 tài liệu) + index
  runbooks/                   # runbook việc cụ thể: ui-3x6-slots.md (6 ô đồ nhanh + launcher CTC)
  */references/               # kiến thức chuyên sâu: mod-install-and-debug.md, jx1-battleselect-taskextrace.md,
                              #   tasktrace-panel-layout.md, ebookjx3-notes.md, engine-api.md, lessons.md…
  */scripts/                  # script chạy lại được: fix_shop_stall_theme.py, instrument-client-protocol.py
  windows-remote-admin/       # vào Windows/WSL2 từ xa: SSH, portproxy, wsl.exe, schtasks
sources/
  simbot/                     # CODE THẬT của hệ SimBot (Lua + settings) để grep offline
  hqvl-docs-text/             # 66 tài liệu HQVL đã bóc text (grep nhanh, không cần mở HTML)
  client-sample/              # file client mẫu (orig từ ui.pak + mod 3+6 ô + config) — verify offline
scripts/audit.sh              # quét secret/PII — chứng minh repo này đã được lọc sạch
NOTICE.md                     # nguồn gốc & bản quyền
```

## Luật sắt (rút từ lỗi thật)

- Script server **nạp RAM lúc start** ⇒ đè file phải **restart `jx_linux_y`**; luôn backup `.bak` trước.
- `skills.txt` sửa mà không đối chiếu `.lua` + `Missile.txt` ⇒ thuộc tính **rỗng âm thầm, không báo lỗi**.
- Lua JX1 là **Lua 4.x**: không `string.match/gsub`; env timer **không thấy global** ⇒ phải cache refs.
- Engine **không stick** state bot (`SetTmpCamp`) và **không có `SetNpcPos`** ⇒ enforce mỗi tick / pre-spawn.
- Chỉ `bishop.cfg` được dùng IP LAN; goddess/s3relay/servercf phải `127.0.0.1`.
- Không dùng file patch/hex của người lạ — rủi ro mã độc.

## Placeholders — điền giá trị của bạn

Repo **đã bỏ hết thông tin máy/hạ tầng riêng**. Gặp các token dưới đây thì thay bằng giá trị của bạn
(`grep -rn "<[A-Z_]*>" .` để liệt kê chỗ cần sửa):

| Placeholder | Ý nghĩa |
|---|---|
| `<GAME_HOST_IP>` | IP LAN của máy chạy server (client ngoài trỏ vào đây) |
| `<GAME_HOST2_IP>` | máy chủ JX1 thứ hai, nếu có |
| `<LAN_IP>` | IP LAN bất kỳ trong ví dụ |
| `<WIN_USER>` | user Windows dùng để SSH/WSL |
| `<PC_NAME>` | tên máy Windows |
| `<WSL_DISTRO>` / `<WSL_HOSTNAME>` | distro WSL2 chạy server + hostname của nó |
| `<SMB_USER>` | user SMB để vào share client |
| `<JX1_ROOT>` | thư mục client JX1 trên Windows (vd `D:\Game\jx1`) |
| `<SERVER_NAME>` | tên server JX1 của bạn (hiện trong bảng chọn server của client) |
| `ssh jx1` | alias SSH tới máy server — thêm vào `~/.ssh/config` |

## Ghi chú

- Repo phục vụ **một server private tự host + nghiên cứu/offline**. Không kèm binary, không kèm client.
- IP trong repo là **IP LAN nội bộ**; không có mật khẩu/khoá trong repo (đã kiểm bằng `scripts/audit.sh`).
- Nguồn gốc tài liệu cộng đồng & bản quyền: xem `NOTICE.md`.
