

## ⚠️ ĐÍNH CHÍNH sau khi đối chiếu server thật (17/09/2026)

- **Tên file thật = `settings/missles.txt`** (không phải `Missile.txt`); kèm `settings/missletemplate.txt` mô tả cột/enum. Bỏ câu "chưa có file dữ liệu thực tế".
- dòng 29: `2` = **bay ngẫu nhiên** (không phải "tùy ý").
- dòng 34-35: `7` = **parabol**; còn `8` = hồi toàn/xoay về (chưa thấy dùng) ⇒ cột `FollowKind` là `{0..8}`, không phải `{0..7}`.
- dòng 40: ⚠️ **ngược nghĩa** — `0` = **KHÔNG bám theo** (438/441 dòng là 0), `1` = bám theo NPC.
- dòng 43: `2` = **bám theo đạn** (chỉ 1 skill dùng; hành vi chưa kiểm runtime).
- dòng 132-137: ⚠️ **lệch 1 cột từ Y trở đi** — thực tế `Y = MissRate` (cột tài liệu cũ bỏ sót, toàn bộ 441 dòng = 0), `Z/AA/AB = Param1/Param2/Param3`. **Luôn đọc theo header thật, đừng copy số cột tài liệu.**
- dòng 139-144: `MultiShow` = **cột AC** (không phải AB).
- dòng 146-149: sau AC còn `AnimFile1-4` + `AnimFileInfo1-4` + `SndFile1-4` (+ bộ `B1-B4`) và `RedLum/GreenLum/BlueLum/LightRadius`.
- dòng 75-86: tên hàm thật = **`missle_lifetime_v`**, **`missle_speed_v`**, `skill_misslenum_v` (không phải `misssle_*`).
- dòng 93-94 (`Zacc`) và 108-109 (`ResponseSkill`): vẫn **chưa kiểm được** (template không khai báo / 100% dòng = 0).

==================================================================
TỪ ĐIỂN THAM KHẢO - CÁC CỘT TRONG FILE Missile.txt (VLTK Offline)
Nguồn: tài liệu "Missiletemplate.docx" người dùng cung cấp.
Ghi chú: chưa có file dữ liệu Missile.txt thực tế được upload trong
cuộc trao đổi này, nên phần đối chiếu dữ liệu thật (như đã làm với
skills.txt/.lua) chưa thực hiện được cho file này. Nội dung dưới đây
là nguyên vẹn kiến thức từ tài liệu gốc, sắp xếp lại theo dạng tra
cứu nhanh.
==================================================================

Vai trò chung: Missile.txt quy định HIỆU ỨNG HÌNH ẢNH và MỘT PHẦN
cách thức TƯƠNG TÁC VẬT LÝ của từng "viên đạn/lưỡi kiếm/quả cầu..."
(missile) bắn ra từ 1 skill. Trong khi skills.txt quyết định "skill
này dùng missile nào, bắn mấy viên, theo kiểu gì", thì Missile.txt
quyết định "1 viên đó trông như thế nào và va chạm ra sao".

------------------------------------------------------------------
CỘT A - MissleId (num)
  ID của missile, dùng để skills.txt tham chiếu tới.

CỘT B - MissleName (str)
  Tên missile, chỉ để người chỉnh sửa dễ nhận diện - đổi tùy ý
  không ảnh hưởng game.

CỘT C - MoveKind (0-7)
  Kiểu di chuyển của missile:
  0 = No change (đứng yên tại chỗ không di chuyển)
  1 = Đường thẳng ( lao về phía trước )
  2 = Tùy ý
  3 = Vòng tròn trung tâm ( đi theo hình tròn )
  4 = Xoắn ốc ( xoay quanh nhân vật )
  5 = Truy mục tiêu ( đuổi theo mục tiêu)
  6 = Động tác của người chơi 
  (chỉ có 7 giá trị 0-6 được liệt kê trong tài liệu gốc, cột ghi
  {0..7} nhưng chỉ mô tả tới 6 - giá trị 7 chưa rõ)
