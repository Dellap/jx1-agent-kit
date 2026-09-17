# EbookJx 3.0 (jxvietnam) — ghi chú tra cứu

> ⚠️ **ĐÍNH CHÍNH (đối chiếu client/server thật 17/09/2026):**
> - Bài 12/13 — tên file GUI: client `settings/NpcRes/界面状态与图形对照表.txt` (dòng cùng id skill → spr); server `settings/状态与光效图形对照表.txt`.
>   Tên `状态图形对照表.txt` của ebook 2010 **không còn tồn tại**.
> - Bài 8 bước 5 (đồng bộ `Skills.txt` → `represent04.dll`): **KHÔNG áp dụng** — client `<GAME_HOST_IP>` **không có** `represent04.dll` (chỉ `represent2/3.dll`); bảng skill client đọc từ `settings/skills.txt` (727 KB, có cả server và client).
> - Bài 14: ví dụ thật trên server nhà = `settings/droprate/npcdroprate20.ini` (Count=54, RandRange=300000, MoneyRate=10, MoneyScale=50); `songjing.ini` trong ebook **không có** trên server.
> - Bài 15: nhãn cột `N/O/P/Q/R/S` là theo **cột Excel bản 2010**; trên `settings/npcs.txt` hiện tại 5 cột đó = `ArmorType(13)/HelmType(14)/WeaponType(15)/HorseType(16)/RideHorse(17)` ⇒ **đọc theo header, đừng đếm**.
> - Bài 13: client `<GAME_HOST_IP>` — `Spr/NpcRes` **chỉ có `man`, KHÔNG có `woman`** (res nữ phải tự tạo thư mục `woman` trước).
> - Bài 18: `顶部控制条.ini` thật ở `ui/ui_ctc_v2/` và `ui/ui_vlmp/`; `Spr/Ui4/主界面/血蓝/` **không tồn tại**; thanh máu/mana nhà = `Spr/Ui3/主界面/生命条.spr` + `内力条.spr` ⇒ phải map lại toàn bộ.
> - Bài 11-12: tên cột thật — `cột J = StateSpecialId (id 10)`, `cột T = MisslesForm (id 20)`, `missles.txt cột 1 = MissleId`.

Nguồn: **"Ebook JX server 3.0"** — CHM do **Jxvietnam** (thành viên Clbgamesvn.com, Yahoo `<EMAIL>`)
biên soạn, **thời gian 10/2010**. Nội dung = bài trên box JX của clbgamesvn.com (ghi rõ tác giả từng bài: thaihoa91,
sandaru, kikina, chickennood, DNT, notfile, zonjkut3, invalid-password, tungpro102, Ronaldo, ICarus, Cubin, Giangleloi)
+ phần tự viết. Ebook 1.0 (Cubin) / 2.0 (Giangleloi) **không** lặp lại, trừ bài cài JX A→Z.

Bản gốc đầy đủ (HTML + 92 ảnh + 4 file nén): **`~/jx1-knowledge/ebookjx3/`**
Bản text đã bóc HTML (26 file, tên file = path gốc với `/`→`__`): **`~/jx1-knowledge/text/ebookjx3__*.txt`**

> ⚠️ **Cảnh báo dùng lại**: toàn bộ phần **cài đặt** viết cho Windows XP thời 2010 — SQL Server 2000, card mạng ảo +
> IP `192.168.x.2`, font China PRC từ thư mục `I386`, 6 file `*.exe` chạy tay. **Không áp dụng cho server nhà**
> (JX1 trên WSL2 CentOS7, `ssh <SSH_ALIAS2>` = root@<GAME_HOST_IP>:2222, 7 systemd service, MySQL :3306) — xem skill
> `<SSH_ALIAS>-server-ops`. Phần **dev dữ liệu client/server** (npcS.txt, skills.txt, missles.txt, NpcRes, SPR, GUI) thì
> **vẫn còn giá trị tra cứu**.
>
> Ghi chú về tiếng Trung trong tài liệu này: chỉ giữ ở **tên file/dữ liệu gốc** (bắt buộc để tra cứu, ví dụ
> `状态图形对照表.txt`, `顶部控制条.ini`, `\Spr\Ui4\主界面\血蓝\血条.spr`) và ở **4 dòng dữ liệu missles nguyên văn**
> của bài "skill phong thần" (dán thẳng vào file dữ liệu nên phải giữ nguyên byte gốc). Mọi phần giải thích là tiếng Việt.

---

## 0. Mục lục → file text

| # | Bài | File text trong `~/jx1-knowledge/text/` | HTML gốc |
|---|---|---|---|
| 1 | Ebook JX 3.0 (giới thiệu) | `ebookjx3__home.txt` | `home.html` |
| 2 | Giới thiệu Game JX | `ebookjx3__html__gioithieu__game.txt` | `html/gioithieu/game.html` |
| 3 | Những thứ cần chuẩn bị | `ebookjx3__html__caigame__chuanbi.txt` | `html/caigame/chuanbi.html` |
| 4 | 1. Cài card mạng ảo | `ebookjx3__html__caigame__cardmang.txt` | `html/caigame/cardmang.html` |
| 5 | 2. Cài SQL server 2000 | `ebookjx3__html__caigame__sql2000.txt` | `html/caigame/sql2000.html` |
| 6 | 3. Import data JX vào SQL | `ebookjx3__html__caigame__import data JX.txt` | `html/caigame/import data JX.html` |
| 7 | 4. Cài Font China | `ebookjx3__html__caigame__fontTQ.txt` | `html/caigame/fontTQ.html` |
| 8 | 5. Config IP server + client | `ebookjx3__html__caigame__config ip server va client.txt` | `html/caigame/config ip server va client.html` |
| 9 | 6. Chạy server | `ebookjx3__html__caigame__chayserver.txt` | `html/caigame/chayserver.html` |
| 10 | HD sử dụng tool JX (view/unpack spr) | `ebookjx3__html__tool__viewspr.txt` | `html/tool/viewspr.html` |
| 11 | Ghép skill Kiếm Thế | `ebookjx3__html__devjx__ghepskillkiemthe.txt` | `html/devjx/ghepskillkiemthe.html` |
| 12 | Ghép vòng sáng | `ebookjx3__html__devjx__ghep vong sang.txt` | `html/devjx/ghep vong sang.html` |
| 13 | Mặt nạ cho JX | `ebookjx3__html__devjx__matna.txt` | `html/devjx/matna.html` |
| 14 | Chỉnh tỉ lệ rơi tiền + đồ | `ebookjx3__html__devjx__chinhtiletien.txt` | `html/devjx/chinhtiletien.html` |
| 15 | Làm NPC từ res nhân vật | `ebookjx3__html__devjx__npcturesnhanvat.txt` | `html/devjx/npcturesnhanvat.html` |
| 16 | Chỉnh thời gian hết hạn account | `ebookjx3__html__devjx__chinhthoigianaccount.txt` | `html/devjx/chinhthoigianaccount.html` |
| 17 | Skill phong thần + skill khủng | `ebookjx3__html__devjx__skill phong than.txt` | `html/devjx/skill phong than.html` |
| 18 | Thanh máu + mana phong thần | `ebookjx3__html__giaodien__thanh mau mana pt.txt` | `html/giaodien/thanh mau mana pt.html` |
| 19 | Giao diện Kiếm Thế | `ebookjx3__html__giaodien__giao dien Kiem The.txt` | `html/giaodien/giao dien Kiem The.html` |
| 20 | Giao diện Võ Lâm 2 | `ebookjx3__html__giaodien__giao dien Vo Lam 2.txt` | `html/giaodien/giao dien Vo Lam 2.html` |
| 21 | Hướng dẫn đưa server lên online | `ebookjx3__html__onlsv__huongdanonlsv.txt` | `html/onlsv/huongdanonlsv.html` |
| 22 | Web cho server online | `ebookjx3__html__onlsv__webjx.txt` | `html/onlsv/webjx.html` |
| 23 | Tổng hợp các server JX | `ebookjx3__html__download__tonghopserver.txt` | `html/download/tonghopserver.html` |
| 24 | Tổng hợp Ebook JX | `ebookjx3__html__download__Ebook JX.txt` | `html/download/Ebook JX.html` |
| 25 | Tổng hợp tool JX | `ebookjx3__html__download__tooljx.txt` | `html/download/tooljx.html` |
| 26 | Cài JX bằng video | `ebookjx3__html__download__Cai JX bang video.txt` | `html/download/Cai JX bang video.html` |

---

## 1. Ebook JX 3.0 — giới thiệu (`home.txt`)

