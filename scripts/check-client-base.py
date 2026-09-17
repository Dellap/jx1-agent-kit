#!/usr/bin/env python3
"""check-client-base.py <thư-mục-Client>  — CHẠY ĐẦU TIÊN trước khi áp "UI 3+6 ô".

Kiểm client ở máy đích có cùng "nền" (theme CTC, layout 800x600) với mẫu trong repo không.
Chỉ ĐỌC — không sửa gì. Kết quả:
  MATCH    -> số Left/Top trong runbook dùng được
  GỐC      -> client chưa mod, cùng nền -> áp được
  MISMATCH -> nền khác (theme/resolution/toolbar khác) -> DỪNG, phải diff trước
Exit: 0 = an toàn để áp, 1 = dừng lại.
"""
import os, re, sys, difflib

def gbk_name(name: str) -> str:
    """tên file trên đĩa -> tên thật (GBK bytes)"""
    try:
        return os.fsencode(name).decode("gbk", "ignore")
    except Exception:
        return name

def norm(p):
    b = open(p, "rb").read().decode("latin-1")
    return [re.sub(r"\s+", "", l) for l in b.replace("\r\n", "\n").split("\n")]

ALIAS = {"主界面": ("main_player_info.ini", "玩家信息主界面.ini"), "控制条": ("toolbar.ini", "顶部控制条.ini")}

def find_ui(client, want_kw):
    """tìm file ui/ctc theo tên GBK chứa keyword ('主界面'/'控制条') hoặc tên ASCII đã đổi trong repo"""
    d = os.path.join(client, "ui", "ctc")
    if not os.path.isdir(d):
        return None
    for n in sorted(os.listdir(d)):
        real = gbk_name(n)
        if not n.endswith(".ini") or ".bak" in n:
            continue
        if want_kw in real or n in ALIAS.get(want_kw, ()) or real in ALIAS.get(want_kw, ()):
            return os.path.join(d, n)
    return None

def cfg_get(path, section, key):
    if not path or not os.path.isfile(path):
        return None
    s = None
    for l in open(path, "rb").read().decode("latin-1").splitlines():
        l = l.strip()
        if l.startswith("["):
            s = l.strip("[]")
        elif s == section and l.lower().startswith(key.lower() + "="):
            return l.split("=", 1)[1].strip()
    return None

