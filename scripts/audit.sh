#!/usr/bin/env bash
# audit.sh — BẮT BUỘC chạy trước khi push.
#   1) secret (mật khẩu / khoá / token / API / IP thật / MAC): quét TOÀN repo (kể cả sources/)
#   2) thông tin cá nhân (IP nội bộ, tên máy, tên người, SĐT, email, số dài): quét tài liệu mình viết
#      + pattern riêng của bạn trong scripts/.pii-local (không commit)
#   3) rác & file quá lớn
# Exit 1 nếu có phát hiện. Dùng: ./scripts/audit.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS="$ROOT/README.md $ROOT/START-HERE.md $ROOT/NOTICE.md $ROOT/skills"
# Danh sách từ khoá riêng của chủ repo (KHÔNG commit). Ưu tiên file NGOÀI repo để an toàn khi
# chia sẻ cả thư mục; vẫn nhận scripts/.pii-local hoặc đường dẫn trong $PII_LOCAL.
LOCAL=""
for _c in "${PII_LOCAL:-}" "$HOME/.jx1-repo-pii.txt" "$ROOT/scripts/.pii-local"; do
  if [ -n "$_c" ] && [ -f "$_c" ]; then LOCAL="$_c"; break; fi
done
fail=0

echo "== 1. Secret / khoá / IP thật (TOÀN repo) =="
SEC='((pass|pwd|passwd|password|matkhau|db_pass|dbpass)["'"'"']? *[:=] *[^ <"'"'"']{3,})'
SEC="$SEC"'|((api[_-]?key|apikey|access[_-]?key|client[_-]?secret|auth[_-]?token|bearer|token|secret)["'"'"']? *[:=] *[^ <"'"'"']{6,})'
SEC="$SEC"'|(sk-[A-Za-z0-9_-]{16,}|AIza[0-9A-Za-z_-]{20,}|ghp_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})'
SEC="$SEC"'|([0-9]{8,10}:AA[A-Za-z0-9_-]{25,})'
SEC="$SEC"'|(BEGIN [A-Z ]*PRIVATE KEY)'
SEC="$SEC"'|(sshpass +-p +[^ ]+)|((mysql|mariadb|mysqldump|mongo|psql)[^ ]*( [^ ]+){0,4} +-p[^ ]{4,})'
SEC="$SEC"'|((mongodb|redis|postgres|mysql|mssql|amqp)://[^ ]+)'
SEC="$SEC"'|((^|[^0-9])((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})([^0-9]|$))'
SEC="$SEC"'|(([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2})'
hits=$(grep -rInEi "$SEC" "$ROOT" --exclude-dir=.git --exclude=audit.sh --exclude=.pii-local 2>/dev/null \
  | grep -vE '127\.0\.0\.1|0\.0\.0\.0|<[A-Z_]+>|PASSWORD|PASS\b|\.\.\.|xxx|<REDACTED>|placeholder|ví dụ|VD:|^[^:]+:[0-9]+: *description:|root/[a-z-]+\.sh|PASS:' || true)
if [ -n "$hits" ]; then echo "$hits"; echo "!! NGHI CÓ SECRET / IP THẬT"; fail=1; else echo "OK"; fi

echo
echo "== 2. Thông tin cá nhân / hạ tầng (tài liệu mình viết) =="
PII='((^|[^0-9])(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]+\.[0-9]+)|([A-Z]:\\Users\\[A-Za-z0-9._-]+)|(/Users/[A-Za-z0-9._-]+)|(\+84[0-9 .-]{6,})|((^|[^0-9])0[0-9]{9}([^0-9]|$))|([[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,})|((^|[^0-9])[0-9]{9,13}([^0-9]|$))'
pii=$(grep -rInEi "$PII" $DOCS 2>/dev/null \
  | grep -vE '127\.0\.0\.1|<[A-Z_]+>|RFC1918|192\.168\.1\.x|jx1offline@gmail\.com|noreply@example\.com|0-255|0\.0\.0\.0|\.html\.txt|wiki-beta__|jx1-scripts__|tutorials__|jxtools__|simbot__' || true)
if [ -f "$LOCAL" ]; then
  local_hits=$(grep -rInEif <(grep -vE '^\s*(#|$)' "$LOCAL") $DOCS 2>/dev/null || true)
  [ -n "$local_hits" ] && pii="$pii
$local_hits"
fi
if [ -n "${pii// /}" ]; then echo "$pii"; echo "!! LỘ THÔNG TIN CÁ NHÂN/HẠ TẦNG"; fail=1; else echo "OK"; fi

echo
echo "== 3. File > 400KB =="
find "$ROOT" -type f -not -path "*/.git/*" -size +400k -exec ls -lh {} \; | awk '{print $5, $9}' | sed "s|$ROOT/||"

echo
echo "== 4. Rác không nên commit =="
find "$ROOT" -type f -not -path "*/.git/*" \( -name "*.tgz" -o -name "*.zip" -o -name ".DS_Store" -o -name "*.bak" -o -name "*Zone.Identifier" \) -print | sed "s|$ROOT/||"

echo
echo "== 5. Tổng quan =="
printf "files: %s | size: %s | skills: %s | sources: %s | pii-local: %s\n" \
  "$(find "$ROOT" -type f -not -path '*/.git/*' | wc -l | tr -d ' ')" "$(du -sh "$ROOT" | cut -f1)" \
  "$(ls "$ROOT/skills" | wc -l | tr -d ' ')" "$(du -sh "$ROOT/sources" | cut -f1)" \
  "$([ -f "$LOCAL" ] && echo có || echo không)"

echo
[ "$fail" -eq 0 ] && echo "==> PASS: sẵn sàng push" || echo "==> FAIL: xử lý mục 1/2 trước khi push"
exit $fail
