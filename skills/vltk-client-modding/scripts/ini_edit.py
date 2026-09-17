#!/usr/bin/env python3
"""Sửa key trong 1 section của ini JX1 (byte hỗn hợp GBK/TCVN3/CRLF) mà KHÔNG làm hỏng file.

Vì sao cần: ini client JX1 chứa bytes không decode được bằng 1 codec duy nhất
(GBK cho tên spr Trung, TCVN3 cho chữ Việt) -> luôn xử lý qua latin-1 (round-trip lossless)
và khi cần ghi chữ Trung thì encode('gbk') trước, khi cần chữ Việt thì encode qua TCVN3.

Dùng:
  python3 ini_edit.py <file.ini> <Section> Key=Value [Key=Value ...]
  python3 ini_edit.py client/ui/ctc/battle/battle_select.ini Main Moveable=1 Left=1350
  python3 ini_edit.py <file.ini> <Section> --show          # in section hiện tại

- Chỉ sửa key trong ĐÚNG section (key chưa có -> thêm vào cuối section đó).
- Giữ nguyên CRLF + bytes còn lại; in diff trước/sau để tự kiểm.
- Nhắc: Label= của client là TCVN3. Encode bằng `vietnamese-conversion` (node):
      toTCVN3('Nhiệm vụ','unicode') -> 'NhiÖm vô'  (verify lại bằng toUnicode(x,'tcvn3'))
"""
import re, sys

def sec_span(txt, name):
    m = re.search(r'(?m)^\[' + re.escape(name) + r'\]\r?\n', txt)
    if not m:
        sys.exit('Không thấy section [%s]' % name)
    end = txt.find('\n[', m.end())
    return m.end(), (end + 1 if end != -1 else len(txt))

def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    path, section = sys.argv[1], sys.argv[2]
    raw = open(path, 'rb').read()
    txt = raw.decode('latin-1')                     # lossless
    s, e = sec_span(txt, section)
    blk = txt[s:e]

    if sys.argv[3] == '--show':
        print('[%s]' % section)
        print(blk)
        return

    for kv in sys.argv[3:]:
        key, _, val = kv.partition('=')
        pat = re.compile(r'(?m)^(\s*;?\s*' + re.escape(key) + r'\s*=\s*)[^\r\n]*')
        if pat.search(blk):
            old = pat.search(blk).group(0)
            blk = pat.sub(lambda m: m.group(1) + val, blk, count=1)
            print('  ~ %s: %r -> %r' % (key, old.strip(), (key + '=' + val)))
        else:
            nl = '\r\n' if '\r\n' in blk else '\n'
            blk = blk.rstrip('\r\n ') + nl + key + '=' + val + nl
            print('  + %s=%s (thêm mới)' % (key, val))

    out = txt[:s] + blk + txt[e:]
    if out == txt:
        print('Không có gì đổi.'); return
    open(path, 'wb').write(out.encode('latin-1'))

    # ---- verify ----
    chk = open(path, 'rb').read().decode('latin-1')
    s2, e2 = sec_span(chk, section)
    print('=== [%s] sau khi ghi ===' % section)
    print(chk[s2:e2])
    assert chk.count('[' + section + ']') == 1
    crlf_bad = chk.count('\n') - chk.count('\r\n')
    print('OK. Dòng LF lẻ (nên = 0 nếu file gốc CRLF):', crlf_bad)

if __name__ == '__main__':
    main()
