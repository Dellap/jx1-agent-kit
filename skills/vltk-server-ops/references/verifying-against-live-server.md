# Kiểm chứng tài liệu ↔ server đang chạy (read-only audit)

Dùng khi cần xác minh ghi chú/tài liệu về server VLTK/JX1 còn đúng hay đã cũ
(số dòng, đường dẫn, tên hàm, định dạng cột, giá trị config).
**Quy tắc sắt: CHỈ ĐỌC** — không sửa file, không restart, không ghi gì lên server.
`pkill jx_linux_y` + `boot_all.sh` chỉ được *hiểu*, không được *làm* trong lúc audit.

## 1. Quy trình

```bash
# 1 lệnh duy nhất lấy mirror read-only rồi scp về local để phân tích
ssh <SSH_ALIAS2> 'bash -lc "cd /home/jxser && tar czf /tmp/mir.tgz \
  server1/script/global/nobitaxd/vdk/simcity server1/settings/global/vdk \
  server1/script/battles/marshal/simtk.lua server1/script/missions/sevencity/"'
mkdir -p ~/jx1-verify && cd ~/jx1-verify && scp jx1:/tmp/mir.tgz . \
  && rm -rf src && mkdir src && tar xzf mir.tgz -C src
```

Rồi nạp toàn bộ `.lua` vào 1 dict Python bằng **latin-1** và grep/đếm tại chỗ
(nhanh, không vướng quote, không tốn round-trip ssh):

```python
import os
corpus = {}
for dp,_,fs in os.walk(root):
    for f in fs:
        p = os.path.join(dp,f)
        corpus[p] = open(p,'rb').read().decode('latin-1')   # 1 byte = 1 ký tự, không lỗi decode
# bỏ file *_goc / *.bak* khi ĐẾM, nếu không sẽ nhân đôi số liệu
print(sum(t.count("TenHam(") for t in corpus.values()))
```

So bản gốc ↔ bản đang chạy: `diff <file>_goc <file>` — nhưng **liệt kê backup trước**:
server còn backup theo timestamp ngoài `_goc` (`ls */**/*.bak* *.bak*`;
đã thấy `config.lua.bak_price`, `config.lua.<SMB_USER>.<ts>.bak`, `sim.core.lua.bak_<ts>`).

## 2. Bẫy (đã trả giá 17/09/2026)

- **⛔ Đừng tin số dòng đếm từ mirror.** Python `len(text.split('\n'))` trên bản tar cho
  `simsevencity.lua = 3588`, nhưng `wc -l` **trên server** = 3587 (chệch 1 do newline cuối).
  Suýt báo sai một số liệu ĐÚNG của tài liệu. → **luôn `wc -l` trên server**
  (`ssh <SSH_ALIAS2> 'bash -lc "wc -l < \$F"'`) trước khi kết luận "tài liệu sai".
- **⛔ Đừng nhồi vòng lặp bash có biến vào trong `ssh <SSH_ALIAS2> 'bash -lc "..."'`.**
  Quote lồng nhau vỡ: `bash: -c: line 0: unexpected EOF while looking for matching \`"'`.
  Cách đúng: 1 lệnh ssh đơn giản (tar / wc / ls), hoặc `ssh <SSH_ALIAS2> 'bash -s' < script.sh`,
  còn phân tích để Python làm ở local.
- **Mã hoá**: `.lua` + settings của server này là **TCVN3 / iso-8859-1** → đọc `latin-1` là ra
  code ASCII dùng được ngay; chữ có dấu hiện mojibake, dùng `iconv -f GBK -t UTF-8` khi cần
  đọc tiếng Trung. Bảng TCVN3 rất dễ đọc nhầm: `chñ ®éng` = "chủ động" (KHÔNG phải "chờ đứng"),
  `Hç trî phßng ngù` = "Hỗ trợ phòng ngự", `V¨n lang hïng téc` = "Văn lang hùng tộc".
- **`vdk.so` là binary native, KHÔNG nằm trong mirror.** Chỉ xác minh được *code Lua có gọi tên
  hàm đó với tham số nào*, KHÔNG xác minh được engine thực thi ra sao → phải ghi rõ trong báo cáo,
  không suy đoán ngữ nghĩa native.
- Hàm engine hay ở dạng **guarded call** (`if Fn then Fn(...) end`) ⇒ 0 hit chỉ chứng minh
  *Lua không gọi*, KHÔNG chứng minh *engine không có*; và ngược lại, grep phải bắt cả chỗ khai báo.
- Comment trong code là bằng chứng loại 1: "`SetNpcPos` không tồn tại trên JX1" được xác nhận
  chính bằng 2 comment trong `simsevencity.lua`, không phải bằng suy luận.

## 3. Quy tắc bằng chứng cho báo cáo

Mỗi phát hiện: **(file, dòng) → đúng / cũ-sai / thiếu → lệnh + trích output THẬT → đề xuất sửa ngắn.**
Không suy đoán. Chỗ không kiểm được thì ghi thẳng "không kiểm được + lý do".

