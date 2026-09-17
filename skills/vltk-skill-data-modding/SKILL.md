---
name: vltk-skill-data-modding
description: Use when sửa skill VLTK server-side data files.
---

# VLTK skill data modding (server-side)

Tài liệu tham khảo chuẩn khi chỉnh skill phía server VLTK/JX1 — dùng cho
mọi server (<SERVER_NAME> <GAME_HOST_IP> WSL, JX2 <GAME_HOST2_IP>/<GAME_HOST2_IP>, bản offline khác). 3 file
reference là từ điển ĐÃ ĐỐI CHIẾU dữ liệu thật (wudang/tianren/emei.lua +
skills.txt), có đánh dấu độ tin cậy [XÁC NHẬN]/[BỔ SUNG]/[CHƯA RÕ].

## File dữ liệu & vị trí
- `Server/Settings/skills.txt` — khai báo skill: SkillId, cách sinh đạn
  (MslsGenerate/MisslesForm/ChildSkillNum), chuỗi sự kiện combo
  (Start/Fly/Collide/VanishedEvent), 20 cặp LvlSetting/LvlData.
- `Server/Script/Skill/<monphai>.lua` — GIÁ TRỊ THỰC của thuộc tính theo
  cấp (bảng SKILLS = { tên_skill = { thuộc_tính = {{cấp,giá trị},...} } }).
- `Server/Settings/Missile.txt` — hình ảnh + va chạm từng "đạn".
- 状态图形对照表.txt — trạng thái aura/buff + file .spr hiển thị.

## Quy tắc vàng (đã xác nhận qua lỗi thật)
1. Tên thuộc tính (.lua) phải khớp CHÍNH XÁC tên magic (magicdesc.ini) và
   cột LvlSetting trong skills.txt — lệch tên = thuộc tính lặng lẽ rỗng,
   KHÔNG báo lỗi (vd addskilldamage0 vs addskilldamage1/2).
2. LvlData (skills.txt) = key tên_skill trong .lua, phải khớp; 1 key có thể
   dùng chung cho nhiều SkillId.
3. Nếu thuộc tính đã khai trong .lua → game chỉ nhận giá trị .lua, mọi sửa
   ở skills.txt/missiles.txt cho thuộc tính đó đều vô hiệu.
4. Đếm `{`/`}` toàn file (bỏ comment) phải CÂN BẰNG — dư 1 `}` phá cả file
   phía sau. Comment phải đủ cả khối (`--` mỗi dòng hoặc `--[[ ]]`), không
   comment nửa vời.
5. Tối đa 20 cặp LvlSetting/LvlData (không phải 10 — giới hạn server cũ).
6. Giá trị theo cấp chỉ cần chốt 2-3 mốc (level 1, 20, 21+), game nội suy
   tuyến tính qua hàm Line() — hoặc Conic (bậc 2) khi khai func thứ 3.
7. Param1/Param2 (skills.txt) nghĩa TUỲ LOẠI skill — tra cứu theo
   MslsGenerate/MisslesForm từng trường hợp (góc quạt = hệ 8-bit 0-255!).

## 5 loại lỗi thường gặp (debug nhanh)
1. Comment nửa vời → thuộc tính mất/đè nhau âm thầm
2. Thừa `}` → vỡ toàn file
3. LvlSetting sai tên so với .lua → thuộc tính luôn rỗng (khó phát hiện nhất)
4. Giá trị bất thường so với quy luật chung (vd skill_cost_v giảm theo cấp)
5. Copy skill mẫu quên bật lại thuộc tính đang comment

## 📚 Tài liệu HQVL — dữ liệu & công cụ (shop/goods/buysell/pak/TCVN3/GM)

> **Tài liệu HQVL liên quan** (60 tài liệu cộng đồng đã bóc text). Bản đầy đủ: repo này `sources/hqvl-docs-text/<file>` (trên máy: `~/jx1-knowledge/text/`). Mục lục + trích đoạn: skill `jx1-hqvl-knowledge/references/doc-index.md`.

- `jxtools__shopbuilder__README.md.txt` — **ShopBuilder** ⭐ *đã chưng cất → `references/shop-goods-buysell.md`* — tạo/sửa shop server (buysell.txt, goods.txt, item/) — JX Linux 8.0 & 6.0
- `jxtools__onlineGMPassTool__README.md.txt` — **OnlineGMPassTool** — mã hoá/giải mã mật khẩu GM (MD5)
- `jxtools__onlineTCVN3Converter__README.md.txt` — **OnlineTCVN3Converter** — chuyển UTF-8 ↔ TCVN3
- `wiki-beta__cong_cu_ho_tro_toan_tap.html.txt` — công cụ hỗ trợ toàn tập
- `wiki-beta__download__cong_cu_them_nhanh_vat_pham_vao_cua_hang.html.txt` — thêm nhanh vật phẩm vào cửa hàng
- `wiki-beta__download__hoan_doi_trang_bi_giu_nguyen_thuoc_tinh.html.txt` — hoán đổi trang bị giữ nguyên thuộc tính
- `wiki-beta__download__huong_dan_pack_va_unpack_du_lieu_tu_pak.html.txt` — pack/unpack dữ liệu từ .pak

## Tham chiếu chi tiết

- `references/shop-goods-buysell.md` — **chưng cất từ ShopBuilder (HQVL) + verify trên server 17/09**: cấu trúc `goods.txt` (26 cột) & `buysell.txt` (ma trận 117 cửa hàng), 3 nơi phải ghi đè, quy trình 4 bước, `Sale(ID,kiểu)`, cảnh báo lệch ID
- references/lua-dictionary.md — cấu trúc & thuộc tính file .lua + hàm nội suy
- references/skillstxt-dictionary.md — giải nghĩa từng cột skills.txt
- references/missiletxt-dictionary.md — giải nghĩa từng cột Missile.txt

## Trình tự sửa skill an toàn
1. Backup file gốc (cp file file.bak).
2. Đối chiếu 3 lớp: skills.txt (LvlSetting/LvlData) ↔ .lua (thuộc tính) ↔
   Missile.txt (đạn) — sửa thiếu 1 lớp = skill hỏng/chết âm thầm.
3. Kiểm tra cân bằng `{}` + grep tên thuộc tính khớp cả 2 file.
4. Restart đúng quy trình (xem vltk-server-ops) rồi test trong game.
