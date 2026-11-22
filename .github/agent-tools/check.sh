#!/usr/bin/env bash
# check.sh - read-only verification used by the /check command of the build-engineer agent.
#
# It does NOT create, edit or delete project files. The only side effect is the
# generated build/ directory produced by ci.sh / ci.bat (ignored by Git).
#
# Usage:  bash .github/agent-tools/check.sh            # full check, including build and tests
#         bash .github/agent-tools/check.sh --no-build # only structure, config and Git checks
# Works on Linux, macOS and Windows (Git Bash). Exit code 0 = PASS, 1 = FAIL.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0")/" || exit 1

RUN_BUILD=1
[ "${1:-}" = "--no-build" ] && RUN_BUILD=0

pass=0; fail=0; warn=0
ok()   { printf '  [PASS] %s\n' "$*"; pass=$((pass+1)); }
bad()  { printf '  [FAIL] %s\n' "$*"; fail=$((fail+1)); }
wrn()  { printf '  [WARN] %s\n' "$*"; warn=$((warn+1)); }
section() { printf '\n== %s\n' "$*"; }
has()  { grep -qiE -- "$2" "$1" 2>/dev/null; }

# ---------------------------------------------------------------- 1. agent
section "1. Agent manifest"
AGENT=.github/agents/build-engineer.agent.md
if [ -f "$AGENT" ]; then
  ok "$AGENT exists"
  has "$AGENT" '^description:' && ok "manifest has description" || bad "manifest: no description in frontmatter"
  has "$AGENT" '^## Роль'                    && ok "manifest: role"                || bad "manifest: section '## Роль' missing"
  has "$AGENT" '^## Область відповідальності' && ok "manifest: scope"               || bad "manifest: section '## Область відповідальності' missing"
  has "$AGENT" '^## Заборонені дії'           && ok "manifest: forbidden actions"   || bad "manifest: section '## Заборонені дії' missing"
  has "$AGENT" '^## Критерії успішного'       && ok "manifest: completion criteria" || bad "manifest: section '## Критерії успішного завершення' missing"
else
  bad "$AGENT not found"
fi

# ---------------------------------------------------------------- 2. skills
section "2. Skills"
for s in project-scaffold build-and-test github-actions; do
  f=".github/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then bad "$f not found"; continue; fi
  missing=""
  has "$f" "^name: $s\$"     || missing="$missing name"
  has "$f" '^description:'   || missing="$missing description"
  for h in 'Коли застосовувати' 'Входи' 'Виходи' 'Перевірка' 'Помилки' 'Приклад'; do
    has "$f" "^## .*$h" || missing="$missing '$h'"
  done
  [ -z "$missing" ] && ok "skill $s: purpose, inputs, outputs, checks, errors, example" || bad "skill $s: missing$missing"
done

# ---------------------------------------------------------------- 3. commands
section "3. Commands"
for c in git-init create-project create-build create-actions check init; do
  f=".github/prompts/$c.prompt.md"
  if [ ! -f "$f" ]; then bad "$f not found"; continue; fi
  missing=""
  has "$f" '^description:'          || missing="$missing description"
  has "$f" '^agent: build-engineer' || missing="$missing agent"
  for h in 'Передумови' 'Дії' 'Очікувані файли' 'Перевірка' 'Помилки'; do
    has "$f" "^## .*$h" || missing="$missing '$h'"
  done
  [ -z "$missing" ] && ok "command /$c" || bad "command /$c: missing$missing"
done

INIT=.github/prompts/init.prompt.md
if [ -f "$INIT" ]; then
  order=$(grep -oE '/(git-init|create-project|create-build|create-actions|check)' "$INIT" | awk '!seen[$0]++' | tr '\n' ' ')
  if [ "$order" = "/git-init /create-project /create-build /create-actions /check " ]; then
    ok "init order: $order"
  else
    bad "init order is wrong: '$order'"
  fi
fi

# ---------------------------------------------------------------- 4. project
section "4. Project files"
for f in README.md .gitignore .gitattributes pom.xml ci.sh ci.bat \
         src/main/java/ua/lpnu/ki405/hello/App.java \
         src/main/java/ua/lpnu/ki405/hello/Calculator.java \
         src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java \
         src/test/java/ua/lpnu/ki405/hello/AppTest.java \
         .github/workflows/ci.yml docs/architecture.md docs/usage.md docs/ai-log.md; do
  [ -f "$f" ] && ok "$f" || bad "$f not found"
done
grep -q 'void BasicAddition' src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java 2>/dev/null \
  && ok "test BasicAddition is defined" || bad "test BasicAddition not defined"
grep -q '<directory>${project.basedir}/build</directory>' pom.xml 2>/dev/null \
  && ok "pom.xml: build directory is build/" || bad "pom.xml: build directory is not build/"
grep -q '<mainClass>' pom.xml 2>/dev/null && ok "pom.xml: executable jar (Main-Class)" || bad "pom.xml: no mainClass"
if [ -f README.md ]; then
  n=$(grep -c '<!-- agent:project-section -->' README.md)
  [ "$n" = "1" ] && ok "README: project section present once" || bad "README: project section count = $n (expected 1)"
