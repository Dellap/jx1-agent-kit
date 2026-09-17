==================================================================
TỪ ĐIỂN THAM KHẢO - CẤU TRÚC FILE .lua SKILL (VLTK Offline)
Nguồn: tài liệu "giải_thích_các_file_skill_Lua.docx" người dùng
cung cấp, ĐÃ ĐỐI CHIẾU và XÁC NHẬN/BỔ SUNG bằng dữ liệu THẬT trích
từ wudang.lua, tianren.lua, emei.lua (các lỗi cụ thể đã phát hiện
và sửa trong quá trình làm việc trước đó).
Ký hiệu: [XÁC NHẬN] = đã kiểm chứng khớp với dữ liệu thật.
         [BỔ SUNG]  = phát hiện thêm qua phân tích dữ liệu thật.
         [CHƯA RÕ]  = vẫn còn là ẩn số.
==================================================================

VỊ TRÍ FILE: Server/Script/Skill/<tên_môn_phái>.lua :
wudang.lua : Môn phái Võ Đang
tianren.lua : Môn phái Thiên Nhẫn
emei.lua : Môn phái  Nga Mi 
gaibang.lua : Môn phái Cái Bang
shaolin.lua : Môn phái Thiếu Lâm
wudu.lua : Môn phái Ngũ Độc. 
tangmeng.lua : Môn phái Đường Môn.
cuiyan.lua : Môn phái Thuý Yên
tianwang.lua : Môn phái Thiên Vương
kunlun.lua : Môn phái Côn Lôn.
Huashan.lua : Môn phái Hoa Sơn . 
VAI TRÒ: chứa THÔNG TIN CHÍNH về TÍNH CHẤT VẬT LÝ thực tế của skill
  (damage, AttackRating, SkillCost, các hiệu ứng phụ trợ...) - tức
  là skill đánh ra bao nhiêu dame, mất bao nhiêu nội lực, hỗ trợ
  bao nhiêu %... Đây là nơi CHỨA GIÁ TRỊ THỰC, còn skills.txt chỉ
  QUYẾT ĐỊNH thuộc tính nào được "bật" cho từng skill (xem từ điển
  số 2, phần LvlSetting/LvlData).

------------------------------------------------------------------
PHẦN 1: FILE 状态图形对照表.txt (Bảng trạng thái - hiệu ứng Aura)
------------------------------------------------------------------
Đây không phải file .lua nhưng liên quan mật thiết, nằm cùng thư
mục Settings/. Liệt kê các trạng thái AURA (buff/hiệu ứng thường
trực) của nhân vật:
  A. Tên trạng thái
  B. Đường dẫn file .spr của vòng hỗ trợ/tương tác
  C. Loại vị trí hiển thị: {头顶,脚底,身上} = {đầu, chân, thân}.
     Ví dụ: Thanh Âm Phạn Xướng (Nga Mi) hiện trên THÂN; các chiêu
     buff Nga Mi (Mộng Điệp, Lưu Thủy, Phật Tâm...) hiện dưới CHÂN;
     các skill bùa chú thường hiện trên ĐẦU.
  D. Dạng lan tỏa - đa số chỉ có dạng VÒNG TRÒN.
  E,F,G,H. Các cột mô tả hiệu ứng hình ảnh.
  I. Thời gian hiệu ứng.
  J. Hiệu ứng có hiển thị trên đối tượng khác hay không {0,1}.
  K. Tên skill sử dụng trạng thái này.

------------------------------------------------------------------
PHẦN 2: CẤU TRÚC CHUNG CỦA 1 FILE SKILL .lua
------------------------------------------------------------------
Cú pháp khung (rút gọn):

  SKILLS = {
      tên_skill_1 = {
          tên_thuộc_tính_A = {
              [1] = {{cấp, giá_trị}, {cấp, giá_trị}, ...},
              [2] = {{cấp, giá_trị}, ...},
              [3] = {{cấp, giá_trị}, ...},
          },
          tên_thuộc_tính_B = { ... },
          ...
      },
      tên_skill_2 = { ... },
      ...
  }