- Tác giả Jxvietnam, forum Clbgamesvn.com, **10/2010**; cảm ơn thaihoa91, sandaru, kikina, chickennood, DNT.
- Ebook **chỉ dành cho newbie**; các bài đã có trong ebook 1.0 (Cubin) và 2.0 (Giangleloi) bị bỏ, **trừ hướng dẫn
  cài JX từ A-Z** (tự biên soạn).
- Không có ảnh minh hoạ (trang bìa `photo/bia.jpg` được dùng ở bài "Giới thiệu Game").

## 2. Giới thiệu Game JX (`gioithieu/game.html`)

- VLTK do VNG mua bản quyền KingSoft, phát hành độc quyền VN, tới 2010 đã ~6 năm.
- JX server của cộng đồng = **"game lậu" lấy từ TQ**, cấu trúc gần giống VLTK nhưng **không** có đủ tính năng của bản VNG.
- Tính năng mà JX server **chưa có** (theo tài liệu 2010): lên/xuống ngựa bằng phím `M`, vòng sáng hoàng kim, kỳ trân các,
  hệ thống bang hội. Ngoài ra tài liệu phàn nàn nạn phá server của người khác.
- Ảnh: `photo/bia.jpg`, `photo/gioithieu1.jpg` … `photo/gioithieu4.jpg`.

## 3. Những thứ cần chuẩn bị (`caigame/chuanbi.html`)

- Quy ước: **Server** = nơi giải nén server (vd `D:\server`), **Client** = nơi giải nén patch client full (vd `D:\client`).
- **Client**: không cần client TQ, lấy client VNG (`game.zing.vn/vo-loam-truyen-ky1/download`) hoặc copy thư mục
  `data/*.pak` từ quán net qua USB 2GB (tài liệu nói **chỉ copy pak cần thiết**, không cần hết; "ai có khả năng" thì
  copy cả thư mục DATA) → cắm về, cut hết pak vào `DATA` của client.
- **Patch client full của thaihoa91** (5 part MediaFire, mirror MegaShare của sandaru) — giải nén, để đâu cũng được.
- **Server mẫu: TSBD của ohishu** (pass giải nén `ohishu`), đặt vd `D:\serverJX`. Tính năng liệt kê: nhiệm vụ Dã Tẩu
  (Kiếm Địa Đồ Chí, Đánh quái, Kiếm Phúc Duyên tiểu/trung/đại), 18 map train + 18 map nhiệm vụ Dã Tẩu, event (Hoàng Kim
  Thạch, Thần Bí Bảo Rương, MĐTB, Thảo Mộc Cung Đình), sự kiện chế tạo thuyền (gặp Xa Phu để lên thuyền, **15 phút cập
  bến PLĐ săn boss vàng**), liên đấu **8h–12h–15h–21h** hằng ngày, Tống Kim, bang hội, luyện % skill **9x/12x/15x**,
  chức năng GM, fix ID map chống gián đoạn, **fix rollback 70%** + fix thời gian khi vật phẩm rớt xuống,
  chuyển sinh/tẩy tủy/ủy thác = BCH, server có **font China PRC**.
- Kèm: **patch client riêng của server** đó, **SQL Server 2000**, **thư mục `I386`** (để cài font China).
- Ảnh: `photo/cai jx/data.JPG`, `photo/cai jx/jx1.jpg`, `photo/cai jx/jx2a.jpg`.
- (Tài liệu không nói rõ) phiên bản/patch number của client VNG, dung lượng, hay danh sách pak "cần thiết" (chỉ nằm trong ảnh).

## 4. Cài card mạng ảo (`caigame/cardmang.html`)

- Chia 3 nhóm: (1) máy **không** internet → **bắt buộc** cài card ảo; (2) có internet → dùng card thật, config IP card
  thật cho server; (3) có card thật **và** lỡ cài card ảo → **chỉ để 1 card Enable**, các card còn lại chuột phải → Disable,
  và config IP server theo IP card đang hoạt động.
- Cách cài card ảo: `Start → Settings → Control Panel → Add Hardware` (làm theo thông báo) → kiểm tra ở
  `Start → Settings → Network Connections`.
- **IP card ảo cấu hình = `192.168.x.2`** (tài liệu nói "tại sao không phải IP khác thì giải thích sau" nhưng **không**
  giải thích ở đâu trong ebook).
- Kiểm tra IP: `Start → Run → cmd → ipconfig` → dòng `IP Address: 192.168.x.2`. Chuột phải card → Enable.
- Ảnh: `photo/cai jx/card1.JPG` … `card12.JPG` (12 ảnh, lưu ý `card1/card8..12` là `.JPG` hoa).

## 5. Cài MS SQL Server 2000 (`caigame/sql2000.html`)

- Công dụng: **lưu account của server**; "bắt buộc cài, không cài thì khỏi chơi JX".
- Chạy `setup.exe` trong thư mục giải nén → Next theo hình → chọn `Start/Continue`.
- **Icon SQL dưới khay hệ thống luôn phải ở trạng thái `Start`** — để `Pause`/`Stop` là lỗi.
- Ảnh: `photo/cai jx/sql01.jpg` … `sql20.JPG` (20 ảnh; `sql01/02/05/07/08/17` là `.jpg` thường, phần còn lại hoa).
- (Tài liệu không nói rõ) tên instance, chế độ authentication (mixed/SQL), mật khẩu `sa`, port — tất cả nằm trong ảnh;
  chỉ suy ra được từ `database.ini` ở bài 8: `User=sa`, `PassWord` để **trống**.

## 6. Import data JX vào SQL Server 2000 (`caigame/import data JX.html`)

- Yêu cầu: SQL Server đang ở trạng thái `start`. Toàn bộ thao tác "làm như hình" + câu cuối "Tí quên còn phải chỉnh
  cái này nữa" (không nói chỉnh gì — nằm trong ảnh).
- Ảnh: `photo/cai jx/sql20.JPG`, `photo/cai jx/import1.JPG` … `import8.JPG`.
- (Tài liệu không nói rõ) tên database đích, file `.mdf/.bak` nào, attach hay restore — **bài này gần như không có chữ,
  chỉ có ảnh**. Suy ra từ bài 8: DB tên `account` (`[account] DataBase=account`).

## 7. Cài Font China (`caigame/fontTQ.html`)

- Chỉ cần cài khi **server có font TQ**; server no-font thì không cần. Cách nhận biết: người share nói rõ, hoặc mở
  server bằng WinRAR vào **thư mục `map`**: tên thư mục **chữ TQ = có font**, **"chữ tầm bậy" (mojibake) = no font**.
- Bước cài: giải nén `I386` (vd `C:\Program Files\Font`) → `Control Panel → Regional and Language Options` →
  tab **Languages**: tick `Install files for East Asian languages` (OK) → tab **Advanced**: `Language for non-Unicode
  programs = Chinese (PRC)` → OK → hộp thoại lỗi → **Browse** tới thư mục `I386` → chọn **`CPLEXE`** → OK; lặp lại
  Browse mỗi lần nó báo lỗi → đợi copy → **restart máy** khi được hỏi.
- Ảnh: `photo/cai jx/font1.JPG` … `font7.JPG`.

## 8. Config IP server + client (`caigame/config ip server va client.html`)

**Cách 1 — sửa tay.** Điều kiện: biết IP card mạng đang chạy (bài 4, ví dụ `192.168.x.2`). Sửa mọi chỗ có IP đó trong
4 file sau (đều mở bằng Notepad):

`Bishop.cfg`
```ini
[Network]
AccSvrIP=192.168.x.2   AccSvrPort=5002
RoleSvrIP=192.168.x.2  RoleSvrPort=55425
ClientOpenPort=5622    GameSvrOpenPort=5632
```

`database.ini` (PassWord để trống)
```ini
[account]
Server=192.168.x.2
DataBase=account
User=sa
PassWord=
```

`relay_config.ini` — các section `[root] [gateway] [dbrole]` có `address=192.168.x.2`; mỗi section còn có
`freebuffer=15`, `buffersize=1048576`, `retryinterval=12000`; `[relay] [host] [chat] [tong]` có
`playercnt=10`, `precision=1`, cùng bộ freebuffer/buffersize/retryinterval; `[root]` và `[serverlist]` mang
`account=sa`, `password=` (trống), `address=192.168.x.2`.

`ServerCfg.ini`
```ini
[Gateway]  Ip=192.168.x.2  Port=5632
[Database] Ip=192.168.x.2  Port=55425
[Transfer] Ip=192.168.x.2  Port=5003
[Chat]     Ip=192.168.x.2  Port=5004
[Tong]     Ip=192.168.x.2  Port=5005
[GameServer] Port=8888
[Overload]   MaxPlayer=600  Precision=400
[Network]    Ip=192.168.x.2
```

