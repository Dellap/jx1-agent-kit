==================================================================
TỪ ĐIỂN THAM KHẢO - CÁC CỘT TRONG FILE skills.txt (VLTK Offline)
Nguồn: tài liệu "Giải_thích_các_cột_trong_skill_txt.docx" người
dùng cung cấp, ĐÃ ĐỐI CHIẾU và XÁC NHẬN/BỔ SUNG bằng dữ liệu THẬT
trích từ skills.txt (bản gần nhất) + wudang.lua + tianren.lua +
emei.lua đã phân tích trước đó trong cùng phiên làm việc.
Ký hiệu: [XÁC NHẬN] = đã kiểm chứng khớp với dữ liệu thật.
         [BỔ SUNG]  = phát hiện thêm qua phân tích dữ liệu thật,
                      không có (hoặc ghi mơ hồ) trong tài liệu gốc.
         [CHƯA RÕ]  = vẫn còn là ẩn số, cả tài liệu gốc lẫn dữ liệu
                      thật đều không làm rõ được.
==================================================================

VỊ TRÍ FILE: Server/Settings/Skills.txt
CÁC FILE LIÊN QUAN CÙNG THƯ MỤC: Missile.txt (xem từ điển số 1),
  状态图形对照表.txt (bảng trạng thái/hiệu ứng đặc biệt - Aura),
  các file .lua trong Server/Script/Skill/ (xem từ điển số 3).
VAI TRÒ: liệt kê TOÀN BỘ skill người chơi và NPC dùng trong game -
  quy định trạng thái, dạng skill, cự ly/cách tương tác, và CHUỖI
  36+ CẤP THUỘC TÍNH (LvlSetting/LvlData) tham chiếu sang file .lua.

------------------------------------------------------------------
NHÓM 1: ĐỊNH DANH CƠ BẢN
------------------------------------------------------------------
A. SkillName / Name (str) - tên skill hiển thị.
B. Property (str) - mô tả tính chất căn bản (hỗ trợ bị động, chủ
   động, tấn công, bùa chú...). Ví dụ gốc: skill Thiếu Lâm Côn
   Pháp có property "Hỗ trợ bị động cho tấn công".
   [XÁC NHẬN] dữ liệu thật: vd "Công kích ngoại công", "Công kích
   nội công" xuất hiện đúng với các skill tấn công (Tam Nga Tề
   Tuyết, Đoạn Hồn Sương Tinh Kiếm...). Dạng text.
C. SkillId (num) - ID riêng của skill.
   [BỔ SUNG - QUAN TRỌNG] SkillId PHẢI là duy nhất trong toàn file
   ,vì engine dùng SkillId làm khóa tra cứu duy nhất.