100 = đạn bay ra rồi bay về vị trí cũ ( cửu cung phi tinh 9x, phi tiêu 6x đường môn)

CỘT D - FollowKind (0-2)
  Kiểu bám đuổi:
  0 = tracking (bám theo vị trí chuột đã nhấp)
  1 = tracking NPC (đuổi theo đối tượng cho đến khi tương tác hoặc
      ra khỏi phạm vi)
  2 = tracking bullets (chưa rõ cơ chế chi tiết)

CỘT E - ColFollowTarget (0/1)
  Có tạo hiệu ứng va chạm SAU KHI đã tương tác với đối tượng hay
  không.

CỘT F - MissleHeight (num)
  Chiều cao xuất phát của missile. Quan trọng với các skill rơi từ
  trên không xuống (vd: Phong Sương, Lôi Động...) - cần để số lớn
  để lấy đủ dạng rơi của skill.

CỘT G - CollidRange (num)
  Độ rộng của HIỆU ỨNG va chạm hiển thị (vd quầng sáng nhỏ quanh
  quái khi trúng đòn). Số càng lớn, vòng hiển thị càng lớn. Ví dụ
  thực tế: skill "Tam Nga Tề Tuyết" (SkillId 328, xem file dữ liệu
  skills.txt) dùng cột này để quyết định kích thước vòng sáng khi
  trúng quái.

CỘT H - IsRangeDmg (0/1)
  Có phải dame diện rộng không. Nếu =0: 2 quái đứng cạnh nhau nhưng
  1 kiếm chỉ giết được 1 quái (dame đơn mục tiêu).

CỘT I - DmgRange (num)
  Phạm vi dame thực tế - CHỈ CÓ TÁC DỤNG khi cột H (IsRangeDmg) = 1.
  Số càng lớn, vùng giết quái càng rộng.

CỘT J - DmgInterval (num)
  Khoảng thời gian giữa 2 lần gây dame hiệu quả.
  = 0: quái chỉ ăn 1 lần dame duy nhất khi missile đi qua. (= 100% dame )
  > 0: hiệu ứng dame còn lưu lại, quái tiếp tục ăn dame bị chia dần ra 
Tóm lại : giá trị càng nhỏ sát thương gây ra càng lớn.

CỘT K - LifeTime (num) có bị chia phối bởi hàm misssle_lifetime trong file .Lua
  Thời gian TỒN TẠI của missile trên màn hình. Càng dài thì missile
  càng lâu biến mất - nếu quá dài dễ gây rối màn hình khi đánh
  nhiều lần liên tục (missile chồng chất).

CỘT L - Speed (num) có bị chia phối bởi hàm misssle_speed trong file  .Lua

  Tốc độ BAY của missile (KHÔNG nhầm với tốc độ xuất chiêu, cũng
  KHÔNG phải tốc độ tương tác thực). Chỉ ảnh hưởng CẢM QUAN (kiếm
  bay nhanh/chậm). Kinh nghiệm từ tài liệu gốc: với skill tầm xa
  đơn, nên để Speed = 0 để hiệu ứng hình ảnh khớp với hiệu quả
  thực tế được tính trong skills.txt + file .lua.

CỘT M - Zspeed (num)
  Tốc độ theo trục dọc (Z). Missile rơi từ trên xuống -> số ÂM.
  Missile bay từ dưới lên -> số DƯƠNG.

CỘT N - Zacc (num)
  Dự đoán là GIA TỐC theo trục Z - CHƯA XÁC NHẬN được ý nghĩa
  chính xác (tài liệu gốc cũng ghi "chưa rõ").

CỘT O - LoopPlay (0/1)
  Lặp lại hiệu ứng hay không.

CỘT P, Q, R - SubLoop, SubStart, SubStop
  Vòng lặp PHỤ (khác với vòng lặp chính ở cột O), thời gian bắt
  đầu/kết thúc vòng lặp phụ (num). Chỉ có ý nghĩa với skill ĐA HIỆU
  ỨNG. Ví dụ kinh điển: "Cửu Long CB" (con rồng 9x) - vòng lặp
  CHÍNH là lúc người chơi giữ chuột trái vào quái (rồng liên tục
  lao vào cắn cho đến khi quái chết/hết phạm vi/hết mana); vòng lặp
  PHỤ là mỗi lần rồng bay tới gặp quái thì cắn qua cắn lại vài lần
  mới xong 1 lần thả skill.

