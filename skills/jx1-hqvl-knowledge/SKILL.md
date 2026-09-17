---
name: jx1-hqvl-knowledge
description: Use khi tra kiến thức JX1/VLTK từ kho HQVL (jxoffline).
version: 1.0.0
author: Hermes Agent (mirror từ github.com/jxoffline / Hội Quán Võ Lâm)
license: MIT
metadata:
  hermes:
    tags: [game-development, jx1, vltk, hqvl, lua, reverse-engineering]
    related_skills: [vltk-server-ops, vltk-client-modding, jx1-client-ui-modding, vltk-skill-data-modding]
---

# Kho tri thức JX1/VLTK — Hội Quán Võ Lâm (github.com/jxoffline)

## When to Use

- Cần tra kỹ thuật JX1/VLTK ngoài phạm vi server nhà: cài bản 6.0/8.0/JXWin, script sự kiện, mission,
  shop (`goods/buysell`), Tống Kim, auto/RE, inject DLL, build JXWin 64-bit, tool pack/unpack, SPR, autoupdate.
- bạn nhắc link `github.com/jxoffline` / "Hội quán võ lâm" / HQVL / jxtools / wiki-beta.
- Không dùng cho vận hành server <SERVER_NAME> đang chạy → skill `vltk-server-ops` / `vltk-client-modding`.

Cộng đồng **HQVL** (fb.com/groups/volamquan, discord.gg/gBrZsTwauH, jx1offline@gmail.com).
`github.com/jxoffline` là **user account** (không phải org → `/orgs/` API trả 404, dùng `/users/`).
4 repo, tải bằng `git clone --depth 1` (curl api.github.com OK, không cần browser):

| Repo | Nội dung | Local mirror |
|---|---|---|
| `wiki-beta` | 48 bài kỹ thuật (JX6/JX8/JXWin/JXLinux + tools) HTML tiếng Việt | `~/jx1-knowledge/wiki-beta` |
| `jxtools` | 3 webtool: ShopBuilder, OnlineGMPassTool, TCVN3Converter | `~/jx1-knowledge/jxtools` |
| `jx1-scripts` | Script Lua thật: SimCity, Tần Lăng Bí Bảo, jxwin-variations | `~/jx1-knowledge/jx1-scripts` |
| `tutorials` | Series AutoJx (auto + inject DLL) kèm source C++/C# | `~/jx1-knowledge/tutorials` |

Bản text đã bóc sạch HTML: `~/jx1-knowledge/text/*.txt` (tên file = path gốc, `/`→`__`).
Tra cứu: `search_files pattern="..." path=~/jx1-knowledge/text`. Refresh: `git -C ~/jx1-knowledge/<repo> pull`.
**Index đầy đủ 66 tài liệu: `references/doc-index.md`.**