[XÁC NHẬN + BỔ SUNG]
- "SKILLS": TÊN BẢNG CỐ ĐỊNH, giữ nguyên, tương đương "function đó"
  của toàn bộ file - KHÔNG được đổi tên.
- tên_skill (key cấp 1, vd "sane_jixue", "CanKhon_quynhat"): đặt
  theo QUY TẮC RIÊNG của từng dự án JX, KHÔNG ĐƯỢC ĐỔI TÙY TIỆN vì
  sẽ gây LỖI SCRIPT (đây chính là giá trị ở cột LvlData trong
  skills.txt - PHẢI KHỚP CHÍNH XÁC giữa 2 file).
  [BỔ SUNG QUAN TRỌNG]: 1 key tên_skill có thể được CHIA SẺ / tham
  chiếu bởi NHIỀU SkillId khác nhau trong skills.txt cùng lúc (ví
  dụ: script tạo MỚI cho "Tam Nga Tề Tuyết" có thể gọi lại
  ChildSkillId=142 dùng chung với skill khác làm missile nền).
- tên_thuộc_tính (key cấp 2, vd "physicsenhance_p", "colddamage_v"):
  LẤY TÊN CHÍNH XÁC từ file magicdesc.ini của server - KHÔNG được
  tự bịa tên mới, vì engine chỉ đọc đúng những tên đã đăng ký sẵn.
  Ví dụ: lifereplenish_v = phục hồi sinh lực mỗi 0.5 giây ... điểm.
- [1], [2], [3]: các THAM SỐ (index) CỦA THUỘC TÍNH ĐÓ. Ý NGHĨA CỦA
  TỪNG INDEX PHỤ THUỘC TỪNG THUỘC TÍNH - ví dụ với thuộc tính dame:
  [1] có thể là SỐ ĐIỂM CỐ ĐỊNH, [3] có thể là KHOẢNG DAO ĐỘNG (min-
  max) - xem ví dụ thực tế bên dưới.
- Cặp số trong mỗi {cấp, giá_trị}: LÀ CẶP LEVEL của skill và GIÁ TRỊ
  tương ứng ở level đó. Thường chỉ cần "chốt" 2-3 mốc (level đầu,
  level cuối, level mở rộng 21+) - GAME TỰ NỘI SUY tuyến tính cho
  các level còn lại theo hàm bậc nhất f(x)=ax+b (xem hàm Line() bên
  dưới). Level 21 dùng để MỞ RỘNG trạng thái vượt ngưỡng 20 (thường
  mức độ tăng có xu hướng NHIỀU HƠN).
- Mỗi dấu mở "{" phải có dấu "}" đóng tương ứng - MỞ BAO NHIÊU DẤU {
  THÌ PHẢI ĐÓNG ĐỦ BẤY NHIÊU } (đây chính là nguyên tắc gây ra toàn
  bộ các LỖI CÚ PHÁP đã phát hiện và sửa trong wudang.lua và
  emei.lua - xem phần "LỖI THƯỜNG GẶP" cuối file).

------------------------------------------------------------------
PHẦN 3: VÍ DỤ THỰC TẾ ĐẦY ĐỦ - "Tam Nga Tề Tuyết" (sane_jixue)
------------------------------------------------------------------
sane_jixue = { --三峨霁雪
    physicsenhance_p = {{{1,510},{15,1200},{20,1637}}},
    seriesdamage_p    = {{{1,20},{15,20},{20,60},{21,62}}},
    colddamage_v = {
        [1] = {{1,1310},{20,2435}},
        [3] = {{1,1310},{20,2451}},
    },
    deadlystrike_p     = {{{1,10},{20,54}}},
    missle_speed_v      = {{{1,28},{20,32},{21,32}}},
    skill_attackradius  = {{{1,448},{20,512},{21,512}}},
    skill_cost_v        = {{{1,35},{20,35}}},
    skill_eventskilllevel = {{{1,1},{20,20}}},
    skill_startevent = {
        [1] = {{1,0},{10,0},{10,1},{20,1}},
        [3] = {{1,329},{20,329}},
    },
    skill_showevent = {{{1,0},{10,0},{10,1},{20,1}}},
    addskillexp1 = {{{1,0},{2,0}},{{1,1},{20,1}},{{1,0},{2,0}}},
    skill_skillexp_v = {{ {1,SkillExpFunc(5000,1.25,1,3,1)}, ... }},
},

