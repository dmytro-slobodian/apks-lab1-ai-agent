#!/usr/bin/env bash
# ci.sh - configure, build, unit-test and package "hello" on Linux and macOS.
# Used both locally and by GitHub Actions (.github/workflows/ci.yml).
# Deletes nothing except the generated build/ directory (mvn clean).
set -euo pipefail
cd "$(dirname "$0")"

# Extra Maven arguments, e.g. MVN_ARGS="-o" for an offline build. Empty by default.
MVN_ARGS="${MVN_ARGS:-}"

log()  { printf '\n==> %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

log "1/5 Environment"
command -v java >/dev/null 2>&1 || fail "java not found (JDK 17+ required)"
command -v mvn  >/dev/null 2>&1 || fail "mvn not found (Maven 3.9+ required)"
java -version 2>&1 | sed -n '1p'   # sed, not head: head + pipefail can fail on SIGPIPE
mvn -v 2>/dev/null | sed -n '1p'

log "2/5 Configure, compile, unit tests, package (mvn clean verify)"
# shellcheck disable=SC2086  # MVN_ARGS is intentionally split into words
mvn -B -ntp $MVN_ARGS clean verify

log "3/5 Test results"
report="build/surefire-reports/TEST-ua.lpnu.ki405.hello.CalculatorTest.xml"
[ -f "$report" ] || fail "test report not found: $report"
grep -q 'testcase name="BasicAddition' "$report" || fail "test BasicAddition did not run"
grep -h '<testsuite ' build/surefire-reports/TEST-*.xml \
  | sed -E 's/.*name="([^"]+)".*tests="([0-9]+)".*failures="([0-9]+)".*/\1: tests=\2 failures=\3/' || true

log "4/5 Executables -> build/dist"
mkdir -p build/dist
cp build/hello.jar build/dist/hello.jar
cat > build/dist/hello <<'LAUNCHER'
#!/usr/bin/env sh
exec java -jar "$(dirname "$0")/hello.jar" "$@"
LAUNCHER
chmod +x build/dist/hello

log "5/5 Smoke test"
out="$(build/dist/hello)"
[ "$out" = "Hello, World!" ] || fail "unexpected output: '$out'"
echo "hello says: $out"
echo "CI RESULT: PASS"