D. Attrib (num) - thuộc tính skill , quyết định loại [WeaponLimit] sử dụng lấy data từ 
[SkillAttrib] : 
9999=<color=Metal>Vâ c«ng trÊn ph¸i<color>
;
101=Vâ c«ng l­u ph¸i: <color=Cyan>Th­¬ng ph¸p (Ngo¹i c«ng)<color>
102=Vâ c«ng l­u ph¸i: <color=Cyan>§ao ph¸p (Ngo¹i c«ng)<color>
103=Vâ c«ng l­u ph¸i: <color=Cyan>Chïy ph¸p (Ngo¹i c«ng)<color>
104=Vâ c«ng l­u ph¸i: <color=Earth>Th­¬ng ph¸p (Hç trî)<color>
105=Vâ c«ng l­u ph¸i: <color=Earth>§ao ph¸p (Hç trî)<color>
106=Vâ c«ng l­u ph¸i: <color=Earth>Chïy ph¸p (Hç trî)<color>
;
201=Vâ c«ng l­u ph¸i: <color=Cyan>C«n ph¸p (Ngo¹i c«ng)<color>
202=Vâ c«ng l­u ph¸i: <color=Cyan>QuyÒn ph¸p (Ngo¹i c«ng)<color>
203=Vâ c«ng l­u ph¸i: <color=Cyan>§ao ph¸p (Ngo¹i c«ng)<color>
204=Vâ c«ng l­u ph¸i: <color=Cyan>C«n ph¸p/§ao ph¸p (Ngo¹i c«ng)<color>
205=Vâ c«ng l­u ph¸i: <color=Earth>Ch­ëng ph¸p/C«n ph¸p/§ao ph¸p (Hç trî)<color>
206=Vâ c«ng l­u ph¸i: <color=Earth>C«n ph¸p (Hç trî)<color>
207=Vâ c«ng l­u ph¸i: <color=Earth>QuyÒn ph¸p (Hç trî)<color>
208=Vâ c«ng l­u ph¸i: <color=Earth>§ao ph¸p (Hç trî)<color>
; Å
301=Vâ c«ng l­u ph¸i: <color=Cyan>Phi tiªu (Ngo¹i c«ng)<color>
302=Vâ c«ng l­u ph¸i: <color=Cyan>Phi ®ao (Ngo¹i c«ng)<color>
303=Vâ c«ng l­u ph¸i: <color=Cyan>Tô tiÔn (Ngo¹i c«ng)<color>
304=Vâ c«ng l­u ph¸i: <color=Green>H·m TÜnh (Néi c«ng)<color>
305=Vâ c«ng l­u ph¸i: <color=Cyan>Phi Tiªu/Phi ®ao/Tô tiÔn (Ngo¹i c«ng)<color>
306=Vâ c«ng l­u ph¸i: <color=Earth>Phi Tiªu/Phi ®ao/Tô tiÔn (Hç trî)<color>
;
401=Vâ c«ng l­u ph¸i: <color=Cyan>§ao ph¸p (Ngo¹i c«ng)<color>
402=Vâ c«ng l­u ph¸i: <color=Green>Ch­ëng ph¸p (Néi c«ng)<color>
403=Vâ c«ng l­u ph¸i: <color=Fire>Bïa chó (Phßng ngù)<color>
404=Vâ c«ng l­u ph¸i: <color=Earth>§ao ph¸p (Hç trî)<color>
405=Vâ c«ng l­u ph¸i: <color=Earth>Ch­ëng ph¸p (Hç trî)<color>
;
501=Vâ c«ng l­u ph¸i: <color=Cyan>KiÕm ph¸p (Ngo¹i c«ng)<color>
502=Vâ c«ng l­u ph¸i: <color=Green>Ch­ëng ph¸p (Néi c«ng)<color>
503=Vâ c«ng l­u ph¸i: <color=Pink>Hç trî<color>
504=Vâ c«ng l­u ph¸i: <color=Earth>KiÕm ph¸p (Hç trî)<color>
505=Vâ c«ng l­u ph¸i: <color=Earth>Ch­ëng ph¸p (Hç trî)<color>
;´
601=Vâ c«ng l­u ph¸i: <color=Cyan>§ao ph¸p (Ngo¹i c«ng)<color>
602=Vâ c«ng l­u ph¸i: <color=Green>Song ®ao (Néi c«ng)<color>
603=Vâ c«ng l­u ph¸i: <color=Earth>§ao ph¸p (Hç trî)<color>
604=Vâ c«ng l­u ph¸i: <color=Earth>Song §ao (Hæ trî)<color>
;
701=Vâ c«ng l­u ph¸i: <color=Cyan>Bæng ph¸p (Ngo¹i c«ng)<color>
702=Vâ c«ng l­u ph¸i: <color=Green>Ch­ëng ph¸p (Néi c«ng)<color>
703=Vâ c«ng l­u ph¸i: <color=Earth>Bæng ph¸p (Hç trî)<color>
704=Vâ c«ng l­u ph¸i: <color=Earth>Ch­ëng ph¸p (Hç trî)<color>
;
801=Vâ c«ng l­u ph¸i: <color=Cyan>M©u ph¸p (Ngo¹i c«ng)<color>
802=Vâ c«ng l­u ph¸i: <color=Green>§ao ph¸p (Néi c«ng)<color>
803=Vâ c«ng l­u ph¸i: <color=Fire>Bïa chó (Ngo¹i c«ng)<color>
804=Vâ c«ng l­u ph¸i: <color=Cyan>M©u ph¸p (Hç trî)<color>
805=Vâ c«ng l­u ph¸i: <color=Green>§ao ph¸p (Hç trî)<color>

