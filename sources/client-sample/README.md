# sources/client-sample — mẫu file client để đối chiếu (đã lọc thông tin)

Bộ file tối thiểu (12K) để agent **verify offline** mà không cần truy cập máy client.
Trích từ client JX1 (bản CTC, client nền 800x600).

```
orig/unpack_out/ui/ctc/toolbar.ini            ← GỐC bóc từ ui.pak (= 顶部控制条.ini)
orig/unpack_out/ui/ctc/main_player_info.ini   ← GỐC bóc từ ui.pak (= 玩家信息主界面.ini)
mod3x6/Ui/ctc/…                               ← mod "UI 3 + 6 Ô" bản 800x600 (bản dùng được)
mod3x6/Ui/ctc1024/… , mod3x6/Ui/Ui3/…         ← biến thể 1024x768 của cùng mod (KHÔNG dùng cho client 800x600)
mod3x6/spr/Ui3/thanhhienthi/thanh.spr         ← sprite nền kèm mod (359x67, single-frame)
config/config.ini        ← [Server] port login + [Client] Theme=CTC + [Launcher] profile
config/package.ini       ← thứ tự load .pak (0=ui.pak … 28=dxrm.pak)
config/uicommon.ini      ← [Region_0] tên server + địa chỉ (đã thay bằng placeholder)
config/resolution.ini    ← hook độ phân giải (1600x900)
config/HoiQuanVoLam.ini  ← config launcher CTC (chỉ [Launcher] Theme=current)
config/fps_events.ini    ← event của plugin hook (dllmain.cpp đọc)
```

- Tên file gốc là **GBK**; repo đổi sang ASCII cho dễ đọc: `toolbar.ini` = `顶部控制条.ini`,
  `main_player_info.ini` = `玩家信息主界面.ini`. Khi ghi lên client phải dùng lại tên GBK.
- `config/uicommon.ini`: `0_Title` / `LastGameServer` đã thay bằng `<SERVER_NAME>`; `0_Address` giữ `127.0.0.1`
  (client chạy cùng máy server).
- Bản mod trong `mod3x6/` là bản share cộng đồng (HQVL) — xem `NOTICE.md`.
- Runbook sử dụng bộ này: `skills/runbooks/ui-3x6-slots.md`.