Giải nghĩa từng thuộc tính (BẢNG TRA CỨU NHANH TÊN HÀM MAGIC HAY
DÙNG NHẤT, tổng hợp từ ví dụ gốc + toàn bộ dữ liệu thật đã xem qua
wudang.lua/tianren.lua/emei.lua):
  physicsenhance_p    = tăng % sát thương vật lý
  seriesdamage_p       = Ngũ Hành tương khắc , 60 = tăng 60% dame lên khắc hệ ( Hoả - Kim), giảm 60% lên kỵ hệ ( Hoả - Thuỷ)
  colddamage_v          = sát thương băng (điểm cố định, hệ ngoại
                          công lạnh)
  firedamage_v          = sát thương lửa (tương tự colddamage_v)
  lightingdamage_v      = sát thương sét
  deadlystrike_p         = tỷ lệ chí mạng (critical)
  missle_speed_v         = tốc độ bay của missile TRONG GAME (khác
                          Speed trong Missile.txt - đây là tốc độ
                          TÁC ĐỘNG THỰC, còn Missile.txt là CẢM
                          QUAN hình ảnh)
  skill_attackradius      = phạm vi hiệu quả/tầm đánh thực
  skill_cost_v            = lượng tiêu hao (mana/máu/thể lực/tiền
                          tùy SkillCostType trong skills.txt)
  skill_eventskilllevel   = sự kiện khi lên level skill
  skill_startevent        = sự kiện lúc BẮT ĐẦU thi triển
  skill_flyevent          = sự kiện lúc missile ĐANG BAY
  skill_collideevent      = sự kiện lúc missile VA CHẠM mục tiêu
  skill_vanishedevent     = sự kiện lúc missile BIẾN MẤT
  skill_showevent         = sự kiện THỂ HIỆN hình ảnh phụ khi xuất
                          chiêu
  addskillexp1            = thiết đặt kinh nghiệm cộng thêm cho
                          skill
  skill_skillexp_v         = công thức tính EXP tăng skill (gọi hàm
                          SkillExpFunc)
  attackrating_p           = tăng % độ chính xác (attack rating)
  stun_p                    = tỷ lệ/thời gian choáng
  steallife_p / stealmana_p = % hút sinh lực / hút nội lực
  addskilldamage1, addskilldamage2 (,...N) = cộng thêm sát thương
                          theo từng bậc/loại vũ khí riêng - SỐ THỨ
                          TỰ (1,2,3...) PHẢI khớp đúng với tên được
                          khai báo trong LvlSetting của skills.txt,
                          nếu lệch tên (vd "addskilldamage0" không
                          tồn tại) thuộc tính sẽ KHÔNG hoạt động.
  missle_lifetime_v         = thời gian tồn tại của missile (khác
                          với LifeTime trong Missile.txt về phạm vi
                          quản lý - cần đối chiếu kỹ khi 2 giá trị
                          này có lệch nhau).
  skill_misslenum_v         = số lượng missile (thường dùng cho
                          hiệu ứng phụ, khác ChildSkillNum bên
                          skills.txt).

Ví dụ giải thích CHI TIẾT 1 thuộc tính (nguyên văn từ tài liệu gốc,
đã xác nhận đúng logic qua nhiều skill khác):
  colddamage_v = {
      [1] = {{1,1310},{20,2435}},
      [3] = {{1,1310},{20,2451}},
  }
  -> [1]: cấp 1 có sát thương lạnh là 1310, cấp 20 là 2435.
  -> [3]: ý nghĩa tương tự nhưng giá trị khác - VỚI THUỘC TÍNH
     DAME, đây thường là GIỚI HẠN TRÊN của khoảng dao động ngẫu
     nhiên (không phải lúc nào cũng đúng 2435 mà có thể hơn hoặc
     kém, dao động trong khoảng [1]-[3]).
  LƯU Ý: cùng 1 SỐ THỨ TỰ INDEX có thể mang Ý NGHĨA KHÁC NHAU tùy
  THUỘC TÍNH khác nhau - ví dụ [1] có thể là trình tự, [2]/[3] có
  thể là giá trị - KHÔNG CÓ QUY TẮC CỐ ĐỊNH CHUNG CHO MỌI THUỘC
  TÍNH, phải xem từng trường hợp.