## 4. Mốc số liệu đã xác minh 17/09/2026 (so sánh nhanh, khỏi audit lại)

| Hạng mục | Giá trị thật trên server |
|---|---|
| `settings/global/vdk/simcity/maps/thanhthi.txt` | 276 dòng (275 dữ liệu: 149 `nodes` + 126 `preset`), 3 dòng khai trùng |
| `maps/thanhthi/*_nodes.txt` / `*_preset.txt` | **148** / **123** file |
| `chat.txt` | 2745 dòng, **20 giá trị Type** (lớn nhất `general`=1690, rồi `fighting`=928) |
| `names.txt` / `npcid2faction.txt` / `skills.txt` / `pets.txt` | 738 / 85 / 40 / 67 |
| `simsevencity.lua` | 3587 dòng |
| `sim.core.lua` `_goc` ↔ hiện tại | 1015 → 1032 dòng (**+17**) |
| `simcity/config.lua` | 81 dòng, `REFRESH_RATE = 18`, `BOT_STALL_PRICE_MULTIPLIER = 15` (max 100) |

## 5. Audit tài liệu HQVL ↔ server nhà (17/09/2026, chỉ đọc)

60 bài HQVL (`~/jx1-knowledge/text/`, mirror `sources/hqvl-docs-text/`) mô tả server của **tác giả bài viết**,
không phải server nhà ⇒ **luôn `find`/`head` trên server trước khi dùng đường dẫn/tên file từ HQVL**.
Lần kiểm này 5/9 đường dẫn đúng, 4 sai:

| Tài liệu HQVL / từ điển ghi | Thực tế trên server nhà |
|---|---|
| `Server/Settings/Missile.txt` | `settings/missles.txt` (442 dòng) + `settings/missletemplate.txt` |
| `script/lib/comon.lua` | `script/lib/common.lua` ("comon" là lỗi chính tả của HQVL) |
| `状态图形对照表.txt` | `settings/状态特效图形对照表.txt` (tên GBK) |
| `server1/settings/relaysetting/maplist.ini` | `server1/settings/maplist.ini` |
| `gateway/s3relay/setting/worldset.txt` | `gateway/s3relay/settings/worldset.txt` |

Đúng như tài liệu: `settings/task/missions.txt`, `settings/timertask.txt`, `script/battles/battlehead.lua`,
`script/global/autoexec.lua`, `settings/magicdesc.ini`, `s3relay/relaysetting/task/tasklist.ini`,
`script/skill/<phái>.lua`.

Header THẬT (giải các ô "chưa rõ" của từ điển trong skill `<SSH_ALIAS>-skill-data-modding` — skill đó user-owned,
không patch được; ghi tạm ở đây):

- `settings/missles.txt`: **57 cột**, TAB. Thứ tự: MissleId, MissleName, MoveKind, FollowKind, ColFollowTarget,
  MissleHeight, CollidRange, IsRangeDmg, DmgRange, DmgInterval, LifeTime, Speed, Zspeed, Zacc, LoopPlay,
  SubLoop, SubStart, SubStop, ResponseSkill, CanDestroy, ColVanish, CanSlow, CanColFriend, AutoExplode,
  **MissRate (cột 25 — KHÔNG có trong từ điển; 441/441 dòng = 0 ⇒ cột chết)**, Param1, Param2, Param3,
  MultiShow, rồi 24 cột hiệu ứng (`AnimFileN` = đường dẫn `.spr`, `AnimFileInfoN` = bộ số `64,16,1`,
  `SndFileN` = `.wav`, N = 1..4 tuyến chính + B1..B4 tuyến phụ), kết bằng `RedLum/GreenLum/BlueLum/LightRadius`.
  Giá trị đang dùng: `MoveKind` 0=205, 1=188, 2=1, 3=3, 4=15, 5=13, **7=9**, 100=7 (⇒ 7 là giá trị thật,
  hết "chưa rõ"); `FollowKind` 0=438, 1=2, 2=1. `Zacc`/`ResponseSkill`/`Param1-3` phần lớn = 0 ⇒ **không suy
  được nghĩa từ dữ liệu, đừng bịa**.
- `settings/skills.txt`: **114 cột**, đúng **20 cặp LvlSetting + 20 LvlData** (con số "tối đa 10" trong tài liệu
  gốc là giới hạn server cũ). Sau `WaitTime` (28) là **`IsSaveCd` (29)** + **`ClientSend` (30)** rồi mới
  `SkillCostType` (31) ⇒ cột "AC chưa rõ tên" trong từ điển gần như chắc chắn là `IsSaveCd`/`ClientSend`.
  Có thật mà từ điển không liệt kê: `TimePerCastOnHorse` (34). `RelativePosType` (66) tên ĐÚNG, nghĩa chưa rõ.

⛔ **Tài liệu HQVL không phải nguồn để sửa server nhà**: đừng copy nguyên hex-patch/ID/item ID từ bài viết
(nhiều bài ghi rõ ID item/cửa hàng của server tác giả). Chỉ lấy *phương pháp*, rồi tra ID thật trên server.