901=Vâ c«ng l­u ph¸i: <color=Cyan>KiÕm ph¸p (Ngo¹i c«ng)<color>
902=Vâ c«ng l­u ph¸i: <color=Green>QuyÒn ph¸p (Néi c«ng)<color>
903=Vâ c«ng l­u ph¸i: <color=Cyan>KiÕm ph¸p (Hç trî)<color>
904=Vâ c«ng l­u ph¸i: <color=Green>QuyÒn ph¸p (Hç trî)<color>
;
1001=Vâ c«ng l­u ph¸i: <color=Cyan>§ao ph¸p (Ngo¹i c«ng)<color>
1002=Vâ c«ng l­u ph¸i: <color=Green>KiÕm ph¸p (Néi c«ng)<color>
1003=Vâ c«ng l­u ph¸i: <color=Fire>Bïa chó (Néi c«ng)<color>
1004=Vâ c«ng l­u ph¸i: <color=Earth>§ao ph¸p (Hç trî)<color>
1005=Vâ c«ng l­u ph¸i: <color=Green>KiÕm ph¸p (Hç trî)<color>
;
1006=Vâ c«ng l­u ph¸i: <color=Cyan>Ngo¹i c«ng<color>
1007=Vâ c«ng l­u ph¸i: <color=Green>Néi c«ng<color>
1008=Vâ c«ng l­u ph¸i: <color=Earth>Hç trî - bÞ ®éng<color>
1009=Vâ c«ng l­u ph¸i: <color=Fire>Hç trî - chñ ®éng<color>
1010=Vâ c«ng l­u ph¸i: <color=Fire>Bïa chó<color>
E. SkillStyle (num, 0-12) - loại skill:
0 = không phân loại (tùy missile),
1 = tấn công,
2 = hỗ trợ chủ động,
3 = bị động,
4 = gọi, 
5 = độc sát, 
6 = them độc,
7 = nạp(?),
8= ẩn(?), 9= thay đổi, 10=đặt mìn, 11= sửa chữa, 12= bắt giữ.
F. SkillIcon (str) - đường dẫn icon .spr.
G. PreCastSpr (str) - hiệu ứng hình ảnh TRƯỚC khi xuất chiêu (vd:
   quầng xanh quanh nhân vật Nga Mi trước khi ra chiêu).
H. ManCastSnd / I. FMCastSnd (str) - âm thanh nam/nữ khi thi triển.
J. StateSpecialId (num) - trạng thái đặc biệt, chủ yếu cho buff
   (hình dạng hiển thị quanh mình + đồng đội khi mở buff).
K. IsAura (num 0/1) - trạng thái chỉ tồn tại khi đang MỞ skill đó,
   đổi sang skill khác là mất.
L. LRSkill (num) - skill tay trái/phải: 0=cả 2 bên, 1=chỉ trái,
   2=chỉ phải, >=3 chưa test.
M. NeedShadow (0/1) - có bóng hay không.
N. AttackRadius (num) - tầm đánh.
   [BỔ SUNG] Trong dữ liệu thật, giá trị thường tăng dần theo độ
   mạnh skill: 90-300 (skill cận/tầm trung), 400-520 (skill tầm xa
   cấp cao như Vô Tướng Trảm=400, Tam Nga Tề Tuyết=512).