------------------------------------------------------------------
PHẦN 4: RÀNG BUỘC QUAN TRỌNG GIỮA .lua VÀ skills.txt
------------------------------------------------------------------
[XÁC NHẬN MẠNH qua nhiều ví dụ thật] Một thuộc tính (vd
physicsenhance_p) CÓ TỒN TẠI trong file .lua VẪN KHÔNG ĐƯỢC ÁP DỤNG
vào game NẾU KHÔNG được khai báo trong cột LvlSetting tương ứng ở
skills.txt. Cách khai báo (theo tài liệu gốc): COPY chính xác TÊN
THUỘC TÍNH rồi dán vào ô trống kế bên TÊN SKILL trong skills.txt
(ví dụ thuộc tính physicsenhance_p của Tam Nga: copy
"physicsenhance_p" dán vào skills.txt ở các cột LvlSetting, LvlData
ghi "sane_jixue").
  [BỔ SUNG - CHỈNH SỬA SỐ LIỆU TÀI LIỆU GỐC]: tài liệu gốc ghi "số
  thuộc tính tối đa khai báo được là 10, thứ 11 trở đi sẽ bất hoạt"
  - nhưng qua kiểm tra header thực tế của skills.txt (bản gần
  nhất), cấu trúc có tới 20 cặp LvlSetting/LvlData (LvlSetting1..
  20), và đã thấy skill thực tế dùng tới 14-18 cặp vẫn hoạt động
  bình thường. Có thể con số "10" trong tài liệu gốc chỉ đúng cho 1
  PHIÊN BẢN SERVER CŨ HƠN - KHUYẾN NGHỊ: nếu server đang dùng có
  giới hạn khác, nên tự kiểm tra thực tế thay vì tin tuyệt đối vào
  con số 10.
	•	Nếu thuộc tính đã được quy định trong file .lua thì ở bên ngoài skills.txt và missles.txt nếu có thay đổi giá trị gì đi nữa  thì ,  hệ thống vẫn chỉ nhận duy nhất giá trị trong file .lua 

------------------------------------------------------------------
PHẦN 5: CÁC HÀM NỘI SUY DÙNG CHUNG (helper functions)
------------------------------------------------------------------
[XÁC NHẬN nguyên văn qua ví dụ thật, có giải thích thêm]

1) function Line(x,x1,y1,x2,y2)
   Nội suy TUYẾN TÍNH (đường thẳng) qua 2 điểm (x1,y1),(x2,y2):
     y = (y2-y1)*(x-x1)/(x2-x1) + y1
   Nếu x1==x2: trả về y2 (tránh chia cho 0).
   ỨNG DỤNG: tính giá trị thuộc tính skill khi lên cấp (chỉ cần set
   2 mốc level, game tự suy ra các level còn lại); hoặc tính đường
   đi missile từ tọa độ người chơi đến quái.

2) function Conic(x,x1,y1,x2,y2)
   Nội suy theo ĐƯỜNG BẬC 2 (parabol):
     y = (y2-y1)*x^2/(x2^2-x1^2) - (y2-y1)*x1^2/(x2^2-x1^2) + y1
   Nếu x1<0 hoặc x2<0: trả về 0. Nếu x1==x2: trả về y2.
   [BỔ SUNG] Đã gặp thực tế: dùng làm "func" thứ 3 trong 1 điểm của
   Link() (vd deadlystrikeenhance_p={{{1,6},{20,25,Conic}}...}) để
   chọn KIỂU nội suy PHI TUYẾN thay vì tuyến tính mặc định - đây là
   CÓ CHỦ ĐÍCH của người thiết kế, KHÔNG PHẢI lỗi.

