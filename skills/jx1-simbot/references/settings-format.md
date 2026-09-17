# Settings SimBot — định dạng & cách thêm dữ liệu

Gốc: `server1/settings/global/vdk/simcity/` (đọc bằng `SimCityTableFromFile(path, pattern)`; TSV, `.txt`, CRLF,
chữ có dấu lưu kiểu **TCVN3/iso-8859-1**).

## 1. `maps/thanhthi.txt` — map nào cho bot đi lại (276 dòng)

```
WorldID<TAB>WorldName<TAB>PathFile<TAB>Type
1	Phượng Tường	thanhthi\1_phuongtuong_nodes.txt	nodes
1	Phượng Tường	thanhthi\1_phuongtuong_preset.txt	preset
```
Mỗi map 2 dòng: 1 `nodes` (đồ thị đường đi) + 1 `preset` (các tuyến đặt tên).

## 2. `<id>_<ten>_nodes.txt` — đồ thị node

```
node_name	linked_nodes	is_exact	type
1800_3425	1595_3213,1787_3412,1791_3416,1800_3425	0	0
```
- `node_name` = `x_y` (toạ độ ô, không phải pixel — code nhân `*32`).
- `linked_nodes` = các node kề (danh sách phẩy), tự tham chiếu chính nó.
- 77 file nodes, vd `78_tuongduong_nodes.txt` (414 dòng) = Tương Dương.

## 3. `<id>_<ten>_preset.txt` — tuyến đường có tên

```
PathName	node_name
tuongduong_DHT	1800_3425
tuongduong_DHT	1787_3412
```
`walkMode = "preset"` → bot đi lần lượt các node của path (đảo chiều khi hết đường — xem `sim.movement.lua`).

## 4. `chat.txt` — kho câu nói (2745 dòng)

```
Type	Chat
fighting	Ngon nhào vô!
```
`Type` khớp: `fighting`, cộng các category trả lời player `rep_chung`, `rep_ok`, `rep_no`, `rep_chao`,
`rep_giaodich`, `rep_boss` (+ `rep_chui` cho taunt). Thêm câu = thêm dòng, không cần build gì.

## 5. `names.txt` (738) / `pname.lua` — tên nhân vật

`names.txt`: cột `Name` + tên VN hoá (Thiềm Yên, Lãnh Hồ Chi, …). `plugins/pname.lua` giữ bảng tên gốc
(Ngôy Diên, Phạm Trường Long, Lục Văn Long… để tạo cảm giác "nhân sĩ võ lâm").

## 6. `npcid2faction.txt` (85 dòng) — map NPC → phái

```
npcId	phai	series	genere
1199	caibang	3	0
```
`genere` = 1/2 → bot dùng bộ hình "gen" (`nSettingsIdx = -1/-2`). Thiếu dòng = bot tự random phái.

## 7. `skills.txt` (40 dòng) — skill bot dùng

```
phai	skillId	ten	chucnang	maxLevel	noCast	castBasic	cost
caibang	130	Tây Điệp Cuồng Vũ	Hỗ trợ phòng ngự - chờ đứng	30	0	1	50000
```
`noCast` = buff không cần đọc (dùng liên tục), `castBasic` = skill đánh thường. Trong code:
`SimCityPhai[phai].noCast / .normalCast / .needCast / .knownIds`.

## 8. `pets.txt` (67 dòng) — vật nuôi bán cho player

```
npcIdx	category	npcName	cost
13	Văn lang hùng tộc	Voi Châu Á	200000
```
`category` = nhóm hiện trong menu; `npcIdx` = ID NPC mẫu làm vật nuôi.

## 9. Thêm một map mới cho bot (checklist)

1. Tạo `maps/thanhthi/<id>_<ten>_nodes.txt` (đồ thị node quanh khu vực cho bot đi).
2. Tạo `maps/thanhthi/<id>_<ten>_preset.txt` (tuyến đi đặt tên).
3. Khai 2 dòng vào `maps/thanhthi.txt` (đúng `WorldID` thật của map).
4. (Tuỳ chọn) stall/dạ tầu: cần node có `isNearAtraction > 0` (trung tâm thành) — `libs/data.lua` tự gom;
   Dạ Tầu tự tính `daTauNodes` (node quanh Dạ Tầu <10 ô) — muốn bot bán quanh Dạ Tầu phải có điểm "Dạ Tầu".
5. Thêm câu chat nếu muốn (`chat.txt`).
6. Restart `jx_linux_y` (script nạp RAM lúc start) rồi vào map kiểm tra.

## 10. Lệnh GM liên quan

- Menu SimCity: NPC **Triệu Mẫn** (7 thành) → `SimCityThanhThi:mainMenu()`; **Vô Kỵ** (Tương Dương) → kéo xe;
  menu tổng trong `nobitaxd/npc/npcthunghiem.lua` (`goisimcity()` → "Gọi SimCity Thành Thị", "Gọi SimCity Kéo Xe").
- Debug Thất Thành Đại Chiến: `/Lua SimTDC_InspectBots()`, `/Lua SimTDC_InspectBots(926)`,
  `...Status()`, `...FixAll()` (các hàm nằm cuối `simsevencity.lua`).