P. MaxShadowNum (num) - số bóng tối đa ( chỉ hoạt động khi NeedShadow =1)
Q. MslsGenerate (num 0-5) - CÁCH SINH RA ĐƯỜNG ĐÁNH: [hình thái xuất chiêu]
   qua thực nghiệm trên hàng chục skill thật]
     0 = Bình thường (có sao ra vậy - không áp dụng quy tắc đặc
         biệt nào)
     1 = Cùng lúc (skill nhiều missile, xuất CÙNG LÚC)
     2 = Tuần tự (n missile xuất LẦN LƯỢT)
     3 = Ngẫu nhiên (không theo quy tắc nào - mỗi missile xuất
         hướng ngẫu nhiên độc lập)
     4 = Cùng lúc ngẫu nhiên (missile xuất ra CÙNG LÚC nhưng HƯỚNG BAY
         không đồng nhất )
      9 chiêu con, Param1=Param2=0 vì cơ chế ngẫu nhiên tự lo
         phân bố trí, KHÔNG cần tham số góc/độ trễ)
     5 = Trải rộng (các missile xuất ra dàn hàng ngang trên 1 mặt phẳng -
         ví dụ thật: "Tam Nga Tề Tuyết" SkillId 328 dùng giá trị
         này kết hợp MisslesForm=0)
R. MslsGenerateData (num) – Giãn cách giữa 2 hoặc nhiều ĐẠN :
   Nếu MslsGenerate = 1;4 thì : MslsGenerateData chắc chắn bằng 0
   Nếu MslsGenerate = 0;2;3;5 thì : phát sinh thêm 2 trường hợp :
           1/ Nếu ChildSkillNum (num) = 1 thì MslsGenerateData sẽ = 0 không có gì xảy ra. ( dù có điều chỉnh giá trị > 0 , vẫn không có tác dụng )
           2/ Nếu ChildSkillNum (num)   < 1 thì MslsGenerateData sẽ là thời giãn cách giữa (độ trễ ) 2 hoặc nhiều ĐẠN trong 1 lần tung chiêu , giá trị càng lớn độ trễ càng lâu., nếu =0 thì tất cả các ĐẠN xuất ra cùng lúc với nhau ( xếp chồng lên nhau).
