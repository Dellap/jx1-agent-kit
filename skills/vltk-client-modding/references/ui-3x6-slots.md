# UI 3+6 ô đồ nhanh + launcher CTC — TRỎ SANG RUNBOOK (bản duy nhất)

⚠️ Nội dung đã **gộp về một chỗ** để khỏi lệch bản: runbook đầy đủ (số `Left/Top` từng section, bước backup/verify/rollback,
launcher `HoiQuanVoLam.exe`, cảnh báo skin HQVL) nằm ở:

- **`skills/runbooks/ui-3x6-slots.md`** (repo `jx1-agent-kit`, 116 dòng) — bản chính, đọc file này trước khi làm.

Điểm bắt buộc nhớ (chi tiết trong runbook):
1. **Chạy `python3 scripts/check-client-base.py "<thư mục Client>"` TRƯỚC** — `exit 1` = nền khác, DỪNG, đừng áp số.
2. Chỉ dùng biến thể **800x600** (`sources/client-sample/mod3x6/Ui/ctc/`); biến thể `ctc1024`/`Ui3` là 1024x768 ⇒ lệch hết.
3. `.ini` phải **CRLF** + tên file **GBK**; file lỏng trong `ui/ctc` đè `ui.pak` (không cần repack).
4. Backup trước khi ghi; test cuối do người dùng chạy client.