def main():
    if len(sys.argv) < 2:
        print(__doc__); return 2
    client = sys.argv[1].rstrip("/\\")
    sample = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sources", "client-sample")
    print(f"client đích : {client}")
    print(f"mẫu trong repo: {sample}\n")

    theme = cfg_get(os.path.join(client, "config.ini"), "Client", "Theme")
    res_w = cfg_get(os.path.join(client, "resolution.ini"), "Resolution", "Width")
    res_h = cfg_get(os.path.join(client, "resolution.ini"), "Resolution", "Height")
    port  = cfg_get(os.path.join(client, "config.ini"), "Server", "GameServPort")
    addr  = cfg_get(os.path.join(client, "UserData", "uicommon.ini"), "Region_0", "0_Address")
    print(f"theme={theme}  resolution={res_w}x{res_h}  GameServPort={port}  0_Address={addr}")

    tgt_main = find_ui(client, "主界面")
    tgt_bar  = find_ui(client, "控制条")
    if not tgt_main or not tgt_bar:
        print("\n!! KHÔNG thấy ui/ctc/<玩家信息主界面.ini|顶部控制条.ini> dạng file LỎNG.")
        print("   => 2 file này còn nằm trong ui.pak. Phải bóc ra bằng unpack.exe (Windows) trước,")
        print("      hoặc chỉ đặt file lỏng của mod vào ui/ctc (file lỏng đè pak).")
        return 1
    print(f"main={os.path.basename(tgt_main)!r}  bar={os.path.basename(tgt_bar)!r}")

    orig_main = os.path.join(sample, "orig/unpack_out/ui/ctc/main_player_info.ini")
    orig_bar  = os.path.join(sample, "orig/unpack_out/ui/ctc/toolbar.ini")
    mod_main  = os.path.join(sample, "mod3x6/Ui/ctc/main_player_info.ini")
    mod_bar   = os.path.join(sample, "mod3x6/Ui/ctc/toolbar.ini")

    verdict, notes = "MATCH", []
    if theme and theme != "CTC":
        verdict = "MISMATCH"; notes.append(f"theme={theme} (mẫu là CTC) -> toạ độ UI sẽ lệch")
    # so toolbar với CẢ 2 mẫu: gốc (chưa mod) và mod (đã mod) — khớp mẫu nào cũng là cùng nền
    def ndiff(a_path, lines):
        return len([l for l in difflib.unified_diff(norm(a_path), lines, lineterm="", n=0) if l[:1] in "+-"]) - 2
    tgt_bar_lines = norm(tgt_bar)
    d_orig, d_mod = ndiff(orig_bar, tgt_bar_lines), ndiff(mod_bar, tgt_bar_lines)
    base = "gốc" if d_orig <= 4 else ("mod" if d_mod <= 4 else None)
    if base is None:
        verdict = "MISMATCH"
        notes.append(f"顶部控制条.ini KHỚP MẪU NÀO CŨNG KHÔNG (khác gốc {d_orig} dòng, khác bản mod {d_mod} dòng)"
                     " -> nền/layout khác, PHẢI diff trước khi áp số")
    else:
        notes.append(f"toolbar khớp bản {base} (lệch gốc {d_orig} / lệch mod {d_mod} dòng)")

    text = open(tgt_main, "rb").read().decode("latin-1")
    on  = len(re.findall(r"(?m)^\s*\[Item_[3-8]\]", text))
    off = len(re.findall(r"(?m)^\s*;\s*\[Item_[3-8]\]", text))
    top = re.search(r"(?m)^\s*Top=(\d+)", text[text.find("[Item_3]"):]) if on else None
    print(f"\nTrạng thái 6 ô: đang bật {on}/6, đang comment {off}/6"
          + (f", Top của ô đầu = {top.group(1)}" if top else ""))
    for n in notes: print("  · " + n)

    if verdict == "MISMATCH":
        print("\n==> MISMATCH: DỪNG. Đừng copy số Left/Top trong runbook.")
        print("    Làm: diff ui/ctc/玩家信息主界面.ini & 顶部控制条.ini của máy này với")
        print("         sources/client-sample/orig/unpack_out/ui/ctc/* rồi tự tính lại toạ độ,")
        print("         hoặc dùng đúng biến thể của client đó (xem sources/client-sample/mod3x6/Ui/{ctc,ctc1024,Ui3}).")
        for n in notes: print("    - " + n)
        return 1

    if on == 0:
        print("\n==> GỐC + CÙNG NỀN: áp được bộ số trong skills/runbooks/ui-3x6-slots.md")
        print("    (bỏ ';' ở [Item_3]..[Item_8], Top=494, Left 282/322/362/402/442/482;")
        print("     [InputBack] Left=221 Top=491; chỉnh 10 nút toolbar theo bảng).")
    elif on == 6:
        print("\n==> ĐÃ ÁP 6 ô (hoặc tương đương). Không cần làm lại; muốn về gốc thì rollback backup.")
    else:
        print(f"\n==> ÁP MỘT PHẦN ({on}/6). Kiểm lại các section còn comment trước khi sửa.")
    print("\nTrước khi ghi: backup 2 ini (+ spr/Ui3/thanhhienthi/thanh.spr), sau khi ghi verify CRLF:")
    print("  python3 -c \"d=open('<file.ini>','rb').read(); print('LF-only',d.count(b'\\n')-d.count(b'\\r\\n'))\"")
    return 0

if __name__ == "__main__":
    sys.exit(main())