**Đồng bộ Server ↔ Client (8 bước)** — lý do: tránh lỗi tên item ra chữ TQ dù .txt là tiếng Việt, học 1 skill ra
skill môn phái khác:
1. Client nền = **client VNG bản mới nhất**, sau đó paste đè **patch client full** lên (Yes to all).
2. Vào `Server/Settings/item` → **tạo 5 thư mục `000`, `001`, `002`, `003`, `004`**.
3. Copy toàn bộ file `.txt` trong `item` → paste vào cả 5 thư mục vừa tạo.
4. Mở `Server/Settings/Skills.txt` bằng Notepad → copy toàn bộ nội dung.
5. Vào client → mở **`represent04.dll` bằng Notepad** (chuột phải → Open With → Notepad) → **paste nội dung Skills.txt
   vào** → Save. (Client đọc bảng skill từ trong DLL này.)
6. Copy **toàn bộ `Server/Settings` (TRỪ thư mục `NpcRes`)** → paste vào `Client/Settings`.
7. Sửa `Client/Settings/Serverlist.ini` = IP chạy server.
8. Lưu ý: các bước trên chỉ đúng cho server đang chơi, **đổi server phải làm lại**.

`Client/settings/Serverlist.ini`
```ini
[List]
RegionCount=1
Region_0=Vo Lam Truyen Ki
[Region_0]
Count=1
0_Title=JX server
0_Address=192.168.x.2
```

**Cách 2 — tool `StartupPro` của sangpronhat**: giải nén, copy tất cả vào server, chỉnh rồi bấm **"Lưu thiết lập"**
(tool tiếng Việt). Ảnh: `photo/tool/startuppro1.JPG`.
→ File cấu hình thật của tool: xem mục **"File kèm theo trong ebook"** (`StartupPro/StartupCfg.ini`).

Ảnh bài này: `photo/cai jx/card12.JPG`, `photo/cai jx/import1.JPG`, `photo/cai jx/config2.JPG`, `photo/tool/startuppro1.JPG`.

## 9. Chạy server (`caigame/chayserver.html`)

- Mỗi lần tắt máy/tắt server phải chạy lại mới vào game được.
- **Cách 1 — chạy tay, đúng thứ tự 6 exe**: `Sword3PaySys.exe` → `S3RelayServer.exe` → `Goddess.exe` → `Bishop.exe`
  → `S3Relay.exe` → `Gameserver.exe`. **Tắt thì tắt ngược thứ tự**: `Gameserver.exe` → `S3Relay.exe` → `Bishop.exe`
  → `Goddess.exe` → `S3RelayServer.exe` → `Sword3PaySys.exe`.
- **Cách 2 — tool `vlStartup.exe` + `Startupcfg.ini`** (xem mục file kèm): copy 2 file vào thư mục server, sửa `[Path]`
  trỏ đúng 5 exe (tool **không** quản `Gameserver.exe`), `[LoginInfo]` khai acc/pass Bishop + S3Relay. Chạy
  `vlStartup.exe` → chọn **"Chạy server AlexTuan"** → tool chạy 5 tiến trình → **phải tự chạy `gameserver.exe`**.
  Có nút **"Ẩn cửa sổ"** và **"Tắt server"**.
- Ảnh: `photo/cai jx/chaysv1.JPG` … `chaysv7.JPG` + `photo/cai jx/chaysv6-1.JPG`.

## 10. HD sử dụng tool JX — view + unpack spr (`tool/viewspr.html`)

- Tool: **RPGViewer** (`RPGViewer.exe`).
- Mở tool → chọn menu chọn **game JX** → chọn thư mục client JX **hoặc** thư mục VLTK của VNG.
- Giao diện: trái = danh sách file `.pak`; phải = file trong pak. **File `.txt/.ini/.lua` hiện trắng** (không preview),
  chỉ ảnh/spr mới hiện hình.
- **Unpack 1 spr**: chọn spr cần lấy → nhớ **số thứ tự hiện ở trên cùng** (ví dụ `3639`) → mở menu Export → ra danh sách
  file theo đúng thứ tự đó → kéo tìm tới số `3639` → có thể chọn nhiều bằng `Ctrl` → **Export** (chọn thư mục lưu) hoặc
  **Export All** để lấy hết.
- File xuất ra tên dạng **`updatejxf04-3639.out`** = `<tên pak>-<số thứ tự trong pak>.out`; **`.out` chính là `.spr`**
  → nên đổi tên thành `.spr` (vd `updatejxf04-3639.out` → `giaymoi.spr`).
- Ảnh: `photo/tool/viewspr.png`, `viewspr1.png`, `viewspr2.JPG`, `viewspr3.png`, `viewspr4.JPG`.

## 11. Ghép skill Kiếm Thế vào JX (`devjx/ghepskillkiemthe.html`) — nguồn zonjkut3

Làm ở **client trước để test**, OK thì chép qua server.
1. Chuẩn bị file `.spr` hình ảnh skill, để ở client (tốt nhất `\spr\xxx.spr`).
2. Mở **`settings/skills.txt` bằng Excel**, chọn 1 skill muốn chỉnh (ví dụ **Huyền Âm Trảm**).
3. Xem **số id ở cột `T`** = **id missile** để ghép. ⚠️ **id trên 197 thì phải tạo thêm 1 missile mới** — tài liệu
   thừa nhận "cái này thì mình k bik" (không hướng dẫn). Ví dụ Huyền Âm Trảm: **id = 165**.
4. Mở **`settings/missles.txt` bằng Notepad (KHÔNG mở bằng Excel)** → tìm dòng có `MissleId` = số vừa tìm (165) →
   bôi đen cả dòng kéo sang phải sẽ thấy **một khoảng ghi đường dẫn `spr\skill\.....spr`** → **thay đường dẫn đó** bằng
   spr mới (vd `spr/huyenamtram.spr`; để ở thư mục khác thì ghi nguyên đường dẫn, vd `spr/vongsang/xxx.spr`).
5. Save tất cả → chạy server → login acc có skill đó → đánh thử.

Ảnh: `photo/dev/ghep skill.jpg`, `photo/dev/ghep skill (1).jpg` … `(4).jpg`.

## 12. Thêm vòng sáng vào JX (`devjx/ghep vong sang.html`) — nguồn zonjkut3

1. Mở `skills.txt` bằng Excel, chọn skill cần ghép vòng sáng (**tốt nhất là La Hán Trận**), **tìm cột `J`** → ví dụ
   **id = 45** (nhớ id). Để file spr ở đâu cũng được, ví dụ `spr\vip.spr`.
2. Vào `client\setting` → tạo thư mục **`NpcRes`** (nếu chưa có) → **move (cut-paste) file `状态图形对照表.txt`
   (bản có font)** vào `NpcRes` → mở bằng Notepad → **tìm dòng `45`** → **thay đường dẫn ngay ở đầu dòng** thành spr mới.
3. Save. **Nếu server đang chạy thì KHÔNG cần chạy lại** → vào game xem.

Ảnh: `photo/dev/vongsang.jpg`, `photo/dev/vongsang (1).jpg`, `photo/dev/vongsang (2).jpg`.
(Tài liệu không nói rõ) file `状态图形对照表.txt` lấy từ server hay client; cột J của skills.txt là cột nào trong header.

## 13. Hướng dẫn làm mặt nạ (mask) cho JX (`devjx/matna.html`) — nguồn Sandaru

Mục tiêu: mặc trang bị nhưng hiển thị hình **NPC**. 5 bước:
1. **Chọn NPC** muốn hoá thân (ví dụ Kim Quốc Đại Tướng) — xem danh sách trong `NpcS.txt`.
2. **Tra Res của NPC**: mở `NpcS.txt` bằng Excel → **cột `L` = `NpcResType`** (ví dụ `enemy022`). Giá trị này tra trong
   2 file res: **`普通npc资源.txt`** và **`普通npc资源信息.txt`**.