CỘT S - ResponseSkill (str)
  Skill "đáp ứng" - Ý NGHĨA CHƯA RÕ trong tài liệu gốc.

CỘT T - CanDestroy (0/1)
  =1: missile biến mất khi gặp vật cản (đá, cây...).

CỘT U - ColVanish (0/1)
  Sau khi có hiệu ứng va chạm rồi, nếu để =0 sẽ hơi kỳ vì hiệu ứng
  cứ hiển thị mãi quanh quái (không tự biến mất).

CỘT V - CanSlow (0/1)
  =1: tốc độ missile sẽ chậm dần theo thời gian.

CỘT W - CanColFriend (0/1)
  =1: missile va chạm/tác động cả lên ĐỒNG ĐỘI (không phân biệt
  địch-ta).

CỘT X - AutoExplode (0/1)
  Dùng chủ yếu cho nhóm skill "chưởng" hoặc dạng vòng tròn, tương
  tự cơ chế LoopPlay.
  =1: chỉ cần bấm 1 lần, missile TỰ ĐỘNG lo phần còn lại (không
      cần bấm lặp lại).
  =0: bấm bao nhiêu lần, missile ra bay nhiêu lần.

CỘT Y, Z, AA - Param1, Param2, Param3 (num)
  Chưa xác định được ý nghĩa rõ ràng qua test thực tế (tài liệu gốc
  ghi "test vài skill của Nga Mi không thấy gì khác"). CẦN LƯU Ý:
  đây là Param1/Param2/Param3 CỦA MISSILE.TXT - KHÁC với Param1/
  Param2/Param1Memo/Param2Memo trong skills.txt (xem file từ điển
  số 2) - hai bộ tham số này ở hai file khác nhau, đừng nhầm lẫn.

CỘT AB - MultiShow (0/1)
  =1: khi skill có NHIỀU HIỆU ỨNG liên tiếp trong quá trình diễn ra
      (ví dụ: skill rồng CB có cả hiệu ứng bay LẪN hiệu ứng va
      chạm).
  =0: skill đơn hiệu ứng (đặt 1 cũng được nhưng sẽ không có gì khác
      biệt).

CÁC CỘT CÒN LẠI (sau AB)
  Là đường dẫn tới file hiệu ứng .spr và các thông số đi kèm (dạng
  số như 64,16,1...) liên quan tới công cụ đồ họa (Corel) - tài
  liệu gốc ghi rõ "ai rành về Corel thì coi giúp".

------------------------------------------------------------------
GHI CHÚ ĐỐI CHIẾU:
Trong toàn bộ quá trình phân tích skills.txt/.lua trước đó, các cột
liên quan trực tiếp đến Missile.txt là:
  - ChildSkillId / ChildSkillNum trong skills.txt: quyết định
    DÙNG missile nào làm nền và BẮN BAO NHIÊU viên.
  - MslsGenerate, MisslesForm, Param1, Param2 (trong skills.txt,
    KHÁC với Param1/2/3 của Missile.txt ở trên): quyết định CÁCH
    CÁC MISSILE ĐƯỢC SINH RA (tuần tự/cùng lúc/ngẫu nhiên/trải
    rộng, hình dạng đội hình).
  - Missile.txt (file này) quyết định TỪNG VIÊN missile đó trông
    thế nào, bay kiểu gì, và va chạm/gây dame ra sao khi nó tới nơi.
Ba lớp dữ liệu này PHẢI phối hợp với nhau (+ file .spr đồ họa) mới
tạo thành 1 skill hoàn chỉnh - đúng điển hình trong Giải_thích file
số 2 (skills.txt): "có đủ các file này cùng file .spr trong data
mới làm thành skill hoàn chỉnh".
==================================================================
