# NOTICE — nguồn gốc, bản quyền, giới hạn

Repo này tập hợp **ghi chép kỹ thuật của chủ server** + **trích dẫn tài liệu cộng đồng**, dùng cho nghiên cứu
và vận hành server private chạy offline. Không bán, không kèm binary, không kèm client game.

## 1. Tài liệu cộng đồng — Hội Quán Võ Lâm (HQVL)

- `skills/jx1-hqvl-knowledge/` và `sources/hqvl-docs-text/` được tổng hợp từ các repo của HQVL:
  `github.com/jxoffline/{wiki-beta,jxtools,jx1-scripts,tutorials}`.
- **Bản quyền phân phối nội dung thuộc về Hội Quán Võ Lâm** (fb.com/groups/volamquan, jx1offline@gmail.com);
  bản quyền từng bài thuộc tác giả ghi trong bài. Điều kiện của HQVL: giữ nguyên nội dung + liên kết + tên tác giả,
  không sửa đổi. Nếu HQVL/tác giả yêu cầu gỡ, xoá ngay phần tương ứng.
- HQVL nêu rõ tài liệu chỉ dùng cho **nghiên cứu/học tập, phi thương mại**; không bảo hành tính chính xác/an toàn
  của mã nguồn, công cụ, tập tin được chia sẻ.

## 2. Ghi chép của chủ server

- `skills/vltk-*`, `skills/jx1-simbot`, `skills/CHEATSHEET.md`, `START-HERE.md`, `sources/simbot/`:
  ghi chép và mã Lua thuộc **server server JX1** (tự host, chơi offline). Phần script SimCity/SimBot do
  dev của server phát triển/nhận chuyển giao, có ghi mốc kinh nghiệm trong comment.
- Nội dung khác trong `sources/` (settings, bảng dữ liệu) là dữ liệu cấu hình của server.

## 3. Thương hiệu

Võ Lâm Truyền Kỳ / JX / 剑侠情缘 là sản phẩm của Kingsoft (và VNG tại Việt Nam). Repo này **không liên kết,
không đại diện, không sở hữu** bất kỳ thương hiệu hay bản quyền nào của các bên trên. Không dùng cho mục đích
thương mại.

## 4. Bảo mật

- Không có mật khẩu, khoá riêng, token hay thông tin đăng nhập trong repo (kiểm bằng `scripts/audit.sh`).
- IP xuất hiện là **IP LAN nội bộ** (dải IP LAN nội bộ) — vô nghĩa với bên ngoài, nhưng nếu public repo thì nên
  thay bằng placeholder nếu muốn che topology.
- Đường dẫn riêng của máy (alias `ssh <SSH_ALIAS2>`, `<JX1_ROOT>\...`) là ví dụ, cần sửa theo môi trường của bạn.