**Nguồn thêm — Ebook JX 3.0 của jxvietnam (CHM, bạn gửi 17/09/2026)**: bung bằng
`7zz x -o/tmp/ebookjx "<file>.chm"` (7-Zip có sẵn ở `/opt/homebrew/bin/7zz`; macOS KHÔNG có
`extract_chmLib`/`archmage`) → 26 trang HTML + 86 ảnh + 4 file kèm. Bóc text:
`~/.hermes/scripts/ebookjx_extract.py` → **`~/jx1-knowledge/text/ebookjx3__*.txt`** (~11k từ),
bản đầy đủ (ảnh + tool) ở `~/jx1-knowledge/ebookjx3/`.
**Ghi chú chưng cất cả 26 bài (số cụ thể: cột `Treasure`/`ExpParam`/`DropRateFile`, công thức droprate, cột `T`/`J`
skills.txt, NpcRes/mặt nạ, 4 spr thanh máu PT 156x8, ini `顶部控制条.ini` theme Ui4, ảnh từng bài, mục "còn dùng
được/lỗi thời" + bảng tra nhanh): `references/ebookjx3-notes.md`.**
Mục lục: cài game (card mạng ảo, SQL 2000, import DB, font TQ, config IP, chạy server) · tool (view/extract spr) ·
dev (ghép skill Kiếm Thế, ghép vòng sáng, mặt nạ, chỉnh tỉ lệ rơi tiền+đồ qua cột `Treasure` trong `settings/npcS.txt`,
NPC từ res nhân vật, chỉnh hạn acc, skill phong thần/VIP) · giao diện (thanh máu+mana phong thần, GUI Kiếm Thế/Võ Lâm 2) ·
online server (hướng dẫn + web) · download (server/tool/ebook/video).
Kèm theo: launcher `vlStartup.exe`+`Startupcfg.ini`, `StartupPro/JxStartup.exe`+`StartupCfg.ini`,
spr thanh máu phong thần (`phongthan.zip`), `顶部控制条.ini` (thanh điều khiển trên).
Bài viết ~2010 nên phần **cài đặt cũ** (SQL 2000/card mạng ảo) không áp cho server nhà (AlmaLinux/<GAME_HOST_IP>);
phần **dev client (SPR, skills.txt, npcS.txt, GUI)** vẫn dùng được.

## 1. Script server-side (JX Linux 6.0/8.0) — đường dẫn chuẩn

```
/home/jxser/server1/settings/task/missions.txt        # khai báo id mission
/home/jxser/server1/settings/timertask.txt            # task-id cho timer
/home/jxser/server1/settings/npcs.txt + npcres/*.txt  # NPC (tên file GBK)
/home/jxser/server1/settings/{goods,buysell,magicscript}.txt
/home/jxser/server1/settings/relaysetting/maplist.ini
/home/jxser/server1/script/global/autoexec.lua        # Include(...) + main()
/home/jxser/server1/script/battles/battlehead.lua     # thông số Tống Kim
/home/jxser/server1/script/missions/...               # InitMission/EndMission/OnTimer/OnLeave/OnDeath
/home/jxser/gateway/s3relay/setting/worldset.txt
/home/jxser/gateway/s3relay/relaysetting/task/tasklist.ini + task/*.lua   # sự kiện
```

**Mission API** (chi tiết: `references/script-api.md`):
`OpenMission(id)` / `CloseMission(id)` (Close gọi trong `EndMission`), `SubWorldID2Idx(idMap)` → index map,
`SubWorld = warmap`, `SetMissionV(taskId, 0)`, `StartMissionTimer(idMission, idTimer, 18*60)` (18 frame = 1s),
`StopMissionTimer`, `AddMSPlayer(84, 1)` (team 1 = Tống, 2 = Kim), `GetNextPlayer(84, idx, team)`,
`SetDeathScript("\\script\\game\\playerdeath.lua")` → `OnDeath(nNpcIndex)`.

**Mở lại sự kiện cũ** (Ông Ba Mươi, Đấu Ngũ Linh Thú): sửa date trong `relaysetting/task/<event>.lua`
(hoặc comment `if nDate < ... return end`) + thêm `[Task_NN] TaskFile=...` vào `tasklist.ini` **và** tăng
`[List] Count` lên 1. Sự kiện trong `server1/script/missions/.../head.lua` có `CO_DATE_BEGIN/CO_DATE_END` phải khớp.
Thời gian chạy: `TaskTime(hh, mm)`.

**Shop**: sửa `goods.txt` (giá) + `buysell.txt` (cửa hàng) → chép đè **3 chỗ**: `server1/settings`,
`gateway/s3relay/relaysetting/syncfiles/settings`, và `settings` trong client → mở bằng `Sale(ID, kiểu)`;
v6: 0 tiền vạn / 1 phúc duyên / 2 danh vọng / 3 tích luỹ TK / 4 vinh dự. **Xoá cửa hàng/vật phẩm = lệch ID**
→ mọi script dùng ID sau đó sai.

**Tống Kim** (`battlehead.lua`): `FRAME2TIME=18` (18 frame = 1s), `BAOMING_TIME=10` (phút đăng ký),
`FIGHTING_TIME=60`, `BOSS_TIME_MAIN=30`, `SONGJIN_SIGNUP_FEES`, `JUNGONGPAI=1773` (item công trạng),
`BONUS_*` (điểm theo rank NPC, `BONUS_1VS1=400`). Muốn **đánh 1 phe vẫn có điểm** → patch server 6.0
(jx_linux_y): hex `76 20 D9 EE...` → `EB 20 D9 EE...`, hoặc IDA: hàm `Lua_GetTypeBonus`, đổi `jbe`→`jmp`.
Bản 8.0 mã hoá nên không áp dụng được.

**Lua conventions**: file mã hoá **iso-8859-1 (TCVN3)**, không phải UTF-8 — dev nên set VSCode
`"files.encoding": "iso88591"`; lib `script/lib/comon.lua` có `unpack`, `iff` (ternary), `tonum`,
`strfill_left/right/center`. Dialog `CreateNewSayEx` **tối đa 16 dòng** → cần phân trang khi >15 lựa chọn
(hàm `PhanTrang` hoàn chỉnh trong `references/script-api.md`).

## 2. Client / tools / UI

- **PAK**: RPGViewer (unpack mọi thứ nhưng mất tên), LDunpack (theo list tên), JxUnpack (hiểu tên tiếng Hoa,
  file >800KB ra NULL → so lại bằng RPGViewer cho bản chuẩn). Trùng path trong nhiều pak → **lấy file ở pak
  ĐẦU TIÊN** tìm được. Loose file override pak (không cần repack).
- **SPR**: `sprtool eng` (bung TGA từ SPR), **Mpc Asf viewer** (xem SPR/MPC/ASF/RPC — chỉ preview, không lưu
  frame); thiếu DLL thì bỏ `libwinpthread-1.dll` cạnh file chạy.
- **Webtool online** (GitHub Pages): shopbuilder.d (shop), onlineGMPassTool.d (mã hoá/giải mã mật khẩu JX +
  MD5), onlineTCVN3Converter.d (UTF8↔TCVN3). Source: NodeJS + jQuery + Bootstrap, `npm run build`.
- **Autoupdate**: app C++ (set 16-bit, thêm exclusion AV, tạo shortcut) + MD5Generator; source dùng Qt 5.7.1 x86.
- **Miniskill** (icon skill nhỏ dưới thanh máu) và **scale cửa sổ lên 1920x1080** (không dùng Alt+Enter) có bản
  share sẵn — xem `references/doc-index.md`.
- UI/SPR client <GAME_HOST_IP> hiện tại: dùng skill `vltk-client-modding` / `jx1-client-ui-modding`.

## 3. Auto & Reverse Engineering (client)

- Auto = gọi script có sẵn qua **hàm thực thi script thanh chat**. JX6: địa chỉ **0x140C0**.
  Lệnh dùng được: `/Chat('CH_NEARBY'|'CH_CITY'|'CH_WORLD'|'CH_TONG', 'msg')`,
  `Switch([[horse]])`, `Switch([[pk]],0..2)`, `Switch([[run]])`.
- **Địa chỉ biến** (static → xanh lá, không đổi) vs **động** (pointer scan / offsets) vs **địa chỉ hàm**
  (phải dịch ngược mã máy). JXLinux: client không build lại → địa chỉ & offset **cố định**; JXWin: build mỗi
  lần mỗi khác → **phải dùng pattern/signature** (vd thư viện Sig của HoShiMin), không hardcode.
  Công cụ: Cheat Engine, Process Hacker/Explorer, OllyDbg, IDA Free.
- **Inject DLL** (2 hướng, xem `references/auto-re-client.md`):
  - **ASM/hex patch** vào `Game.exe`: exe đổi ít, vào game trực tiếp, **không mã hoá được DLL** → hợp miniskill/anti-dump.
  - **C#/C++ (6 dòng)**: exe nguyên bản, mã hoá/hide DLL, nhưng cần launcher trung gian (kiểu JX8) → hợp auto.
- **JX80 binary variants**: `game_y.exe` bản jx80 HQVL đã hook sẵn VAuto (auto khác phải bật VAuto mới chạy)
  → có bản **VAuto Dehook** (chưa hook, tự do phát triển) và bản **Stand-alone** (client gốc KS, không hiện
  cửa sổ Command Prompt, cần patch để dùng auto).
- **JXWin source**: source Tinh Vân dị bản Trần Minh (~15GB, 10 part, **VS 6.0**); biến thể
  `duccom0123/jx1-vs2022` (giao diện Công Thành Chiến). **Build GS 64-bit**: cần `common.lib`, `heaven.dll`,
  `rainbow.dll`, `CoreServer.dll`, `Engine.dll` đều 64-bit; gateway/goddess/s3relay/paysys **giữ 32-bit**;
  chuyển con trỏ `unsigned int` → 64-bit; lợi: 1 GS chứa ~800 map ~10GB thay vì 7×1.7GB, config đơn giản hơn.

## 4. Cài đặt / vận hành

- **JXLinux 8.1.11 HQVL**: lấy `data` + `music` từ client VNG (volam.zing.vn) → thêm PatchClient 8.1.11 + server
  máy ảo (VMware WinXP + CentOS). Tối thiểu 8GB RAM/20GB đĩa (mượt: 16GB/40GB), VMware 15+,
  VC++ 2005 Redistributable x86.
- **Tắt coredump** CentOS JX Linux: `* hard core 0` trong `/etc/security/limits.conf`,
  `fs.suid_dumpable = 0` trong `/etc/sysctl.conf` (+ `sysctl -p`), `ulimit -S -c 0` trong `/etc/profile`.
- **Web admin "bili"** (quản lý tài nguyên) chạy XAMPP 1.7.1/PHP 5.2 + cURL — **bảo mật rất kém**
  (từng bị chiếm quyền admin); nếu dùng phải nâng PHP 8.2 + PDO.
- **AutoIt autoplay**: bộ video Lưu Bị 1.7GB — part 1 tìm thông số nhân vật/hàm trong game (HP, mana, toạ độ,
  click NPC, hook hàm), part 2 nâng cao (đọc static, Cheat Engine inject DLL, inject assembly C++, Arduino).

## Pitfalls

- Script nạp RAM lúc start → đè file phải **restart server** mới có hiệu lực; backup trước, verify md5 sau.
- **Không dùng file đã hex/patch của người khác** (rủi ro mã độc) — tự patch theo hex/IDA.
- Sự kiện: quên tăng `[List] Count` trong `tasklist.ini` = task không chạy; sai ngày ở `head.lua` = vào không thấy gì.
- Lua: đếm `{`/`}` cân bằng; tên thuộc tính phải khớp 3 lớp (chi tiết skill `vltk-skill-data-modding`).
- Tài liệu HQVL chỉ để **nghiên cứu/phi thương mại** (DISCLAIMER của họ nói rõ); nhiều link Google Drive/Facebook
  trong bài có thể đã chết.
