# GBK filenames + smbclient — recipe

## Vấn đề
Tên file tiếng Trung trên share Windows (JX1 client) lưu dưới dạng **GBK bytes**. smbclient nhận tên UTF-8 → `NT_STATUS_OBJECT_NAME_NOT_FOUND`. Phải truyền đúng byte GBK.

## Cách lấy tên GBK để dùng với smbclient
Chuỗi mojibake hiện trong `ls` output CHÍNH LÀ byte GBK render dưới dạng Latin-1/UTF-8 — copy nguyên chuỗi đó vào lệnh `cd`/`get`/`put`.

Ví dụ (top bar ini):
```bash
smbclient "//<GAME_HOST_IP>/VoLamTruyenKy" -U "<SMB_USER>%<pass>" -m SMB3 \
  -c 'cd CLIENT\ui\ctc; get "¶¥²¿¿ØÖÆÌõ.ini" /tmp/topbar.ini'
```
- `¶¥²¿¿ØÖÆÌõ.ini` = mojibake của `顶部控制条.ini`
- KHÔNG được gõ `顶部控制条.ini` trực tiếp (UTF-8 → fail)

## Decode mojibake → tên thật (Python)
```python
# bytes từ file list đã lưu (vd từ `smbclient -c "ls" > list.txt`)
raw = open('list.txt','rb').read().splitlines()
for line in raw:
    s = line.decode('utf-8', 'replace')   # smbclient output thực ra là UTF-8 hóa của GBK bytes
    try:
        print(s.encode('latin-1').decode('gbk'))  # -> tên thật tiếng Trung
    except Exception:
        print(s)
```
Giải thích: smbclient output = UTF-8 encoding của chuỗi Latin-1-interpreted-GBK → `utf-8 decode` → `latin-1 encode` (lấy lại GBK bytes gốc) → `gbk decode` = tên thật.

## GBK name map (đã dùng trong session)
| Tên thật (UTF-8) | Mojibake để dùng trong smbclient |
|---|---|
| 顶部控制条.ini | ¶¥²¿¿ØÖÆÌõ.ini |
| 玩家头像.ini | Íæ¼ÒÍ·Ïñ.ini |
| 生命条.spr | ÉúÃüÌõ.spr |
| 内力条.spr | ÄÚÁ¦Ìõ.spr |
| 主界面 (folder) | Ö÷½çÃæ |
| 五行.ini | ÎåÐÐ.ini |
| 公共.ini | ¹«¹².ini |

## CRLF check
```python
d = open('file.ini','rb').read()
assert d.count(b'\n') - d.count(b'\r\n') == 0   # 0 = toàn CRLF chuẩn
```
Khi sửa bằng Python: đọc bytes, dùng `data.replace(old, new)` với old/new chứa `\r\n` đầy đủ; append section mới phải dùng `\r\n` (không dùng LF-only) — parser cũ có thể nuốt section lạ line-ending.