3. **Thay res đồ bằng res của NPC**: vào `settings\item\` → mở **`Armorres.txt`** → chọn res muốn đổi (ví dụ Sa di phục
   có res = 2) → mở `男主角躯体.txt` (nam) / `女主角躯体.txt` (nữ) và file `...信息.txt` tương ứng.
   Bố cục cột trong `男主角躯体.txt`: **6 cột đầu = hành động đứng; 5 cột tiếp = đi; 5 cột tiếp = chạy; 4 cột tiếp = chết;
   4 cột tiếp = dính skill; 6 cột tiếp = đánh; còn lại để hành động đứng**.
   Ý nghĩa hậu tố tên file trong `普通npc资源.txt`: `st/st01/st02` = đứng (stand), `wlk` = đi (walk), `die` = chết,
   `bat` = dính skill, `at/at01/at02` = đánh (attack).
   Ví dụ thay cho NPC `enemy022`: đứng `enemy022_st.spr` ×6; đi **và chạy** đều dùng `enemy022_wlk.spr` ×5
   (**"NPC không chạy được nên dùng hành động đi luôn"**); chết `enemy022_die.spr` ×4; dính skill `enemy022_bat.spr` ×4;
   đánh `enemy022_at.spr` ×6; phần còn lại dùng `enemy022_st.spr`. Sau đó **mở `男主角躯体信息.txt` và
   `普通npc资源信息.txt` để ghi chỉ số** (cột tương tự 2 file kia).
4. **Unpack NPC**: dùng **Ldunpack**; lấy đường dẫn NPC từ file **`人物类型.txt`** (ví dụ `\spr\npcres\enemy\enemy022`).
   Trong thư mục Ldunpack tạo 1 text document, ghi mỗi dòng 1 đường dẫn spr:
   `\spr\npcres\enemy\enemy022\enemy022_st.spr` (… `_wlk`, `_die`, `_bat`, `_at`) → save → unpack.
   **Client TQ: unpack `Update.pak` + `Spr.pak`. Client VNG: unpack hết.**
5. **Bỏ kết quả vào client**: `\Client\Spr\NpcRes\man\` (nam) hoặc `\Spr\NpcRes\woman\` (**nữ bắt buộc vào `woman`,
   không thì "khỏi có mask mà xài"**). Làm res nữ thì sửa `女主角躯体.txt` / `女主角躯体信息.txt` tương tự.
- Lưu ý của tác giả: **một vài NPC bị "lak"**, ví dụ ngựa Kiếm Thế — đừng thắc mắc.
- Ảnh: **chỉ có 2 gif nhúng nội tuyến trong CHM (`matna_clip_image001.gif`, `matna_clip_image001_0000.gif` — 2 icon nhỏ
  inline) và KHÔNG được bóc ra thư mục `photo/`**, nên bài này **không có ảnh minh hoạ mở lại được**.
- (Tài liệu không nói rõ) ý nghĩa từng cột trong 2 file `...信息.txt`; nội dung/thứ tự các cột của `Armorres.txt`.

## 14. Chỉnh tỉ lệ rơi tiền và đồ (`devjx/chinhtiletien.html`) — nguồn invalid-password (tự mò)

Ví dụ: **Boss Nam Tống Nguyên Soái**. Mấu chốt: `Settings\npcS.txt` (3 cột) + file droprate riêng.

**a) `npcS.txt`:**
- **Cột `Treasure`** = tổng số đồ & tiền tối đa rớt ra. Heo trắng `Treasure=1` (tối đa 1 cục tiền **hoặc** 1 cục đồ);
  Nam Tống Đại Tướng `Treasure=24` → tối đa **24 cục tiền + 24 cục đồ**. (Tác giả đùa "chỉnh lên 1000 không biết có
  đầy màn hình không" — không nói giới hạn thật.)
- **Cột `ExpParam`** = kinh nghiệm khi giết (Nam Tống Nguyên Soái = `800000`) → **số tiền rớt ra tính theo Exp này**.
- **Cột `DropRateFile`** = đường dẫn file định nghĩa mọi thứ rớt ra, ví dụ `"\Settings\droprate\songjing.ini"`
  (`songjing` = Tống Kim 宋金) — tức mỗi NPC/nhóm NPC có file droprate riêng.

**b) File droprate (vd `songjing.ini`):**
```ini
[Main]
Count=2              ; số LOẠI đồ có thể rớt
RandRange=100        ; mẫu số cho RandRate
MagicRate=50         ; % rớt ĐỒ  (trên Treasure)
MoneyRate=50         ; % rớt TIỀN (trên Treasure)
MoneyScale=10        ; % giá trị mỗi đống tiền (trên ExpParam)
MinItemLevel=1       ; độ VIP thấp nhất (1 = đồ trắng, 10 = đồ xanh nhiều op cao)
MinItemLevelScale=1  ; yêu cầu đẳng cấp thấp nhất (10 mức)
MaxItemLevel=5
MaxItemLevelScale=10
[1]
Genre=4  Detail=99  Particular=1   RandRate=25
[2]
Genre=0  Detail=0   Particular=1   RandRate=50
```
**Công thức tài liệu cho:**
- **Số đống tiền** = `Treasure × MoneyRate%` → 24 × 50% = **12 đống** ("có khi hơn kém 1").
- **Giá mỗi đống tiền** = `ExpParam × MoneyScale%` → 800000 × 10% = **80000 lượng**.
- **Số món đồ** = `Treasure × MagicRate%` → 24 × 50% = **12 món**.
- **Xác suất ra đúng món nào** = `RandRate ÷ RandRange` → món [1] 25/100 = 25% → tối đa 25%×12 ≈ **3 món**;
  món [2] 50/100 = 50% → **6 món**. Vậy trong 12 món lấy được chỉ có ~9 món thực rớt — **3 món còn lại "sẽ không rớt ra"
  vì file chỉ cho rớt có 2 loại**. Tổng `RandRate` các món **không được vượt `RandRange`**.
- **`Count`** = số **loại** đồ khác nhau có thể rớt (`Count=1` = luôn 1 loại; con Nhím `Count=70` = tới 70 món khác nhau).
  "Các món khác nhau không tính đẳng cấp": **Lang Nha Bổng và Kim Cô Bổng tính là 1 món** (cùng loại bổng, khác đẳng cấp).
- **`Genre`/`Detail`/`Particular`** = **ID món đồ**, tra trong `Settings\Item\*.txt`. Ví dụ `Genre=4 Detail=99 Particular=1`
  = ID "4-99-1" = **Nhạc Vương Kiếm** (tra `questkey.txt`; **server khác có thể mang ID khác**). Món [2] là cây đao
  (**tài liệu không xác định là đao gì**).
- **`MinItemLevel`/`MaxItemLevel`** = độ VIP ngẫu nhiên 1..10 (1 = đồ trắng, 10 = đồ xanh nhiều dòng op cao — vẫn random).
  Ví dụ file set 1..5: Nhạc Vương Kiếm thì cái nào cũng như nhau, còn **cây đao** sẽ random op xịn từ 1→5.
- **`MinItemLevelScale`/`MaxItemLevelScale`** = **yêu cầu đẳng cấp** của món đồ, 10 mức: **không yêu cầu, cấp 9, 18, 27,
  36 …** (cấp 9 = bội số 9). Chỉ tác động **cây đao**, không ảnh hưởng vật phẩm nhiệm vụ. Mức 10 → **Đại Phong Đao**,
  mức 9 → **Thanh Long Đao**.
- Không có ảnh minh hoạ.

## 15. Làm NPC từ res của nhân vật (`devjx/npcturesnhanvat.html`) — nguồn thaihoa91

Điều kiện: phải hiểu Res (tài liệu trỏ 2 bài forum clbgamesvn.com: "Những điều cần biết về NpcRes"
`forum.clbgamesvn.com/showthread.php?t=31400` và "Mask (mặt nạ) toàn tập" `...t=31399`).

- Mở **`Server/Settings/NpcS.txt` bằng Excel** (chuột phải → Open with → Excel).
- Chỉ quan tâm **6 cột `N, O, P, Q, R, S`**:
  - `N` — **xoá nội dung ô ở cột N của CHỈ NPC cần làm** (không xoá cả cột của mọi NPC).
  - `O = ArmorType` ↔ `ArmorRes` (áo)
  - `P = HelmType` ↔ `HelmRes` (mũ)
  - `Q = WeaponType` ↔ `WeaponRes` (vũ khí)
  - `R = HorseType` ↔ `HorseRes` (ngựa/thú cưỡi)
  - `S = RideHorse` — chỉ 2 giá trị: **0 = không cưỡi thú, 1 = cưỡi thú**.
- **`S` và `R` phụ thuộc nhau**: `S=0` thì **dù `R` trỏ res ngựa nào cũng không hiển thị** (nhân vật không có thú cưỡi
  trong bảng thông tin F3).
- Xong → save → **đồng bộ Server và Client** → chạy server, vào game test.
- Ảnh: `photo/dev/CachLamNPCTuResNhanVat1.jpg`, `photo/dev/CachLamNPCTuResNhanVat2.jpg`.
- (Tài liệu không nói rõ) **tên cột `N` là gì** (chỉ gọi "cột N"); đồng bộ cái gì (file nào) không nêu chi tiết.

## 16. Chỉnh thời gian hết hạn account (`devjx/chinhthoigianaccount.html`) — nguồn thaihoa91

- Hiện tượng: login báo **"Xin hãy nạp tài khoản rồi mới vào trò chơi"** = **thời gian hết hạn của account vượt quá
  giờ hệ thống trong máy chủ**.
- Cách sửa (SQL Server 2000/2005): mở bảng account (3 bước thao tác theo hình) → **cột `dEndDate` là cột xác định thời
  gian hết hạn** → "chỉnh đơn giản thì cứ đổi số năm"; ví dụ account `volam` được set hết hạn **10/10/2020 lúc
  10:10:10**. Sửa xong **bấm dấu X để tắt là nó tự save**.
- Ảnh: `photo/dev/ChinhNgayAccount1.jpg`, `ChinhNgayAccount2.jpg`, `ChinhNgayAccount3.jpg`.
- (Tài liệu không nói rõ) tên bảng/database cụ thể (chỉ "Database Account"); server nhà dùng MySQL nên tên bảng/cột
  có thể khác — cần verify lại (`dEndDate` nhiều khả năng trùng tên).

## 17. Add skill phong thần + skill khủng (`devjx/skill phong than.html`) — nguồn sandaru

**Skill phong thần gồm 4 skill**: Lôi Động Cửu Thiên, Tam Muội Chân Hỏa, Phong Vân Lôi Động, Huyền Nữ Bổ Thiên.
Cách làm = **thêm dòng dữ liệu missile**, spr bỏ vào **`\spr\skill\magic\`**.

Nguyên văn 4 dòng dữ liệu (giữ nguyên byte gốc để dán vào file missles; tên skill + file spr/sound là dữ liệu gốc):

```
Lôi Động Cửu Thiên
18 雷动九天 0 0 0 10 4 1 4 16 15 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \spr\skill\magic\giutset2.spr 16,1,1 \sound\雷动九天.wav 255 255 239 90
Tam Muội Chân Hỏa
51 三味真火 0 0 1 10 15 1 15 8 41 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 \sound\三味真火.wav \spr\skill\magic\nuilua.spr 14,1,1 123 255 189 90
Huyền Nữ Bổ Thiên
28 玄女补天 0 0 0 10 13 1 13 12 20 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 \sound\五岳朝宗.wav \spr\skill\magic\locxoay.spr 10,1,1 255 255 231 90
Phong Vân Lôi Động
16 风云雷动 1 0 0 10 6 1 6 21 20 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 \sound\风云雷动.wav \spr\skill\magic\giutset.spr 20,1,1 255 255 239 90
```
Đọc nhanh: số đầu = **MissleId** (18 / 51 / 28 / 16); file spr thật dùng: `giutset2.spr`, `nuilua.spr`, `locxoay.spr`,
`giutset.spr`; mỗi dòng còn có bộ tham số `16,1,1` / `14,1,1` / `10,1,1` / `20,1,1` và 4 số cuối (RGB + 90);
dòng Tam Muội Chân Hỏa **đặt `\sound\` trước `\spr\`** (2 dòng còn lại ngược thứ tự) — giữ nguyên như tài liệu.
Tài liệu có link down spr "Fs1" (chết).

**Skill khủng (võ lâm)**: "làm giống như các bước ghép vòng sáng, chỉ thay spr vòng sáng thành spr skill khủng".

Ảnh: `photo/dev/skillphongthan.jpg`, `photo/dev/skillphongthan1.jpg`.

## 18. Thanh máu + mana phong thần (`giaodien/thanh mau mana pt.html`) — nguồn sandaru

1. Giải nén file `顶部控制条.ini` → copy vào **`\Ui\Ui3`**.
2. Bỏ spr đúng 4 đường dẫn sau (client):
   - `\Spr\Ui4\主界面\血蓝\个人状态.spr`
   - `\Spr\Ui4\主界面\血蓝\血条.spr`
   - `\Spr\Ui4\主界面\血蓝\蓝条.spr`
   - `\Spr\Ui4\主界面\血蓝\经验.spr`
3. "Thư mục UI và spr ở trong client".

**File ini kèm theo (đã giải nén thật — xem mục file kèm)** dùng **theme `Ui4`**, khác hẳn theme `CTC` đang dùng ở server nhà:
`[Main] Left=0 Top=20 Moveable=1 Trans=1`, nền `Image=\Spr\Ui4\主界面\血蓝\个人状态.spr`,
`Button0=Name Button1=Level Button2=Life Button3=Mana Button4=Exp`;
`[Life] 10,16 156x10 ClassType=Player_Life` + `[Life_Image] Width=156 Height=8 Image=血条.spr PartType=0`;
`[Mana] 10,28` + `[Mana_Image] 156x8 Image=蓝条.spr PartType=0`; `[Exp] 10,39` + `[Exp_Image] 156x8 Image=经验.spr`;
`[Name_Text] Font=14 HAlign=1 Color=55,231,63`, `[Level_Text]` như trên, các `_Text` của Life/Mana/Exp màu `255,255,255`.

Ảnh bài này: `photo/dev/skillphongthan.jpg` (dùng lại ảnh của bài skill phong thần).
(Tài liệu không nói rõ) file spr nào ứng với máu / mana (chỉ liệt kê đường dẫn); **xung đột với client nhà** đang dùng
`spr/Ui3/主界面/生命条.spr` + `内力条.spr` và `ui/ctc` → phải map lại tên spr nếu muốn dùng.

## 19. Giao diện Kiếm Thế (`giaodien/giao dien Kiem The.html`) — nguồn kikina

- Dành cho **server có font**. Tải về có **2 thư mục `UI` và `SPR`** → copy cả 2 vào client → chạy `game.exe`.
- Ảnh: `photo/dev/giaodienkt1.JPG`, `photo/dev/giaodienkt2.jpg`, `photo/dev/giaodienkt3.jpg`.

## 20. Giao diện Võ Lâm 2 (`giaodien/giao dien Vo Lam 2.html`) — nguồn thaihoa91

- Giải nén ra 2 thư mục **`Font`** và **`No font`**:
  - server **có font** → copy `UI` + `SPR` trong thư mục `font` vào client;
  - server **no font** → copy `UI` + `SPR` trong thư mục `no font`.
- Ảnh: `photo/dev/giaodienjx2_1.PNG`, `photo/dev/giaodienjx2_2.PNG`, `photo/dev/giaodienjx2_3.PNG`.

## 21. Hướng dẫn đưa server lên online (`onlsv/huongdanonlsv.html`) — nguồn tungpro102

**I/ Mở port modem**: `cmd → ipconfig` xem **IP gateway (dòng cuối)** → vào IE/Firefox gõ `http://<gateway>`
(vd `http://192.168.x.1`) → login modem → vào tab **Virtual server** (tên tab tuỳ modem) → mở port theo **mục III**
(lưu ý IP khi mở port).

