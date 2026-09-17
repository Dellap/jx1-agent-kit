# Script API & path — chi tiết (nguồn: wiki-beta HQVL)

> ⚠️ **ĐÍNH CHÍNH (17/09/2026):** `StartMissionTimer(84, 155, 18*60)` — **18 frame = 1 GIÂY** ⇒ `18*60` frame = 1 phút.
> Nhóm Tống Kim: `BAOMING_TIME = ThoiGianBaoDanhTK` (3 phút), `FIGHTING_TIME = ThoiGianChienDauTK` (30 phút), `SONGJIN_SIGNUP_FEES = 20000`;
> `BOSS_TIME_MAIN`/`VANISHGAME_TIME_MAIN` **đã bị xoá khỏi `battlehead.lua`**. `settings/item/magicscript.txt` (không phải `settings/magicscript.txt`).
> `tasklist.ini [List] Count = 133` nhưng chỉ có 45 section `[Task_0..44]` ⇒ **Count không phải số task**.

## A. Khai báo map + NPC cho tính năng mới (ví dụ thật: Tần Lăng Bí Bảo)

1. **maplist.ini** — `/home/jxser/server1/settings/relaysetting/maplist.ini`: thêm block map mới, sửa ID map
   trùng khớp map liền kề, rồi **đồng bộ file sang client**.
2. **worldset.txt** — `/home/jxser/gateway/s3relay/setting/worldset.txt`: thêm dòng map, ID phải khớp maplist.
3. **NPC (4 file, phải đồng bộ cả 4 sang client)**:
   - `server1/settings/npcs.txt`
   - `server1/settings/npcres/ÈËÎïÀàÐÍ.txt` (人物类型)
   - `server1/settings/npcres/ÆÕÍ¨npc×ÊÔ´.txt` (普通npc资源)
   - `server1/settings/npcres/ÆÕÍ¨npc×ÊÔ´ÐÅÏ¢.txt` (普通npc资源信息)
   - ⚠️ **ID boss = số thứ tự dòng trong `npcs.txt` − 2**. Ví dụ dòng 2061 → ID NPC 2059.
4. **Task gateway**: `gateway/s3relay/relaysetting/task/tasklist.ini` thêm `[Task_NN]` + `TaskFile=tanlang\tg_tanlang.lua`.
5. **Lối vào (Lua)**: trong `server1/script/global/autoexec.lua`, trên `function main` thêm
   `Include("\\script\\global\\...\\fun_xxx_main.lua")`, dưới `function main` gọi `add_loivao...()`.
6. **Config riêng** trong `fun_xxx_config.lua` (bật/tắt, EXP, drop table, ID map, ID boss) và `fun_loivao.lua`
   (`entercave()` chứa ID map).
7. **Giờ mở sự kiện**: trong `gateway/s3relay/relaysetting/task/<...>/tg_xxx.lua` → `TaskTime(20, 30);`

## B. Mission API (bài "Các bước cơ bản tạo nhiệm vụ")

`OpenMission(id)` — id khai trong `server1/settings/task/missions.txt`; theo id sẽ gọi `InitMission()`
trong thư mục tương ứng. Hai `CloseMission` được gọi trong `EndMission()`.

Mission gắn theo **index của map**:

```lua
warmap  = SubWorldID2Idx(idMap)  -- lấy index map trong gameserver
SubWorld = warmap                -- trỏ index map để thao tác
OpenMission(84)
```

Đếm / trạng thái (giống `SetTask` nhưng cho index map):

```lua
SetMissionV(taskid, 0)                      -- set biến nhiệm vụ map (vd đếm số quái hạ gục)
StartMissionTimer(84, 155, 18*60)           -- id mission, id timer, timer (18 frame = 1 phút)
StopMissionTimer(idMission, idTimer)
```

`task-id` khai trong `server1/settings/timertask.txt`. Khi hết timer, theo id timer game gọi `OnTimer()` trong
file tương ứng (dùng để đếm timer tính năng hoặc kết thúc).

Phe/team trong mission:

```lua
AddMSPlayer(84, 1)   -- tống
AddMSPlayer(84, 2)   -- kim
```

Player out game / rời map → game gọi `OnLeave(RoleIndex)` trong file khai báo id mission (truy xuất
indexPlayer để thao tác lên toàn bộ người chơi của mission đó). Ví dụ thưởng toàn bộ player rồi đưa ra ngoài
khi hết giờ: `GetNextPlayer(84, idx, idTeam)`.

```lua
SetDeathScript("\\script\\game\\playerdeath.lua")   -- khi NPC bị hạ gục -> gọi OnDeath(nNpcIndex)
```

## C. Phân trang hộp thoại (CreateNewSayEx tối đa 16 dòng)

```lua
function PhanTrang(table, nOfPage)
    local tbSplitTable = { nil }
    local nCount = getn(table)
    if nCount > nOfPage then
        local nIndex = floor(nCount / nOfPage)
        for id = 0, nIndex - 1 do
            local tbTemp = {}
            for n = id * nOfPage + 1, id * nOfPage + nOfPage do
                tinsert(tbTemp, table[n])
            end
            tinsert(tbSplitTable, tbTemp)
        end
        local nMod = mod(nCount, nOfPage)
        if nMod > 0 then
            local tbTemp = {}
            for i = nCount - nMod + 1, nCount do tinsert(tbTemp, table[i]) end
            tinsert(tbSplitTable, tbTemp)
        end
    else
        tbSplitTable = table
    end
    return tbSplitTable
end

function Boss_HK(nPage)
    local tbBossHK = PhanTrang(tbBoss, 10)
    local tbOpt = {}
    if not nPage then nPage = 1 end
    local nCount = getn(tbBossHK)
    if nPage < nCount then
        for i = 1, 10 do
            tinsert(tbOpt, { tbBossHK[nPage][i].szName, Call_Boss, { tbBossHK[nPage], i } })
        end
        tinsert(tbOpt, { "Trang sau", Boss_HK, { nPage + 1 } })
    else
        for i = 1, getn(tbBossHK[nCount]) do
            tinsert(tbOpt, { tbBossHK[nCount][i].szName, Call_Boss, { tbBossHK[nCount], i } })
        end
    end
    if nPage > 1 then tinsert(tbOpt, { "Trang trước", Boss_HK, { nPage - 1 } }) end
    tinsert(tbOpt, { "Kết thúc đối thoại" })
    CreateNewSayEx("Chọn Boss muốn gọi", tbOpt)
end
```

Gọi boss kèm thông báo toàn server (mẫu thật):

```lua
local clBoss = AddNpcEx(Boss.nBossId, Boss.nLevel, Boss.nSeries, SubWorldID2Idx(nw), nx*32, ny*32, 1, Boss.szName, 1)
SetNpcDeathScript(clBoss, "\\script\\missions\\boss\\bosstieu.lua")
SetNpcParam(clBoss, 1, Boss.nBossId)
SetNpcTimer(clBoss, 120 * 60 * 18)
local handle = OB_Create(); ObjBuffer:PushObject(handle, str)
RemoteExecute("\\script\\event\\msg2allworld.lua", "broadcast", handle); OB_Release(handle)
```

## D. Sự kiện định kỳ — mở lại (2 ví dụ thật)

**Ông Ba Mươi** (`springfestival_2006.lua`):
1. `gateway/s3relay/relaysetting/task/springfestival_2006.lua` → `DATEBEGIN`/`DATEEND`.
2. `tasklist.ini` → thêm `[Task_NN] TaskFile=springfestival_2006.lua` + tăng `[List] Count`.
3. `server1/script/missions/springfestival/head.lua` → `CO_DATE_BEGIN`/`CO_DATE_END` khớp ở trên.
Hardcode giờ chạy trong game: 12h–14h, 19h–23h, 1h–3h.

**Đấu Ngũ Linh Thú** (`shengdan0811.lua`):
1. `relaysetting/task/shengdan0811.lua` → comment `if nDate < 090116 or nDate > 090215 then return end`
   (hoặc sửa ngày).
