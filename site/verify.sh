#!/usr/bin/env bash
# After a deploy: both hostnames serve public/index.html byte for byte, and the
# CSP header is the one public/_headers sets (build.py writes both; their hashes
# must match). Cloudflare's edge can lag an upload, so each check retries for
# up to 90 s. Read-only GETs. Exit 1 names what failed.
set -uo pipefail
cd "$(dirname "$0")/.."
want_csp=$(sed -n 's/^[[:space:]]*Content-Security-Policy:[[:space:]]*//p' public/_headers | head -1)
[ -n "$want_csp" ] || { echo "🛑 no Content-Security-Policy in public/_headers"; exit 1; }
bad=0
for host in pdxfixit.com www.pdxfixit.com; do
  ok=0
  for _ in $(seq 1 30); do
    if curl -fsS -m 20 "https://$host/?$RANDOM" | cmp -s - public/index.html; then ok=1; break; fi
    sleep 3
  done
  [ "$ok" = 1 ] && echo "✅ $host serves public/index.html" || { echo "❌ $host does not serve public/index.html"; bad=1; }
  got_csp=$(curl -fsS -m 20 -D - -o /dev/null "https://$host/?$RANDOM" | tr -d '\r' | sed -n 's/^[Cc]ontent-[Ss]ecurity-[Pp]olicy:[[:space:]]*//p' | head -1)
  [ "$got_csp" = "$want_csp" ] && echo "✅ $host CSP matches _headers" || { echo "❌ $host CSP differs from _headers"; bad=1; }
done
exit $bad