**II/ Config IP server về IP WAN**:
- Static IP: `My Network Places → View network connections` → config card `Local Area Connection`: dòng 1 = IP trong
  `ipconfig`, dòng 2 = `mặt nạ /24`, dòng 3 = **giống gateway**; DNS dòng 1 = gateway, dòng 2 để trống.
- **Cài Loopback adapter và để IP Loopback = IP WAN**: dòng 1 = IP WAN, dòng 2 = `mặt nạ /24`, dòng 3 để trống,
  DNS để trống. Xem IP WAN ở **`http://canyouseeme.org`**.
- **SQL**: `Database Account → Tables → Serverlist` → sửa IP thành IP WAN.
- **Sửa IP WAN trong file**: `Bishop.cfg`, `Database`, `JXConfig`, `ServerCfg` (**chú ý: dòng `Network` để IP của máy**);
  **Client**: `Settings/Serverlist` sửa thành IP WAN.

**III/ List port cần mở** (dùng web reg acc thì mở thêm **80**):
- Server Thái Sơn Bắc Đẩu by Ohishu (tên thật Vương Minh):
  `5001, 5002, 5003, 5004, 5005, 5425, 55425, 5632, 5622, 50000`
- Server DHAH by Notfile:
  `5001, 5002, 5003, 5004, 5005, 5425, 55425, 6532, 5622, 6666`

Không có ảnh minh hoạ. (Tài liệu không nói rõ) port nào là bắt buộc — list chép theo từng bản server của người khác;
2 list khác nhau ở port `5632/5622/50000/6532/6666`.

## 22. Web cho server online (`onlsv/webjx.html`) — nguồn notfile

- Công dụng: **reg acc + quảng cáo thông tin server**. Tác giả ghi rõ **"web này mình chưa test"**.
- Cài: giải nén → chép thư mục `htdocs` vào **XAMPP** (hoặc dùng **App** thì copy nội dung vào thư mục `www`) →
  vào trình duyệt gõ `localhost`.