3) function Extrac(x,x1,y1,x2,y2)
   Công thức gốc (theo căn bậc 2) nhưng PHẦN THÂN HÀM trong tài
   liệu lại viết giống hệt Line() - [CHƯA RÕ] đây có phải lỗi đánh
   máy trong TÀI LIỆU GỐC hay hàm này thực sự chỉ là 1 biến thể đặt
   tên khác của Line(). Cần kiểm tra trực tiếp trong file .lua thật
   (không chỉ dựa vào tài liệu Word) nếu cần dùng chính xác hàm
   này.

4) function Link(x, points)
   VẼ ĐƯỜNG GHÉP TỪ NHIỀU ĐOẠN (spline theo từng cặp 2 điểm liên
   tiếp). points có dạng:
     {{x1,y1,func1},{x2,y2,func2},...,{xn,yn,funcN}}
   - Nếu 1 điểm KHÔNG chỉ định func: mặc định dùng Line.
   - Nếu x nằm TRƯỚC điểm đầu tiên hoặc SAU điểm cuối cùng: NGOẠI
     SUY (extrapolate) dựa trên 2 điểm gần nhất ở đầu/cuối.
   - Nếu x nằm GIỮA 2 điểm liên tiếp [i-1, i]: nội suy theo func
     của điểm thứ i.
   ĐÂY LÀ HÀM CHÍNH được gọi trong GetSkillLevelData() để tính giá
   trị thực tế của 1 thuộc tính ở 1 level cụ thể.

5) function GetSkillLevelData(levelname, data, level)
   HÀM TRUNG TÂM đọc dữ liệu 1 thuộc tính:
   - levelname = tên thuộc tính magic (vd "physicsenhance_p")
   - data      = tên skill (key trong bảng SKILLS)
   - level     = level hiện tại của skill
   Logic: nếu data/levelname không tồn tại (nil) -> trả về CHUỖI
   RỖNG "" (ĐÂY CHÍNH LÀ cơ chế gây ra hiện tượng "thuộc tính biến
   mất" khi LvlSetting trong skills.txt ghi SAI TÊN không khớp với
   .lua - đã xác nhận qua lỗi thực tế "addskilldamage0"). Nếu
   [1]/[2]/[3] của thuộc tính không được định nghĩa, TỰ ĐỘNG điền
   mặc định {{0,0},{20,0}} (giá trị 0 tất cả các level). Kết quả
   trả về là CHUỖI "p1,p2,p3" (qua hàm Param2String).

6) function Param2String(Param1, Param2, Param3)
   Ghép 3 giá trị đã tính thành 1 chuỗi dạng "p1,p2,p3" để trả về
   cho engine.

7) function SkillExpFunc(Exp0, a, Level, Time, Range)
   Công thức tính EXP cho hệ thống "skill 9x" (tăng theo kinh
   nghiệm, không phải tăng theo điểm):
     SkillExp(i) = Exp0 * a^(i-1) * Time * Range / [50 hoặc 2 tùy
                   bản server - hai tài liệu/dữ liệu gốc có thể
                   khác nhau về số chia này, CẦN KIỂM TRA LẠI đúng
                   file .lua thật đang dùng, [CHƯA RÕ] chính xác
                   con số nào là đúng/cập nhật nhất]
   Các tham số ảnh hưởng: mức độ thăng cấp a, level hiện tại, thời
   gian xuất skill (Time), phạm vi skill (Range).

