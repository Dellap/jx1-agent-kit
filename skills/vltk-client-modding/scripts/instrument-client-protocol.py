#!/usr/bin/env python3
"""Gắn log chẩn đoán vào script/protocol.lua của JX1/VLTK CLIENT (không đụng file mod).

Cách dùng:
    python3 instrument-client-protocol.py <protocol.lua vào> [<ra>]
    luajit -bl <ra> /dev/null          # kiểm CÚ PHÁP trước khi đẩy
    # đẩy lên client: ssh <SSH_ALIAS> 'cat > .../Client/script/protocol.lua' < <ra>
    # bạn mở lại client + đăng nhập, rồi đọc Client/logs/protocol_log.txt

Log ghi ra Client\\logs\\protocol_log.txt (append):
  - 'LOOSE loaded. TASKTRACE_id=N ... | engine: pcall=.. call=.. getn=..'
        -> chứng minh bản LOOSE được nạp + biết DIALECT của engine. File rỗng = client dùng bản
           trong pak (slistcache.pak) -> phải đóng gói lại vào pak.
  - 'RX id=N name=emSCRIPT_PROTOCOL_XXX hasHandler=1|nil'
        -> MỌI protocol client nhận được: server thật sự gửi số nào, client hiểu thành tên gì.
           hasHandler=nil = client chưa có Def cho số đó (lệch số / thiếu Def).
  - 'CALL <file> <fun>' ... 'CALL-DONE <fun>'
        -> handler chạy tới đâu. Cụt ở CALL = chết BÊN TRONG handler (hàm engine / ui.lua mod).
           Có CALL-DONE = mod chạy trọn vẹn -> không hiện UI là vấn đề HIỂN THỊ của engine.

⛔ KHÔNG dùng `pcall` trong script client (bài học 17/09/2026 — tốn 3 lần test của bạn):
engine script là Lua đời cũ (`getn`/`tinsert`/`format` global, `for key,v in tbl do`), KHÔNG phải Lua 5.1,
nghi KHÔNG có `pcall`. Bọc pcall -> script dừng IM LẶNG ngay tại dòng đó (không log, không popup) -> log cụt
đúng sau dòng liền trước -> rất dễ kết luận sai là "hàm engine crash". Vì vậy script này chỉ LOG, giữ nguyên
code gọi handler; dialect thì LOG `tostring(pcall)/tostring(call)/tostring(getn)` chứ đừng gọi.

Sau khi xong: gỡ log (copy bản backup *.bak_<ts> về), giữ file log lại làm bằng chứng nếu cần.
"""
import sys

LOG_FN = """
do -- === DEBUG TAM (go sau khi xong) ===
__LOG = function(szMsg)
\tlocal f = openfile(".\\\\logs\\\\protocol_log.txt","a")
\tif not f then f = openfile(".\\\\logs\\\\protocol_log.txt","w") end
\tif f then write(f, szMsg .. "\\n"); closefile(f) end
end
"""


def instrument(src: str, out: str) -> str:
    b = open(src, encoding='latin-1').read()

    # 1) sau khi khởi tạo bảng enum -> chứng minh bản loose được nạp + id đang dùng + dialect engine
    a1 = '\nScriptProtocol:_InitProtocolEnum()\n'
    assert b.count(a1) == 1, ('anchor1 (thêm \\n đầu để không khớp dòng "function ...")', b.count(a1))
    b = b.replace(a1, a1 + LOG_FN +
                  '__LOG("LOOSE loaded. TASKTRACE_id=" .. '
                  'tostring(ScriptProtocol["emSCRIPT_PROTOCOL_TASKTRACE"]) .. " EXPRANK_id=" .. '
                  'tostring(ScriptProtocol["emSCRIPT_PROTOCOL_EXPRANK"]) .. " model=" .. '
                  'tostring(MODEL_GAMECLIENT) .. " | engine: pcall=" .. tostring(pcall) .. '
                  '" call=" .. tostring(call) .. " getn=" .. tostring(getn))\\nend\\n')

    # 2) log mọi protocol nhận được
    a2 = 'function ScriptProtocol:ProtocolProcess(nProtolId, nHandle)'
    assert b.count(a2) == 1, ('anchor2', b.count(a2))
    b = b.replace(a2, a2 + '\n\t__LOG("RX id=" .. tostring(nProtolId) .. " name=" .. '
                           'tostring(self.KE_SCRIPT_PROTOCOL[nProtolId]) .. " hasHandler=" .. '
                           'tostring(self.tbProtocolDef ~= nil and self.tbProtocolDef[nProtolId] ~= nil))')

    # 3) CHỈ kẹp log trước/sau lời gọi handler — KHÔNG pcall, KHÔNG đổi code gọi handler
    a3 = ('\t\telseif MODEL_GAMECLIENT == 1 then\n'
          '\t\t\tRequire(szFile);\n'
          '\t\t\tDynamicExecute(szFile, szFun, unpack(tbParam))\n')
    assert b.count(a3) == 1, ('anchor3', b.count(a3))
    b = b.replace(a3,
                  '\t\telseif MODEL_GAMECLIENT == 1 then\n'
                  '\t\t\t__LOG("CALL " .. szFile .. " " .. szFun)\n'
                  '\t\t\tRequire(szFile);\n'
                  '\t\t\tDynamicExecute(szFile, szFun, unpack(tbParam))\n'
                  '\t\t\t__LOG("CALL-DONE " .. szFun)\n')

    open(out, 'w', encoding='latin-1').write(b)
    return out


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else src.rsplit('.lua', 1)[0] + '.instrumented.lua'
    instrument(src, out)
    print("OK ->", out)