- Phần "hướng dẫn" còn lại (~29 KB, chiếm gần hết bài) chỉ là **dán nguyên một file `php.ini`** để chép vào thư mục
  `php` của XAMPP. Nội dung là bản `php.ini` mặc định thời **PHP 5.2** (mở đầu `[PHP]`, các giá trị nổi bật:
  `short_open_tag = Off`, `asp_tags = Off`, `output_buffering = Off`, `precision = 14`, `y2k_compliance = On`,
  `serialize_precision = 100`, `allow_call_time_pass_reference = On`, `safe_mode = Off`, `implicit_flush = Off`,
  `zlib.output_compression = Off`, `variables_order = "GPCS"`, `register_globals = Off`, `register_long_arrays = Off`,
  `report_memleaks = On`, `track_errors = Off`, `html_errors = On`, `error_log` ví dụ `"\xampp\apache\logs\php_error.log"`).
- **Không có**: schema DB, tên bảng, host/user/pass MySQL, hay danh sách file PHP → **bài này không dùng lại được để
  dựng web reg acc** (và phần php.ini đã lỗi thời hoàn toàn với PHP 8).
- Ảnh: `photo/webdemo.jpg`.

## 23. Tổng hợp các server JX (2010) (`download/tonghopserver.html`) — nguồn Ronaldo

Tất cả chỉ còn tên + mô tả (mọi link Google/MediaFire/MegaShare đều đã chết). Danh sách:
- Server Sóng Gió Tình Yêu = DEV by Batca2tay
- Server JX 7.0 II = DEV by Mr.Rezo
- Server Mãnh Long Tranh Bá = DEV by zonjkuto (**pass giải nén `zonjkut3`**)
- Server Thiên Địa Vô Cực = DEV by sandaru
- Server Tình Huynh Đệ = DEV by kikina2009 — **server chưa có thư mục `map`**, phải down thêm server DNT rồi copy
  thư mục `map` qua
- Server Thiện Ác = DEV by Mr ReZo
- Server Đại Hội bạn Hùng = DEV by notfile
- Server Thái Sơn Bắc Đẩu v0.2 = DEV by Ohishu (**pass `ohishu`**)
- Server Phong Vân = DEV by tungpro
- Server Độc Bá V2.0 = DEV by kjmbialon (patch: dùng patch full của thaihoa91 rồi đồng bộ)
- Server Giang Hồ Tình Kiếm (SV Mướp) = DEV by thachlong78
- Server JX-49 = DEV by DNT MASTER ("khá good", từng online với nick Sóng Gió Trung Nguyên)
- Server Giang Hồ Dậy Sóng (MƯỚP) = by Cubinktvn
- Server JX 5.0 = DEV by Mr Rezo
- Server Xuân Thu = DEV by DNT MASTER (**toàn tiếng Tàu**, patch full thaihoa91)
- SV cũ: JX 6.0 II (MrReZo); JX 50 ver 1.0 (King Max, patch full thaihoa91); Tuyệt Tình Kiếm (ThanhVipLn?, patch full thaihoa91)

## 24. Tổng hợp Ebook JX (`download/Ebook JX.html`)

Chỉ là nơi để link 2 ebook trước: **Ebook JX server 1.0 by Cubin**, **Ebook JX server 2.0 by Giangleloi**. Không có nội dung khác.

## 25. Tổng hợp tool JX server (`download/tooljx.html`) — link đều đã chết

| Tool | Dụng ý theo tài liệu |
|---|---|
| Notepad++ | bắt buộc để viết script |
| Ultra Edit + crack | view file dll, … |
| Unpack + Pack | giải nén/pack (hướng dẫn có sẵn trong thư mục, "để ở ổ D") |
| Tool AddNPC by Chicken | add NPC — **bản free chỉ 10 map** |
| HanoConv 1.0 | dịch chữ Trung Quốc → Hán Việt (dịch được cả đoạn văn) |
| Filemon | cần để **thêm map mới của VNG** |
| Tool view spr | xem file spr |
| Auto Click | cộng tiềm năng (khỏi mỏi tay) |
| Auto Level | "dùng để train hay sao ý" |
| Lấy id skill + đồ by Chicken | view **id đồ** rất nhanh |

## 26. Cài JX server bằng video (`download/Cai JX bang video.html`)

- Video do **Công Quốc** thực hiện, định dạng **`.fbr`** → phải cài **BB FlashBack Pro Player** (chạy
  `BB FlashBack Pro Player.exe` → Open → chọn file `.fbr`) rồi "crack bình thường".
- 6 bước nội dung video: 1) cài MS SQL Server 2000 · 2) cài Language China (PRC) · 3) cài Card mạng ảo ·
  4) **set RAM ảo** · 5) config Server + Client · 6) khởi động Server.
- (Không có link video lẫn link soft thực trong bản bóc text — link nằm trong HTML nhưng trống/đã chết.)

---

## File kèm theo trong ebook (4 file nén — đã giải nén & kiểm tra thật)

Đều nằm trong `~/jx1-knowledge/ebookjx3/html/…` (giải nén bằng `bsdtar` hoặc `7zz`; **`7zz` KHÔNG giải được `file ini.rar`** — dùng `bsdtar`/`unar`):

### 1. `html/caigame/startupAlextuan.rar` — launcher server (bản AlexTuan, 230.772 B)
Chứa: **`vlStartup.exe`** (297.201 B, 2007-05-10) + **`Startupcfg.ini`** (339 B, 2010-08-13).
Dụng ý: dùng cho **bài 9 Cách 2** — bấm 1 nút chạy 5 tiến trình server, ẩn cửa sổ, tắt server. Nội dung ini thật:
```ini
[Path]
Sword3PaySys="E:\SV JX\JxserverPro\Sword3PaySys.exe"
S3RelayServer="E:\SV JX\JxserverPro\S3RelayServer.exe"
Goddess="E:\SV JX\JxserverPro\Goddess.exe"
Bishop="E:\SV JX\JxserverPro\Bishop.exe"
S3Relay="E:\SV JX\JxserverPro\S3Relay.exe"
[LoginInfo]
BishopAcc="txjx"    BishopPass="<PASSWORD>"
S3RelayAcc="sa"     S3RelayPass=""
```
→ Ba giá trị đáng nhớ: **`BishopAcc=txjx` / `BishopPass=<PASSWORD>`**, **`S3RelayAcc=sa`**, S3Relay pass trống;
**`Gameserver.exe` không có trong danh sách** (phải tự chạy).
(Tài liệu không nói rõ) acc/pass của `Goddess` và `Sword3PaySys`; tool viết bằng gì (không có source).

### 2. `html/caigame/StartupPro.rar` — tool config server+client (sangpronhat/SangProNhat, 656.825 B)
Chứa thư mục **`StartupPro/`**: `JxStartup.exe` (539.493 B, 2009-06-08), `StartupCfg.ini` (703 B),
`icon.ico` (293.281 B), `copyright.jpg` (45.718 B).
Dụng ý: **bài 8 Cách 2** — "config bằng tool" (tiếng Việt, bấm **"Lưu thiết lập"**) và có ảnh minh hoạ
`photo/tool/startuppro1.JPG`. Nội dung `StartupCfg.ini` thật:
```ini
[Client]  Pacth =D:\Vo Lam Truyen Ky   IP =10.x.x.x   FullScreen =0
[Bishop]  Account =jx_spn   Password =<PASSWORD>
[S3relay] Account =sa      Password =<PASSWORD>
[Server]  Pacth=C:\GSV\    IP=10.x.x.x   MAC=0200-4C4F-4F50
```
→ Đáng chú ý: tool ghi **IP server + IP client + đường dẫn client/server + MAC**, và có riêng
**Bishop acc `jx_spn`/pass `12345`** (khác `vlStartup` dùng `txjx`/`1111`) ⇒ **acc Bishop là cấu hình trong file của
từng server pack**, không phải hằng số chung. `MAC=0200-4C4F-4F50` (chuỗi byte "LOOP" = card Loopback).

### 3. `html/giaodien/phongthan.zip` — 4 spr thanh máu/mana "phong thần" (5.623 B, 2010-09-02)
Chứa **4 file `.spr` tên GBK** (đã giải mã tên + đọc header thật, tất cả **single-frame** `frameW=frameH=0`):

| File (tên thật) | Bytes | Kích thước | Map vào (theo bài 18) |
|---|---|---|---|
| `血条.spr` (thanh máu) | 2080 | **156 × 8** | `\Spr\Ui4\主界面\血蓝\血条.spr` |
| `蓝条.spr` (thanh mana) | 2080 | **156 × 8** | `\Spr\Ui4\主界面\血蓝\蓝条.spr` |
| `经验.spr` (kinh nghiệm) | 2080 | **156 × 8** | `\Spr\Ui4\主界面\血蓝\经验.spr` |
| `个人状态.spr` (khung trạng thái) | 9675 | **169 × 52** | `\Spr\Ui4\主界面\血蓝\个人状态.spr` |

