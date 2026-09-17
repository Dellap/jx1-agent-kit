#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""Copy 4 cua so dung ban (摆摊*) + 2 cua so NPC (npc买卖界面/npc描述界面) tu theme day du
sang theme dang chay, BANG TEN MOJIBAKE

⛔ KHONG sua duoc loi "click bot dung ban khong xem duoc hang": loi do o module engine
   vdk.dll/vdk.so (xem SKILL.md muc "Shop dung ban ... module ENGINE vdk"), khong phai thieu file theme.
   Script nay chi de bo sung cua so con thieu cho theme. (bytes GBK -> latin1) — dung quy luat ten file cua client JX1/CTC.

Chay TREN WSL (host `jx1`):  ssh <SSH_ALIAS2> 'python2 -' < fix_shop_stall_theme.py
Nguon: ui/ui_ctc_v2 (co du 133 ini) | Dich: ui/ctc (theme dang chay, thieu cua so dung ban)
Kiem chung: ui/ctc/°ÚÌ¯ÎïÆ·.ini ton tai + spr/Ui3/°ÚÌ¯/Ì¯Ö÷Ãæ°å.spr ton tai.
"""
import os, shutil, sys

CLIENT = '$GAME_ROOT/Client'
SRC_THEME = os.path.join(CLIENT, 'ui', 'ui_ctc_v2')
DST_THEME = os.path.join(CLIENT, 'ui', 'ctc')

WINDOWS = [
    u'\u6446\u644a\u7269\u54c1',           # 摆摊物品   (bang hang cua chu quay)
    u'\u6446\u644a\u6807\u4ef7',           # 摆摊标价
    u'\u6446\u644a\u5e7f\u544a\u6761',       # 摆摊广告条
    u'\u6446\u644a\u8bbe\u7f6e\u5e7f\u544a',   # 摆摊设置广告
    u'npc\u4e70\u5356\u754c\u9762',        # npc买卖界面
    u'npc\u63cf\u8ff0\u754c\u9762',        # npc描述界面
]


def moji(u):
    """Ten that tren dia cua client: GBK bytes doc nhu latin-1."""
    return u.encode('gbk').decode('latin-1')


def main():
    if not os.path.isdir(SRC_THEME):
        print('KHONG thay theme nguon: %s' % SRC_THEME)
        return 1
    ok = 0
    for name in WINDOWS:
        for cand in (moji(name) + '.ini', name + '.ini'):      # uu tien ten mojibake
            src = os.path.join(SRC_THEME, cand)
            if os.path.exists(src):
                dst = os.path.join(DST_THEME, moji(name) + '.ini')
                shutil.copyfile(src, dst)
                print('OK  %-26s -> %-30s %d bytes' % (cand, moji(name) + '.ini', os.path.getsize(dst)))
                ok += 1
                break
        else:
            print('THIEU trong theme nguon: %s' % name)
    # kiem sprite (phai co san, ten mojibake)
    checks = [(u'\u6446\u644a', u'\u644a\u4e3b\u9762\u677f'), (u'\u4e70\u5356', u'\u4e70\u5356\u9762\u677f')]
    for d, f in checks:
        p = os.path.join(CLIENT, 'spr', 'Ui3', moji(d), moji(f) + '.spr')
        print('SPR %-22s %s' % (moji(f) + '.spr', 'CO (%d bytes)' % os.path.getsize(p) if os.path.exists(p) else 'THIEU'))
    print('=> copy %d/%d. Tat client, mo lai, dang nhap, click bot dung ban.' % (ok, len(WINDOWS)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