------------------------------------------------------------------
PHẦN 6: LỖI THƯỜNG GẶP ĐÃ PHÁT HIỆN + SỬA THỰC TẾ (tra cứu debug
nhanh, tổng hợp từ quá trình rà soát wudang.lua và emei.lua)
------------------------------------------------------------------
LỖI KIỂU 1 - "Comment nửa vời" (comment không đủ, thiếu che hết cả
khối): chỉ comment ĐÚNG DÒNG ĐẦU TIÊN của 1 khối thuộc tính nhiều
dòng, khiến các dòng còn lại (vd [1]=..., [3]=..., dấu "},") BỊ LỘ
RA thành KEY TRỰC TIẾP của bảng CHA (vd của tên_skill thay vì của
thuộc_tính, hoặc thậm chí của cả bảng SKILLS). Hậu quả: thuộc tính
BỊ MẤT hoàn toàn (trả về ""), hoặc thuộc tính SAU ĐÓ trong cùng
khối bị ĐÈ LÊN nhau (dữ liệu bị mất âm thầm không báo lỗi).
  CÁCH SỬA: hoặc comment ĐẦY ĐỦ MỖI DÒNG trong khối (mỗi dòng đều
  có "--" ở đầu), hoặc dùng comment khối "--[[ ... ]]".
  Ví dụ thật đã sửa: wudang.lua, khối Doatmang_tamthien và
  Doatmang_3000.

LỖI KIỂU 2 - Thừa 1 dấu ngoặc đóng "}": 1 dấu "}" dư ở cuối 1 dòng
sẽ đóng SỚM 1 cặp bảng đang mở (có thể đóng nhầm chính bảng cha,
hoặc trong trường hợp xấu nhất đóng nhầm cả bảng SKILLS gốc), gây
HIỆU ỨNG DÂY CHUYỀN phá vỡ cấu trúc TOÀN BỘ PHẦN CÒN LẠI CỦA FILE
(các skill phía sau trở thành cú pháp sai hoàn toàn). Đây là LỖI
NGHIÊM TRỌNG NHẤT trong các loại đã gặp, vì ảnh hưởng CẢ FILE chứ
không chỉ 1-2 skill.
  CÁCH PHÁT HIỆN: đếm tổng số dấu "{" và "}" toàn file (bỏ qua dòng
  comment) - nếu KHÔNG BẰNG NHAU, chắc chắn có lỗi cấu trúc.
  Ví dụ thật đã sửa: emei.lua, khối Bang_nhu110 (dòng
  "[1]={{1,20},{20,110},{23,120}}}," có 1 dấu "}" thừa).

LỖI KIỂU 3 - Tên thuộc tính trong LvlSetting (skills.txt) KHÔNG
KHỚP với tên thực sự trong file .lua (vd khai báo "addskilldamage0"
nhưng .lua chỉ có "addskilldamage1"/"addskilldamage2"): không gây
lỗi cú pháp, CHẠY BÌNH THƯỜNG nhưng thuộc tính đó sẽ LUÔN RỖNG khi
hiển thị/tính trong game - loại lỗi NÀY KHÓ PHÁT HIỆN NHẤT vì
KHÔNG CÓ THÔNG BÁO LỖI, chỉ phát hiện được qua ĐỐI CHIẾU THỦ CÔNG
giữa 2 file.

LỖI KIỂU 4 - Giá trị BẤT THƯỜNG so với QUY LUẬT chung (vd
skill_cost_v GIẢM theo cấp trong khi 95%+ các skill khác đều tăng/
giữ nguyên): không phải lỗi cú pháp, chỉ là dấu hiệu NGHI VẤN cần
kiểm tra lại chủ đích thiết kế - phát hiện bằng cách SO SÁNH THỐNG
KÊ giá trị cùng 1 thuộc tính giữa nhiều skill CÙNG LOẠI.

LỖI KIỂU 5 - Sao chép (copy-paste) 1 skill làm mẫu nhưng QUÊN BẬT
LẠI 1 vài thuộc tính đã bị comment tắt trong bản gốc (vd tạo skill
mới từ 1 skill có sẵn, giữ nguyên các dòng addskilldamage1/
skill_attackradius đang ở dạng comment từ bản gốc trong khi TẤT CẢ
các thuộc tính khác đều được chỉnh sửa có chủ đích) -> skill mới
"thiếu" mất 1 phần sức mạnh dù cấu trúc vẫn đúng cú pháp.
  CÁCH PHÁT HIỆN: so sánh SKILL MỚI với SKILL MẪU từng dòng, chú ý
  đặc biệt các dòng đang bị comment (--) xem có phải "quên bật" hay
  "có chủ đích giữ tắt".
==================================================================