S. CharClass (num 1-5) - ngũ hành: 1 kim, 3 mộc, 2 thủy, 4 hỏa, 5 thổ.
T. MisslesForm (num 0-7) - DẠNG MISSILE: [Quỹ đạo bay của “ĐẠN”]
     0 = Dạng tường phẳng (thường dùng cho dạng QUẠT/fan khi kết
         hợp MslsGenerate=1 hoặc 5 - đã xác nhận qua ví dụ "Truy
         Phong Độc Cát" 32 chiêu con, Param2=128 = quạt 180 độ)
     1 = Đường thẳng 
     2 = Bột ( Mảnh vụ - ví dụ thật: "Băng Tung Vô Ảnh" =5 tức là có 5 ĐẠN
         con)
     3 = hình tròn ( tự chia góc không bị ảnh hưởng bởi Param) 
     4 = Vùng 
     5 = Điểm
     6 = ngay vj trí mục tiêu .
     7 = ngay vị trí bản thân .
U. ChildSkillId (num) - skill NỀN (missile gốc) nó được trích suất từ Cột A “MissleId” của file Missles.txt mà Skill hiện tại dựa vào và sử dụng.
   [BỔ SUNG] Trong dữ liệu thật, nhiều skill CHIA SẺ chung 1
   ChildSkillId (ví dụ: ChildSkillId=142 "Thâu Thiên Hoán Nhật"
   được "Tam Nga Tề Tuyết" SkillId 328 sử dụng làm mẫu missile). Đây là chuyện bình thường , hệ thống cho phép có thể xảy ra.
V. ChildSkillLevel (num) - level của skill nền, thường = -1 (skill
   nền không có level hoặc có level nhưng không ảnh hưởng kết quả).
W. ChildSkillNum (num) - SỐ LƯỢNG skill nền được sinh ra (thống nhất cách gọi là số lượng “ĐẠN” được sinh ra )(ví dụ: kỹ năng Thiên hạ vô cẩu có 3 bổng ( 3 ĐẠN)
  1#  Vậy nên , muốn có 6 bổng thì ChildSkillNum (num) = 6 .
2# Lưu ý : Thông số này bị chia phối bởi hàm misssle_num trong file .Lua ( tức là nếu trong file .lua ,misssle_num = 3 thì cho dù ChildSkillNum (num) = 6 thì vẫn chỉ đánh ra 3 ĐẠN (bổng)  thay vì 6 bổng như 1# . 

X. BaseSkill (0/1) - có dựa trên skill nền hay không.
Y. CharAnimId (num) - animation nhân vật khi thi triển skill.
   [BỔ SUNG] Đổi giá trị này có thể khiến nhân vật đánh theo "kiểu
   nội công khác" (quan sát từ quá trình phân tích trước đó).
Z. EventSkillLevel (0/1) - có hiệu ứng riêng khi lên cấp skill hay
   không (vd vòng tròn vàng quanh nv khi lên level).
AA. IsMelee (0/1) - cận chiến hay không.
AB. WaitTime (num) - thời gian CHỜ trước khi xuất skill, dùng cho
   skill ĐA HỖ TRỢ (nhiều hiệu ứng nối tiếp). Ví dụ gốc: "Phong
   Sương Nga Mi" gồm Kim Đỉnh Phát Quang (ra đầu, 4 tia tỏa) ->
   Phong Sương (mưa rơi) -> Thiên Phát Thiên Điệp (4 tia nhập) -
   mỗi skill sau phải wait skill trước một lúc rồi mới xuất ra. 
AC. (chưa rõ tên cột / ý nghĩa) - [CHƯA RÕ], tài liệu gốc cũng
   không biết.
AD. SkillCostType (num 0-3) = {MANA, LIFE (máu), STAMINA (thể
   lực), MONEY (tiền)} - loại tài nguyên tiêu hao.
AE. CostValue (num) - lượng tiêu hao tương ứng.
AF. TimePerCast (num) - thời gian hồi chiêu. Nên để 0 để hài hòa
   (gọi tắt là CountDown) 
AG. IsPhysical (0/1) - có tính là sát thương VẬT LÝ không (ảnh
   hưởng việc nhận cộng dồn % sát thương, điểm, bạo kích, đối
   thương, hồi máu, hút sinh lực...).
AH. TargetOnly (0/1) - =1: chỉ tác động lên ĐÚNG 1 mục tiêu đang
   nhắm, dù kiếm có bay rợp trời các con khác cũng không chết.
AI. TargetEnemy (0/1) - có hiệu lực với kẻ thù.
AJ. TargetAlly (0/1) - có hiệu lực với đồng đội (vd buff Nga Mi).
AK. TargetSelf (0/1) - có hiệu lực lên bản thân (chỉ dành cho skill
   phụ trợ cho mình).
AL. TargetObj (0/1) - có hiệu lực lên OBJECT/item (vd đao Thiếu
   Lâm chặt rớt đồ khi đánh quái).
AM. ByMissle (0/1) - dame/hiệu ứng tính theo THỜI ĐIỂM MISSILE VA
   CHẠM hay không. =1: missile vừa chạm là có tác động ngay. Ví dụ
   đối lập: skill đa thức sát (Thiên Vương Thương) cần đủ 5 thương
   mới tính dame - nếu ByMissle=1 thì từng thương đã tính dame
   riêng ngay từ đầu (5 dame riêng lẻ thay vì 1 dame gộp).
AN. IsUseAR (0/1) - có dùng độ chính xác (Attack Rating) không.
AR-AZ. StartEvent/StartSkillId, FlyEvent/FlySkillId, FlyEventTime,
   CollideEvent/CollidSkillId, VanishedEvent/VanishedSkillId:
    Chuỗi 4 SỰ KIỆN trong vòng đời 1 skill, mỗi sự kiện có thể kích hoạt 1 SkillId con, để khích hoạt thì gía trị ở AR AT AW AY phải = 1
     - StartEvent (AS = idskill con): ngay khi XUẤT chiêu chính ( gắn bó mật thiết với hàm thực thi skill_startevent trong script của file Lua , ví dụ nếu script đã thiết lập một SkillId thì cho dù StartSkillId có mang SkillId của  một skill khác thì hệ thống vẫn chỉ nhận giá trị của script) 
     - FlyEvent (AU = idskill con) : khi missile ĐANG BAY (giữa chừng)(skill con sẽ bay theo Skill chính) trong khoảng thời gian quy định tại AV (thường là =3)
( gắn bó mật thiết với hàm thực thi skill_flyevent trong script của file Lua , ví dụ nếu script đã thiết lập một SkillId thì cho dù FlySkillId có mang SkillId của  một skill khác thì hệ thống vẫn chỉ nhận giá trị của script)
     - CollideEvent( AX = idskill con): khi missile VA CHẠM mục tiêu sẽ xuất hiện skill con ( gắn bó mật thiết với hàm thực thi skill_collideevent trong script của file Lua , ví dụ nếu script đã thiết lập một SkillId thì cho dù CollidSkillId có mang SkillId của  một skill khác thì hệ thống vẫn chỉ nhận giá trị của script)
     - VanishedEvent( AZ = idskill con): khi missile BIẾN MẤT (kết thúc) sẽ sinh ra skill con ( Nứt đất của Thiên ngoại lưu tinh, lồng sắt của Huyền Âm trảm).
( gắn bó mật thiết với hàm thực thi skill_vanishedevent trong script của file Lua , ví dụ nếu script đã thiết lập một SkillId thì cho dù VanishedSkillId có mang SkillId của  một skill khác thì hệ thống vẫn chỉ nhận giá trị của script)
 -  Đây là cơ chế tạo COMBO NHIỀU TẦNG (ví dụ thật: "Càn Khôn Quy
   Nhất" SkillId 1963 --StartEvent--> "Bát Cấp Quy Phục" SkillId
   1964; "Đoạt Mạng Tam Thiên Kiếm" SkillId 1965 --StartEvent-->
   "Đoạt Mạng 3000" SkillId 1966; "Ba Kiếm 110" SkillId 572
   --FlyEvent--> "Băng Nhũ Đâm Chọt" SkillId 573).
BA. ReqLevel : Yêu cầu Level nhân vật tối thiểu để có thể sử dụng được kỹ năng ( ví dụ =80 tức nhân vật đạt level 80 mới có thể sử dụng
 BB. MaxLevel : level tối đa của skill này có thể đạt được ( ví dụ =20 tức skill sẽ max level 20 không thể tang cấp them nữa )
BC. EqtLimit: [WeaponLimit]  Cần phải sử dụng loại vũ khí gì để có thể sử dụng Skill , bị ảnh hưởng bởi [Attrib (num)]:
-2=<color=Red>Kh«ng h¹n chÕ vũ khí <color>
-1=<color=White> Tay kh«ng <color>
0=<color=Cyan> KiÕm <color>
1=<color=Green> §¬n §ao <color>
2=<color=Wood> C«n Bæng <color>
3=<color=Yellow> Th­¬ng <color>
4=<color=Pink> Song Chïy <color>
5=<color=Metal> Song §ao <color>
100=<color=Earth> Phi Tiªu<color>
101=<color=Water>Phi §ao<color>
102=<color=Blue>Tô TiÔn<color> 

BD. HorseLimit:
có thi triển trên ngựa được không.
BE. DoHurt (num) - thời gian từ lúc xuất chiêu đến lúc đối phương
   nhận hiệu ứng. Với skill tầm xa đơn (1 lần/1 chiêu): nên =0
   Với skill đa thức sát: ví dụ
   "Truy Tinh Trục Nguyệt" (Thiên Vương) DoHurt=60, nghĩa là thời
   gian quái chờ dính dame = 40% thời gian missile đi hết khoảng
   cách (KHÔNG PHẢI thời gian thương chạm thực tế vào quái). Tốc độ
   missile THỰC do hàm missle_speed_v trong file .lua quy định.
    Tức có thể hiểu là Hệ số tỉ lệ gây ra co giật ( + Thời gian phục hồi ).
BF. WeaponSkill: skill CHỈ dành cho vũ khí dựa vào (có điều
   kiện loại vũ khí đang cầm). 
BG. Param1: độ lệch góc giữa 2 hoặc nhiều tia ĐẠN trên cùng 1 mặt phẳng 
BL. Param2 : Khoảng cách giữa nhân vật xuất chiêu với ĐẠN ngay thời điểm nó được xuất ra . = 0 : theo mặc định, > 1: khoảng cách càng xa, tỉ lệ thuận khi giá trị tăng lên . 
   [XÁC NHẬN + BỔ SUNG LỚN qua thực nghiệm số liệu thật - đây là
   phần quan trọng nhất đã làm rõ được trong toàn bộ quá trình phân
   tích] Ý NGHĨA PHỤ THUỘC HOÀN TOÀN vào loại skill (MslsGenerate/
   MisslesForm/ChildSkillNum), KHÔNG có 1 nghĩa cố định duy nhất:

   (a) Skill missile TUẦN TỰ (MslsGenerate=2): Param1 = ĐỘ LỆCH
       THỜI GIAN (tick nội bộ) giữa các đòn liên tiếp. Giá trị quan
       sát được gần như cố định ~8-10 dù số lượng chiêu con khác
       nhau (2,3,4...) - tức đây là khoảng cách THỜI GIAN GIỮA 2
       LẦN RA, không phụ thuộc số lượng.
   (b) Skill missile CÙNG LÚC dạng QUẠT (MslsGenerate=1 hoặc 5):
       Param2 = GÓC GIÃN CÁCH giữa các missile, đơn vị là HỆ GÓC
       8-BIT (0-255 tương ứng 0-360 độ, KHÔNG PHẢI độ thông
       thường). Ví dụ thật: Param2=128 (~180 độ, nửa vòng tròn)
       dùng chung cho cả 3 skill Truy Phong Độc Cát (32 chiêu con),
       Ma Viêm Tại Thiên (16 chiêu con), Phong Hỏa Liên Thiên (8
       chiêu con) - chứng minh đây là TỔNG GÓC QUẠT CỐ ĐỊNH, không
       phụ thuộc số lượng missile (số missile chỉ quyết định mật độ
       rải trong quạt). Param2=64 (~90 độ), Param2=24 (~34 độ, quạt
       hẹp). Trường hợp đặc biệt: Param2=65537 (=0x10001, dạng đóng
       gói 2 giá trị 16-bit) xuất hiện ở các skill dùng
       MslsGenerate=5 + MisslesForm=0 (vd "Phá Thiên Trảm", "Tam
       Nga Tề Tuyết", "Phi Long Tại Thiên") - ý nghĩa chính xác 2
       nửa-từ con [CHƯA RÕ HOÀN TOÀN], nhưng nhiều khả năng là 2
       tham số con (min/max) của độ biến thiên ngẫu nhiên.
   
   (d) Skill dùng MslsGenerate=4 (cùng lúc ngẫu nhiên): thường
       Param1=Param2=0 vì cơ chế ngẫu nhiên tự lo phân bố, không
       cần tham số tường minh (ví dụ: "Vô Tướng Trảm").
   => KẾT LUẬN THỰC HÀNH: muốn biết chính xác Param1/Param2 nghĩa
      là gì cho 1 skill cụ thể, PHẢI mở file .lua tương ứng (cột
      LvlSetScript) xem hàm nào đọc biến param1/param2, vì cùng 1
      con số có thể mang ý nghĩa vật lý hoàn toàn khác nhau.
BH. StopWhenMove (0/1) - dừng skill khi di chuyển.
BI. HeelAtParent (num) - =1: missile xuất phát từ skill ĐẦU TIÊN
   (nếu có) hoặc từ NGƯỜI xuất skill nếu không có skill đầu. Bỏ
   trống/0 = trạng thái mặc định.
BJ. RelativePosType - [CHƯA RÕ], tài liệu gốc cũng không biết.
BK. PeaceCanUse (0/1) - =1: skill dùng được ở CHẾ ĐỘ HÒA BÌNH,
   thường dành cho skill buff (vị trí người ở đâu thì vòng buff ở
   đó). =0: mặc định của skill.
BL. ShowEvent (0/1) - thể hiện SỰ KIỆN PHỤ TRỢ khi xuất chiêu.
BM. LvlSetScript (str) - ĐƯỜNG DẪN tới file .lua quy định các
   thuộc tính chiến đấu/phụ trợ THỰC (vd \script\skill\wudang.lua).

------------------------------------------------------------------
NHÓM 2: KHỐI THUỘC TÍNH THEO CẤP (LvlSetting / LvlData) - CÁC CỘT
LvlSetScript : đường dẫn liên kết tới file Lua để triển khai các hàm thực thi . 
------------------------------------------------------------------
[XÁC NHẬN + BỔ SUNG] Cấu trúc lặp lại: LvlSetting1/LvlData1,
LvlSetting2/LvlData2, ... LvlSetting20/LvlData20 (tối đa 20 cặp
theo header thực tế, KHÁC với con số "10, từ 11 trở đi bất hoạt"
ghi trong tài liệu gốc file thứ 3 - CÓ THỂ do phiên bản server
khác nhau, hoặc giới hạn 10 chỉ áp dụng cho phiên bản server mà
người viết tài liệu gốc đang dùng; dữ liệu thực tế đã thấy 14-18
cặp được sử dụng cho 1 skill ví dụ "Ba Kiếm 110").
  - LvlSettingN (str) = TÊN thuộc tính magic (chính xác như tên
    biến trong file .lua, ví dụ "physicsenhance_p", "colddamage_v")
  - LvlDataN (str) = TÊN SKILL (key trong bảng SKILLS của file
    .lua) mà thuộc tính đó áp dụng cho - LUÔN là LvlData key trùng
    với giá trị ở cột LvlSetScript bên cạnh nó.
  Ví dụ thật đầy đủ: skill "Tam Nga Tề Tuyết" SkillId=328,
  LvlSetScript=\script\skill\emei.lua, LvlData=sane_jixue - mỗi
  cặp LvlSettingN='tên_thuộc_tính', LvlDataN='sane_jixue'.
  QUAN TRỌNG: nếu 1 thuộc tính CÓ trong file .lua nhưng KHÔNG được
  khai báo trong 1 cặp LvlSetting/LvlData tương ứng ở đây, thuộc
  tính đó sẽ KHÔNG được đọc/áp dụng vào game (đã xác nhận qua lỗi
  thực tế "addskilldamage0" khai báo trong txt nhưng không tồn tại
  trong .lua -> luôn trả về rỗng).

CUỐI CÙNG: SkillDesc (str) - mô tả skill hiển thị cho người chơi.
[Nghiên cứu cách hàm SkillDesc (str) hoạt động ]
------------------------------------------------------------------
GHI CHÚ LỖI THƯỜNG GẶP ĐÃ PHÁT HIỆN QUA THỰC TẾ (để tra cứu nhanh
khi debug):
------------------------------------------------------------------
1. Trùng SkillId giữa 2 nhóm skill không liên quan (vd 1963-1966,
   1963-1981) - gây xung đột dữ liệu tiềm ẩn.
2. LvlSetting khai báo TÊN THUỘC TÍNH KHÔNG TỒN TẠI trong file .lua
   tương ứng (vd "addskilldamage0" thay vì "addskilldamage2") ->
   thuộc tính đó sẽ luôn rỗng khi hiển thị/tính toán trong game.
3. skill_cost_v GIẢM theo cấp (vd cấp 1=32, cấp 20=2) trong khi
   toàn bộ các skill khác đều tăng/giữ nguyên - dấu hiệu gõ nhầm số
   liệu.
==================================================================