2. `tasklist.ini` → `[Task_NN] TaskFile=shengdan0811.lua` + `Count`.
3. Boss ra 20h00, hoạt động 19h50. Thưởng rơi: `server1/script/event/shengdan_jieri/200811/newboss/bossdeath.lua`
   hoặc tạo file droprate gắn id NPC boss.

## E. Tống Kim (`server1/script/battles/battlehead.lua`)

```lua
FRAME2TIME = 18;              -- 18 frame = 1 giây
BAOMING_TIME = 10             -- 10 phút đăng ký
FIGHTING_TIME = 60            -- 60 phút trận đấu
ANNOUNCE_TIME = 20            -- 20 giây công bố
BOSS_TIME_MAIN = 30           -- 30 phút sau báo danh xuất hiện nguyên soái
VANISHGAME_TIME_MAIN = 20     -- 20 phút cuối xuất hiện nguyên soái tiếp theo
TIMER_1 = ANNOUNCE_TIME * FRAME2TIME
TIMER_2 = (FIGHTING_TIME + BAOMING_TIME) * 60 * FRAME2TIME
RUNGAME_TIME = BAOMING_TIME * 60 * FRAME2TIME / TIMER_1
GO_TIME      = BAOMING_TIME * 60 * FRAME2TIME / TIMER_1
SONGJIN_SIGNUP_FEES = 10000
JUNGONGPAI = 1773             -- item 6,1,1477 (Sung Kim quân công bài)
EXPIRED_TIME = 24*60
JUNGONGPAI_Task_ID = 1830
TIME_GAME_LIMIT = 5 * 60      -- ở trại quá lâu -> out ra NPC báo danh
BONUS_KILLPLAYER = 75; BONUS_SNAPFLAG = 600; BONUS_KILLNPC = 1
BONUS_KILLRANK1..7 = 5,30,150,250,500,1000,500
BONUS_MAXSERIESKILL = 150; BONUS_GETITEM = 25; BONUS_1VS1 = 400
```

Bonus đọc qua `Lua_GetTypeBonus` (dùng cho patch 1-phe-vẫn-có-điểm ở server 6.0).

## F. Sự kiện / hoạt động ngắn khác

- **Thêm giờ Tống Kim theo ý**: script 2.85KB (Julian Vương) — sửa giờ mở chiến trường.
- **Lệnh bài làm nhiệm vụ Hoàng Kim**: tạo item trong `magicscript.txt` trỏ tới file script, hoặc add hàm
  `help_questhoangkim()` vào lệnh bài GM / thần hành phù.
- **Hoán đổi trang bị giữ nguyên thuộc tính** (reroll gacha): sửa ID item theo server; nguồn 5.54KB.
- **SimCity / Kéo Xe NPC** (`jx1-scripts/0001_simcity`): copy thư mục `script/` vào server, sửa
  `script/global/autoexec.lua`:
  ```lua
  Include("\\script\\global\\vinh\\main.lua")
  function main()
      add_npc_vinh()
  ```
  NPC ở gần hiệu thuốc Tương Dương (Triệu Mẫn = simcity, Vô Kỵ = kéo xe). Thêm NPC theo code:
  `KeoXeNpcManager:start()` + `KeoXeNpcManager:TaoNpc(ID hình, Tên, { is_boss=1, no_revive=1, canFight=1, series=5 })`.
  Config: `script/global/vinh/simcity/config.lua`, `keoxe/danhsach_xe.lua`. SimCity đã lên 5.2 (116 map, tự
  load NPC, plugin hoá); bản 3.0 có Tống Kim + bảng xếp hạng.
  Log toạ độ di chuyển (dùng khi vẽ đường đi NPC):
  ```lua
  function main()
      local nW, nX, nY = GetWorldPos()
      local file = openfile("./script/toadodichuyen.log", "a+")
      write(file, nW.." "..nX.." "..nY.."\n"); closefile(file); Msg2Player(nW.." "..nX.." "..nY)
      return 1
  end
  ```