→ Khớp đúng số trong `顶部控制条.ini`: `[Life_Image]/[Mana_Image]/[Exp_Image] Width=156 Height=8`,
`[Main]` nền 169×52 (chú thích `;Width=169 ;Height=46` trong ini là bị comment — số thật 169×52).
(Tài liệu không nói rõ) file nào là máu / mana — suy ra từ tên GBK + khai báo ini, không phải từ text ebook.

### 4. `html/giaodien/file ini.rar` — ini "thanh điều khiển trên" (670 B, 2010-10-10)
Chứa **`顶部控制条.ini`** (1.756 B) — **thanh điều khiển/trạng thái trên cùng**: tên + cấp + máu + mana + kinh nghiệm,
nền là `个人状态.spr`. Dụng ý: **bài 18**, copy vào `\Ui\Ui3`. Nội dung thật (tóm tắt số quan trọng):
```ini
[Main]  Left=0  Top=20  Moveable=1  Trans=1  Image=\Spr\Ui4\主界面\血蓝\个人状态.spr
        Button0=Name Button1=Level Button2=Life Button3=Mana Button4=Exp
[Name]  25,2  113x14  ClassType=Player_Name   [Name_Text] Font=14 HAlign=1 Color=55,231,63
[Level] 140,0 27x14  ClassType=Player_Level   [Level_Text] Font=14 HAlign=1 Color=55,231,63
[Life]  10,16 156x10 ClassType=Player_Life    [Life_Image] 0,3 156x8 PartType=0 Image=血条.spr
[Mana]  10,28 156x10 ClassType=Player_Mana    [Mana_Image] 0,2 156x8 PartType=0 Image=蓝条.spr
[Exp]   10,39 156x10 ClassType=Player_Exp     [Exp_Image]  0,2 156x8 PartType=0 Image=经验.spr
```
→ **Bổ sung / khác biệt đáng chú ý so với bản `ui/ctc` đang dùng ở server nhà**
(skill `<SSH_ALIAS>-client-modding`): file này là **theme `Ui4`**, tên section giống nhưng **`Mana` cũng `PartType=0`**
(bản CTC dùng `PartType=1` cho mana — "đầy giữ phải"); `[Main]` có `Moveable=1 Trans=1`; `[Exp]` là control
`ClassType=Player_Exp`; `_Text` của Name/Level ghim màu `55,231,63` còn Life/Mana/Exp màu trắng.
→ Nếu định dùng: **KHÔNG copy thẳng vào client theme CTC** — phải map lại `\Spr\Ui4\…` sang `\Spr\Ui3\…` + đổi
`PartType`/dim cho khớp.

---

## Còn dùng được / đã lỗi thời (đối chiếu server JX1 <GAME_HOST_IP> hiện tại)

### ❌ Đã lỗi thời — đừng dùng lại
| Nội dung ebook | Lý do |
|---|---|
| **Card mạng ảo + IP `192.168.x.2`** (bài 4, 8, 21) | Server nhà = WSL2 NAT trên PC <GAME_HOST_IP> (client cùng máy → `127.0.0.1`; máy khác → Windows `portproxy`). Xem `<SSH_ALIAS>-server-ops` + `<SSH_ALIAS>-client-modding`. Loopback IP WAN cũng bỏ. |
| **SQL Server 2000 + import data kiểu 2000** (bài 5, 6) | Server nhà dùng **MySQL :3306**. Bài import gần như chỉ có ảnh, không nói tên DB/file backup → vô dụng. |
| **Font China PRC từ thư mục `I386`** (bài 7) | Thủ tục Windows XP; server nhà chạy Linux, client Windows hiện đại không cần. |
| **Chạy tay 6 `*.exe` / `vlStartup.exe` / `StartupPro`** (bài 9) | Server nhà: `mysqld → goddess_y → bishop_y → s3relay_y → jx_linux_y` (7 systemd service, `<PORTABLE_DIR>/{boot_all,stop_all}.sh`). **Nhưng thứ tự khởi động trong ebook khớp logic** (paysys→relay sv→goddess→bishop→s3relay→game) và **tên/port Bishop khớp**: AccSvr 5002, RoleSvr 55425, client login **5622**, game-svr **5632**; `ServerCfg` Gateway 5632 / Database 55425 / Transfer 5003 / Chat 5004 / Tong 5005 → đúng bộ port 5003/5004/5005 + 5622/5632 đang dùng. |
| **Config IP trong `Bishop.cfg / database.ini / relay_config.ini / ServerCfg.ini` bằng tay** (bài 8) | Vẫn hữu ích làm **bản đồ port** (ở trên), nhưng server nhà đã có `fix_config.sh` — **sửa file không đủ, phải patch script** (xem `<SSH_ALIAS>-server-ops`). Bản 2010 không có `[FixIp]`. |
| **Mở port modem / Virtual server / `canyouseeme.org`** (bài 21) | Mạng hiện tại dùng portproxy + firewall trên host Windows. |
| **Web reg acc + `php.ini` PHP 5.2** (bài 22) | Webpanel hiện tại là python2 `server.py`; bài này không có schema DB, và php.ini 5.2 (`register_long_arrays`, `safe_mode`, `allow_call_time_pass_reference`) đã bị PHP 8 xoá. |
| **Mọi link download** (bài 3, 17–26) | 2010 (zing.vn, MediaFire, MegaShare) — chết. Ebook 1.0/2.0 không kèm trong file này. |
| **Đồng bộ `Skills.txt` → `represent04.dll`** (bài 8, bước 5) | Đặc thù client 2010 (client đọc bảng skill trong DLL). **Chưa verify** với client CTC đang chạy → đọc như giả thuyết, không copy vào DLL trước khi test. |

### ✅ Còn dùng được (cơ chế dữ liệu engine JX1 vẫn vậy)
- **`npcS.txt`: `Treasure`, `ExpParam`, `DropRateFile`** + **file droprate** (`MoneyRate`, `MoneyScale`, `MagicRate`,
  `Count`, `RandRange`, `Genre/Detail/Particular`, `RandRate`, `Min/MaxItemLevel`, `Min/MaxItemLevelScale`) — đây là
  **bài chi tiết nhất trong ebook** và khớp trực tiếp với `settings/npcS.txt` mà skill `jx1-hqvl-knowledge` đã ghi
  ("chỉnh tỉ lệ rơi tiền+đồ qua cột `Treasure`") → dùng bài 14 khi cần chỉnh rơi đồ.
- **`npcS.txt` cột `O..S` (`ArmorType/HelmType/WeaponType/HorseType/RideHorse`)** → làm NPC/nhân vật hoá trang (bài 15).
- **`skills.txt` cột `T` = id missile** và **`missles.txt` dòng `MissleId` tương ứng chứa đường dẫn spr** (bài 11) —
  cùng cơ chế với `MslsGenerate/MisslesForm` trong `<SSH_ALIAS>-skill-data-modding`; bài 11 là hướng dẫn "đổi hình skill"
  nhanh nhất. Cảnh báo **id > 197 phải tạo missile mới** (ebook bó tay).
- **`skills.txt` cột `J` = id skill + `状态图形对照表.txt` dòng cùng id → spr** để ghép vòng sáng (bài 12) —
  khớp với file `状态图形对照表.txt` mà `<SSH_ALIAS>-skill-data-modding` liệt kê (trạng thái aura/buff + spr).
- **4 dòng missles phong thần** (bài 17) — dữ liệu nguyên văn, dùng được nếu cần thêm missile.
- **NpcRes client**: `\Spr\NpcRes\man|woman` + file `男主角躯体.txt / 女主角躯体.txt (+信息)`, `普通npc资源.txt`,
  `人物类型.txt`, `Armorres.txt`, Ldunpack theo list đường dẫn (bài 13) — kiến thức res **không có** trong các skill
  hiện tại ⇒ đây là phần **bổ sung mới**.
- **GUI**: kỹ thuật "thay `顶部控制条.ini` + thay spr thanh máu/mana" (bài 18) vẫn đúng — nhưng **khác theme**
  (Ui4 vs CTC) nên chỉ dùng số/spr làm tham chiếu, xem mục file kèm #4.
- **Xem/unpack spr pak bằng RPGViewer** (bài 10) — trùng với `jx1-hqvl-knowledge` (RPGViewer có sẵn); điểm ebook
  thêm: file export ra `.out` = `.spr`, và số thứ tự file trong pak dùng để chọn.