fi
if [ -f .gitignore ]; then
  dups=$(grep -vE '^\s*(#|$)' .gitignore | sort | uniq -d)
  [ -z "$dups" ] && ok ".gitignore: no duplicate lines" || bad ".gitignore: duplicates: $dups"
fi

# ---------------------------------------------------------------- 5. workflow
section "5. GitHub Actions workflow"
WF=.github/workflows/ci.yml
if [ -f "$WF" ]; then
  PY=$(command -v python3 || command -v python || true)
  if [ -n "$PY" ] && "$PY" -c 'import yaml' 2>/dev/null; then
    if "$PY" - "$WF" <<'PYEOF'
import sys, yaml
def check(d):
    on = d.get("on", d.get(True))          # PyYAML reads the key "on" as True
    assert isinstance(on, dict), "no 'on' triggers"
    for ev in ("push", "pull_request"):
        br = on[ev]["branches"]
        assert "develop" in br and "master" in br, f"{ev} must target develop and master"
    jobs = d["jobs"]
    assert len(jobs) == 1, "exactly one job expected"
    job = next(iter(jobs.values()))
    oses = job["strategy"]["matrix"]["os"]
    assert set(oses) == {"ubuntu-latest", "windows-latest", "macos-latest"}, f"matrix: {oses}"
    runs = [s["run"] for s in job["steps"] if "run" in s]
    assert runs and all(r.strip() in ("./ci.sh", "call ci.bat") for r in runs), f"run steps: {runs}"
try:
    check(yaml.safe_load(open(sys.argv[1], encoding="utf-8")))
except (AssertionError, KeyError, TypeError, yaml.YAMLError) as e:
    print("         ci.yml problem:", repr(e))
    sys.exit(1)
PYEOF
    then ok "ci.yml: valid YAML, push+PR to develop/master, one job, 3 OS, only ci.sh/ci.bat"
    else bad "ci.yml: structure check failed (see message above)"; fi
  else
    wrn "python3 + PyYAML not available: using text checks only"
    for os in ubuntu-latest windows-latest macos-latest; do
      has "$WF" "$os" && ok "ci.yml: $os" || bad "ci.yml: $os missing"
    done
    has "$WF" 'run: \./ci\.sh' && has "$WF" 'run: call ci\.bat' && ok "ci.yml runs ci.sh / ci.bat" || bad "ci.yml does not run ci.sh / ci.bat"
  fi
  if grep -nE '(ghp_|github_pat_|AKIA[0-9A-Z]{12}|password:|token:)' "$WF" >/dev/null; then
    bad "ci.yml: looks like it contains a secret"
  else
    ok "ci.yml: no secrets"
  fi
else
  bad "$WF not found"
fi

# ---------------------------------------------------------------- 6. git hygiene
section "6. Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ok "inside a Git repository (branch: $(git branch --show-current))"
  git check-ignore -q build/ && ok "build/ is ignored" || bad "build/ is NOT ignored"
  tracked=$(git ls-files | grep -E '(^|/)(build|target)/|\.class$|\.jar$' || true)
  [ -z "$tracked" ] && ok "no build output tracked by Git" || bad "build output tracked: $tracked"
  secrets=$(git ls-files -z | xargs -0 grep -lE 'ghp_[A-Za-z0-9]{20,}|github_pat_|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----' 2>/dev/null \
            | grep -v '^.github/agent-tools/check.sh$' || true)
  [ -z "$secrets" ] && ok "no secrets in tracked files" || bad "possible secrets in: $secrets"
  mode=$(git ls-files -s ci.sh 2>/dev/null | cut -d' ' -f1)
  [ "$mode" = "100755" ] && ok "ci.sh is executable in Git" || wrn "ci.sh mode in Git is '${mode:-untracked}' (expected 100755)"
else
  bad "not a Git repository"
fi

# ---------------------------------------------------------------- 7. build + tests
section "7. Build and tests"
if [ "$RUN_BUILD" = "1" ]; then
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) cmd //c ci.bat > build-check.log 2>&1; rc=$? ;;
    *)                    bash ./ci.sh  > build-check.log 2>&1; rc=$? ;;
  esac
  mkdir -p build && mv -f build-check.log build/check.log
  if [ "$rc" = "0" ] && grep -q 'CI RESULT: PASS' build/check.log; then
    ok "ci script finished with code 0"
    grep -E 'Tests run:' build/check.log | tail -n 1 | sed 's/^/         /'
    ok "hello prints: $(grep 'hello says:' build/check.log | sed 's/.*hello says: //')"
  else
    bad "ci script failed (code $rc). Reason from build/check.log:"
    { grep -E '<<< FAIL|expected: |ERROR\] (  |COMPILATION)|^ERROR: ' build/check.log | head -n 10
      grep -E 'Tests run: .*Failures' build/check.log | tail -n 1; } | sed 's/^/         /'
    echo "         full log: build/check.log"
  fi
else
  wrn "build skipped (--no-build)"
fi

# ---------------------------------------------------------------- summary
printf '\nSUMMARY: %d passed, %d failed, %d warnings\n' "$pass" "$fail" "$warn"
if [ "$fail" -eq 0 ]; then echo "RESULT: PASS"; exit 0; else echo "RESULT: FAIL"; exit 1; fi
