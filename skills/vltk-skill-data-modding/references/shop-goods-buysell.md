# Shop / goods.txt / buysell.txt — chưng cất từ ShopBuilder (HQVL) + kiểm tra thật trên server (17/09/2026)

Nguồn: `sources/hqvl-docs-text/jxtools__shopbuilder__README.md.txt` + `jxtools__shopbuilder.d__index.html.txt` (+ bản `.d__index`, source HTML).
Tool gốc: **VNJX ShopBuilder** — https://jxoffline.github.io/jxtools/shopbuilder.d/ (NodeJS + jQuery + Bootstrap, MIT, tác giả **vinh-ttn**,
source: `github.com/jxoffline/jxtools/tree/main/shopbuilder`). Video hướng dẫn: https://youtu.be/_QTmfC8G1So

## 1. Bộ file quyết định shop

| File | Vai trò | Cấu trúc |
|---|---|---|
| `goods.txt` | **Danh mục vật phẩm bán** (món + giá theo nhiều loại tiền) | 26 cột, 1 dòng = 1 món; **ID món = số thứ tự dòng (1-based)** |
| `buysell.txt` | **Ma trận cửa hàng**: cửa hàng nào bán món nào | dòng 1 = **tên cửa hàng theo CỘT**; mỗi dòng sau = 1 vị trí; ô = ID dòng trong `goods.txt` (trống = ô trống) |
| `item/` | Thư mục định nghĩa item (chia theo `000/001/002…`) — phải zip kèm khi upload tool | |
| `magicscript.txt` | Tool cũng sửa được (item đặc biệt/magic) | **server hiện tại KHÔNG có file này** |

**Trạng thái thật trên server (đã verify 17/09):**

| Nơi | buysell.txt | goods.txt |
|---|---|---|
| `server1/settings/` | 33.810 B, 180 dòng × **117 cột** | 141.026 B, **2.160 dòng** × 26 cột |
| `gateway/s3relay/relaysetting/syncfiles/settings/` | 28.293 B — ⚠️ **KHÁC md5, nhỏ hơn** | 69.068 B — ⚠️ **KHÁC md5, nhỏ hơn** |
| `<CLIENT>/settings/` | 33.810 B (khớp server1) | 141.026 B (khớp server1) |

⇒ **Đọc kỹ khi sửa shop**: gateway là bản relay cho client; đang **lệch** với server1 (cần xác nhận bản nào đúng trước khi ghi).
Có thêm `settings/item/` và dưới gateway là `syncfiles/settings/shop/` (chỉ có `type.txt`).

## 2. `goods.txt` — 26 cột (tên cột là **GBK**, đọc ra nghĩa như sau)

`ItemGenre` · `DetailType` · `ParticularType` (3 cột này = **ID vật phẩm**, khớp `Genre-Detail-Particular`) ·
Ngũ hành thuộc tính · Đẳng cấp · Ngân lượng · Phúc duyên · Đồng tiền · Tích phân · Kim tệ · Cống hiến độ · Vinh dự điểm ·
Kim tệ tích phân · Kim tệ hoàn lại · Loại tiền giá thống nhất · Số tiền giá thống nhất · Có ghi giao dịch ·
**Giá hiện tại** · Bắt đầu khuyến mãi · Kết thúc khuyến mãi · Bắt đầu bán · Kết thúc bán ·
Bảo giá kỳ (phút, thời gian thực) · Sử dụng kỳ (phút, thời gian online) · Loại tiêu hao (0 = một lần, 1 = vô hạn) ·
**Tên đạo cụ — BẮT BUỘC để ở cột CUỐI cùng (engine KHÔNG đọc)**.

Dòng thật trong file server: `1 · 0 · 0 · 0 · 1 · 50 · … · 0 · … · 金创药(小)` = món `1-0-0`, đẳng cấp 1, giá 50 ngân lượng.
Nhiều cột tiền tệ trống = món chỉ bán bằng loại tiền đã điền.

## 3. Quy trình sửa shop bằng ShopBuilder (đúng như tài liệu)

1. Trên server tạo 1 thư mục A chứa **`buysell.txt` + `goods.txt` + `item/`** (đều nằm trong `server1/settings`) → **zip** lại.
2. Upload zip đó vào tool → **Bắt đầu**.
3. Thêm/chỉnh: *Vật phẩm bán* (`goods.txt`, sửa giá) → *Cửa hàng* (`buysell.txt`, thêm món vào shop) → có thể thêm cửa hàng mới / món mới.
4. **Download** `goods.txt` + `buysell.txt` mới — **chọn đúng version server (6 hoặc 8)** → chép đè vào **3 nơi**:
   - `server1/settings/`
   - `gateway/s3relay/relaysetting/syncfiles/settings/`
   - `<CLIENT>/settings/`
5. **Restart cả game và server** rồi kiểm tra trong game.

Mở shop bằng script: **`Sale(ID, kiểu)`** — `ID` = id cửa hàng; kiểu (v6): `0` tiền vạn · `1` phúc duyên · `2` danh vọng ·
`3` tích lũy TK · `4` vinh dự (mặc định `0`); v8 mới xác nhận được kiểu `0` (tài liệu ghi "chưa rõ" các kiểu sau).

## 4. ⚠️ Cảnh báo từ chính tài liệu (đừng bỏ qua)

- **Xoá một cửa hàng ⇒ mọi cửa hàng sau bị đổi thứ tự ⇒ mọi script dùng `Sale(ID)` sẽ chạy SAI shop.**
- **Xoá một vật phẩm ⇒ các ID sau dịch lên**; tool tự cập nhật cửa hàng liên quan, nhưng nếu sửa tay thì phải sửa `buysell.txt` theo.
- **Backup `goods.txt` + `buysell.txt` gốc trước khi ghi đè** (file mới lỗi là mất shop).
- Chép thiếu 1 trong 3 nơi ⇒ client/relay giữ bản cũ (xem mục 1: gateway đang lệch thật).
- Sửa `.txt` xong phải restart; client phải **tắt hẳn rồi mở lại**.

## 5. Tài liệu liên quan (cùng nhóm dữ liệu)

- `wiki-beta__download__cong_cu_them_nhanh_vat_pham_vao_cua_hang.html.txt` — thêm nhanh vật phẩm vào cửa hàng.
- `wiki-beta__download__hoan_doi_trang_bi_giu_nguyen_thuoc_tinh.html.txt` — hoán đổi trang bị giữ nguyên thuộc tính.
- `wiki-beta__download__huong_dan_pack_va_unpack_du_lieu_tu_pak.html.txt` — pack/unpack `.pak`.
- `jxtools__onlineTCVN3Converter__README.md.txt` — chuyển UTF-8 ↔ TCVN3 (chữ Việt trong file .txt/settings).
