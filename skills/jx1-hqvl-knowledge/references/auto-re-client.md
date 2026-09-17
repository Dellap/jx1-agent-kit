# Auto, Reverse Engineering & inject DLL (nguồn: HQVL — Trung Duong / Tiến Phan / Kiều Tôn Sơn)

## 1. Nguyên lý auto

Auto đơn giản = gọi **hàm thực thi script của thanh chat** trong `game.exe`. Địa chỉ hàm này (JX6.0):
**0x140C0**. Ví dụ script gọi được:

```
/Chat('CH_NEARBY', 'message')    -- phụ cận
/Chat('CH_CITY',   'message')    -- thành thị
/Chat('CH_WORLD',  'message')    -- thế giới
/Chat('CH_TONG',   'message')    -- bang hội
Switch([[horse]])                -- lên/xuống ngựa
Switch([[pk]], 0|1|2)            -- đổi PK
Switch([[run]])                  -- đi bộ / chạy
```

Khó nhất là **tìm địa chỉ**: hàm di chuyển, hàm bán đồ, v.v. phải tự RE (không có bài bản; tham khảo tutorial
RE của The Legend Of Random). Video Part1: hướng dẫn viết auto rao bán đồ JX6, dùng Process Hacker.

## 2. Phân loại địa chỉ

| Loại | Cách tìm | Ghi chú |
|---|---|---|
| **Biến static** (toạ độ, HP…) | Cheat Engine scan → địa chỉ **xanh lá** | Không đổi giữa các lần mở game |
| **Biến dynamic** | Cheat Engine scan giá trị → **Pointer scan for this address** để lấy pointer offsets | Đổi mỗi lần mở game; thành thạo rồi thì đọc offset trực tiếp trong assembly |
| **Địa chỉ hàm** | Dịch ngược mã máy (IDA/OllyDbg) | Khó nhất, làm sau |

**JXLinux** (không có source, client không build lại) → địa chỉ hàm, biến static và pointer offset **cố định**.
**JXWin** (build lại từ source) → mỗi lần build địa chỉ khác ⇒ **phải dùng pattern/signature** (ví dụ thư viện
`HoShiMin/Sig`) để tự dò lại, không hardcode. Nguyên tắc chung: dùng `base + offset`, đừng dùng địa chỉ tuyệt đối.

## 3. Inject DLL — 2 hướng

**Part 2 — Assembly/hex trong `Game.exe`**
- Ưu: exe đổi rất ít, vẫn vào game trực tiếp như bình thường.
- Nhược: inject phức tạp hơn C#/C++; **không mã hoá được DLL** cần inject.
- Hợp cho: miniskill, anti-dump.

**Part 3 — C# (≈6 dòng) hoặc C++**
- Ưu: `Game.exe` **hoàn toàn không bị thay đổi**; code C#/C++ mở rộng được để mã hoá DLL (thêm lớp bảo mật);
  nâng cao có thể làm inject gần như tàng hình, hạn chế dump memory để lấy lại DLL gốc và hạn chế debug/cr@ck.
- Nhược: cần chương trình thứ 3 để inject ⇒ vào game không trực tiếp (kiểu JX8).
- Hợp cho: auto.

Công cụ kèm theo: Process Hacker/Explorer, OllyDbg 1.10, IDA Free, Cheat Engine (code injector DLL).

## 4. Bản jx80 — dị bản nhị phân `game_y.exe`

- `game_y.exe` bản jx80 HQVL được chỉnh để **chạy VAuto**: mọi auto khác muốn chạy phải bật VAuto trước.
- **VAuto Dehook**: client chưa bị hook VAuto → tự do phát triển auto độc lập (chưa auto nào chạy sẵn được).
  Vẫn phải khởi động bằng `Game.exe`.
- **Stand-alone**: client gốc Kingsoft bàn giao VNG (giống bản 6.0), **không hiện cửa sổ Command Prompt**;
  không xài được auto ngay, cần "thủ thuật patch" (inject DLL / patch auto) mới dùng được.

## 5. JXWin source & bản 64-bit (Tiến Phan)

- Source: **Tinh Vân dị bản Trần Minh** (~15GB, 10 part; kèm client + server chạy được; **Visual Studio 6.0**),
  biến thể `duccom0123/jx1-vs2022` (giao diện Công Thành Chiến).
- Chuyển **GameServer lên 64-bit**:
  - Lợi: 1 process GS thay vì 8 GS (7 GS × ~1.7GB ≈ cần 10GB cho 800 map ở chế độ multi-GS debug),
    tăng được player/NPC/map mà không phải chạy multi-server, ít cấu hình, tốn ít RAM hơn.
  - Bắt buộc: các thư viện `common.lib`, `heaven.dll`, `rainbow.dll`, `CoreServer.dll`, `Engine.dll` phải là bản 64-bit.
  - `Gateway (bishop)`, `DB server (goddess)`, `s3relay`, `Paysys` **giữ 32-bit** vẫn chạy bình thường.
  - Cần chuyển kiểu dữ liệu con trỏ (`unsigned int`) từ 32 sang 64 bit; `size_t` → `unsigned int` vẫn 4 byte ở cả hai.

## 6. AutoIt autoplay (bộ video Lưu Bị — 1.7GB)

Part 1 (tìm thông số & hàm): mở game + click bắt đầu; tìm hàm chọn server + ô tài khoản/mật khẩu; auto login;
click chọn nhân vật + scan HP/Mana/Thể lực/Trạng thái; auto đánh quái (3 phần, scan NPC, auto buff);
scan ID thành + toạ độ + hàm di chuyển; click NPC + click menu; sử dụng item; scan hàm/offset value;
hook function lấy giá trị thanh ghi; tìm hàm đánh quái; tìm hàm di chuyển liên thành.
Part 2 (nâng cao): tìm & đọc static, Cheat Engine code injector DLL, inject assembly bằng C++, giao tiếp Arduino.

## 7. Client UI / patch khác có sẵn

- **Miniskill**: icon các skill đang thụ hưởng, hiện dưới thanh máu góc trên trái; nguồn 527MB (gốc) / 46KB (patch).
- **Scale cửa sổ lên 1920x1080** không cần Alt+Enter (app riêng, tác giả Nguyễn Nghĩa) — HEX UI về tỉ lệ 16:9
  cho đẹp khi full màn.
- **Client patch trùng sinh 6,7,8,9**: chép vào thư mục client; dùng lệnh bài trùng sinh, đổi giá trị 5 → 6..9.
- **JX60 Công Thành Chiến → HKMP** (dị bản Ôi Cuộc Đời): client data VNG + patch client + server `hkmpupdate5`;
  fix hiển thị thần hành phù bằng `spr-fix-than-hanh-phu.7z`.