### Mơ hồ / tài liệu không nói rõ (đừng tin chắc)
- Bài **6 (Import data JX)**: 100% là ảnh, không nêu tên DB, file `.bak/.mdf`, cách attach.
- Bài **4**: hứa "giải thích sau" vì sao IP phải `192.168.x.2` — **không giải thích ở đâu trong ebook**.
- Bài **5**: không nói mixed mode / mật khẩu `sa` (chỉ suy ra "trống" từ `database.ini`).
- Bài **8**: 5 thư mục `000`–`004` trong `Settings/item` — **không nói để làm gì**; "Bước 1/Bước 2" của phần config tay
  trống chữ (chỉ ảnh); cột/dòng nào đổi IP không liệt kê.
- Bài **11**: id missile > 197 → tác giả tự nhận **không biết** cách tạo missile mới.
- Bài **12**: `状态图形对照表.txt` lấy ở đâu (server hay client) không nói; "cột J" không đối chiếu header.
- Bài **13**: ảnh minh hoạ **không bóc ra được** (chỉ 2 gif inline); không nói ý nghĩa cột trong `...信息.txt`.
- Bài **14**: không nói giới hạn trên của `Treasure`; "hơn kém 1" là quan sát; ví dụ "cây đao" không xác định ID.
- Bài **15**: **cột `N` không có tên** (chỉ "cột N"); "đồng bộ Server và Client" không nói file nào.
- Bài **16**: không nêu tên bảng/database (chỉ "Database Account"), chỉ chốt cột `dEndDate`; server nhà dùng MySQL → verify lại.
- Bài **17**: 4 dòng dữ liệu **không nói chèn vào file nào, dòng nào, hay đổi id gì** (suy ra phải là `missles.txt`).
- Bài **18**: không nói spr nào là máu/mana (chỉ 4 đường dẫn trần); không nói theme nào (`Ui3`? `Ui4`?).
- Bài **21**: list port copy theo từng bản server khác nhau; không nói port bắt buộc.
- Bài **22**: không có bất kỳ thông tin DB/PHP file nào dùng được.
- Toàn ebook: **không có** khái niệm MySQL/MariaDB, systemd, Linux server, `<GAME_HOST_IP>`, WSL2, `fix_config.sh`, `[FixIp]`,
  hay client theme `CTC` ⇒ mọi mục liên quan phải lấy từ skill `<SSH_ALIAS>-server-ops` / `<SSH_ALIAS>-client-modding`.

---

## Tra nhanh

| Chủ đề | Bài | File text |
|---|---|---|
| **Ghép skill Kiếm Thế (đổi hình skill)** | 11 | `ebookjx3__html__devjx__ghepskillkiemthe.txt` |
| id missile = cột `T` trong `skills.txt` | 11 | (như trên) |
| Thêm skill mới / 4 skill phong thần (dòng missles + spr + sound) | 17 | `ebookjx3__html__devjx__skill phong than.txt` |
| **Rơi tiền + rơi đồ** (`Treasure`, `ExpParam`, `DropRateFile`, MoneyRate/MoneyScale/MagicRate) | 14 | `ebookjx3__html__devjx__chinhtiletien.txt` |
| ID đồ (`Genre-Detail-Particular`) / độ VIP / yêu cầu đẳng cấp | 14 | (như trên) |
| Vòng sáng quanh nhân vật (`状态图形对照表.txt`, cột `J`) | 12 | `ebookjx3__html__devjx__ghep vong sang.txt` |
| **Mặt nạ / mask NPC** (NpcRes, `男主角躯体.txt`, Armorres.txt, Ldunpack) | 13 | `ebookjx3__html__devjx__matna.txt` |
| NPC mặc đồ từ res nhân vật (cột `O..S` NpcS.txt) | 15 | `ebookjx3__html__devjx__npcturesnhanvat.txt` |
| Hết hạn account / báo "nạp tài khoản" (`dEndDate`) | 16 | `ebookjx3__html__devjx__chinhthoigianaccount.txt` |
| **GUI: thanh máu/mana/exp phong thần** (ini + 4 spr) | 18 (+ file kèm 3,4) | `ebookjx3__html__giaodien__thanh mau mana pt.txt` |
| GUI Kiếm Thế (2 thư mục `UI/SPR`) | 19 | `ebookjx3__html__giaodien__giao dien Kiem The.txt` |
| GUI Võ Lâm 2 (Font / No font) | 20 | `ebookjx3__html__giaodien__giao dien Vo Lam 2.txt` |
| View/unpack spr trong `.pak` (RPGViewer, `.out`→`.spr`) | 10 | `ebookjx3__html__tool__viewspr.txt` |
| Launcher server (chạy 5 exe bằng 1 nút) | 9 + file kèm 1, 2 | `ebookjx3__html__caigame__chayserver.txt` |
| Tool config server+client bằng GUI | 8 + file kèm 2 | `ebookjx3__html__caigame__config ip server va client.txt` |
| **Bản đồ port + tên file config** (Bishop/database/relay_config/ServerCfg) | 8, 9 | như trên |
| Đồng bộ Settings server ↔ client | 8 | (như trên) |
| Danh sách tool JX 2010 (AddNPC, HanoConv, Auto Click…) | 25 | `ebookjx3__html__download__tooljx.txt` |
| Danh sách server pack 2010 (+ pass rar) | 23 | `ebookjx3__html__download__tonghopserver.txt` |
| Cài đặt từ A–Z (SQL 2000, card mạng ảo, font, import DB) | 3–7, 26 | `ebookjx3__html__caigame__*.txt` |
| Đưa server lên online (port, IP WAN, Serverlist SQL) | 21 | `ebookjx3__html__onlsv__huongdanonlsv.txt` |
| Web reg acc | 22 | `ebookjx3__html__onlsv__webjx.txt` |
| Tổng quan VLTK vs JX server lậu | 2 | `ebookjx3__html__gioithieu__game.txt` |
| Nguồn/năm/tác giả ebook | 1 | `ebookjx3__home.txt` |

### Ảnh minh hoạ (index tổng — mở trong `~/jx1-knowledge/ebookjx3/`)
| Bài | Thư mục ảnh | Ghi chú |
|---|---|---|
| 2 Giới thiệu game | `photo/bia.jpg`, `photo/gioithieu1..4.jpg` | |
| 3 Chuẩn bị | `photo/cai jx/data.JPG`, `jx1.jpg`, `jx2a.jpg` | |
| 4 Card mạng ảo | `photo/cai jx/card1..12.JPG` | 12 ảnh |
| 5 SQL 2000 | `photo/cai jx/sql01..20.jpg/JPG` | 20 ảnh |
| 6 Import data | `photo/cai jx/sql20.JPG`, `import1..8.JPG` | 9 ảnh |
| 7 Font China | `photo/cai jx/font1..7.JPG` | 7 ảnh |
| 8 Config IP + đồng bộ | `photo/cai jx/{card12,import1,config2}.JPG`, `photo/tool/startuppro1.JPG` | 4 ảnh |
| 9 Chạy server | `photo/cai jx/chaysv1..7.JPG`, `chaysv6-1.JPG` | 8 ảnh |
| 10 View/unpack spr | `photo/tool/viewspr.png`, `viewspr1.png`, `viewspr2.JPG`, `viewspr3.png`, `viewspr4.JPG` | 5 ảnh |
| 11 Ghép skill KT | `photo/dev/ghep skill.jpg`, `ghep skill (1..4).jpg` | 5 ảnh |
| 12 Vòng sáng | `photo/dev/vongsang.jpg`, `vongsang (1).jpg`, `vongsang (2).jpg` | 3 ảnh |
| 13 Mặt nạ | — | **chỉ 2 gif inline trong CHM, không bóc ra được** |
| 14 Tỉ lệ rơi đồ | — | không có ảnh |
| 15 NPC từ res | `photo/dev/CachLamNPCTuResNhanVat1.jpg`, `..2.jpg` | 2 ảnh |
| 16 Hạn account | `photo/dev/ChinhNgayAccount1..3.jpg` | 3 ảnh |
| 17 Skill phong thần | `photo/dev/skillphongthan.jpg`, `skillphongthan1.jpg` | 2 ảnh |
| 18 Thanh máu/mana PT | `photo/dev/skillphongthan.jpg` | dùng lại ảnh bài 17 |
| 19 GUI Kiếm Thế | `photo/dev/giaodienkt1.JPG`, `giaodienkt2.jpg`, `giaodienkt3.jpg` | 3 ảnh |
| 20 GUI Võ Lâm 2 | `photo/dev/giaodienjx2_1..3.PNG` | 3 ảnh |
| 21 Online | — | không có ảnh |
| 22 Web server | `photo/webdemo.jpg` | 1 ảnh |
| 23–26 Download | — | không có ảnh |

(Tổng 92 file trong `photo/`, gồm `photo/`, `photo/cai jx/`, `photo/dev/`, `photo/tool/` — tên thư mục ảnh có
**khoảng trắng** (`cai jx`), nhớ quote khi mở bằng shell.)
