#!/usr/bin/env bash
# postcard-capture against stand-ins for the picker, grim and hyprctl, so it
# runs without a compositor.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf -- "$scratch"' EXIT
export XDG_RUNTIME_DIR="$scratch/runtime with spaces"
export TEST_LOG="$scratch/log"
mkdir -p "$scratch/bin" "$XDG_RUNTIME_DIR/postcard-captures"
export PATH="$scratch/bin:$PATH"

# Prints the freeze PID and the selection, the way --keep-freeze does.
cat > "$scratch/bin/omarchy-capture-region" <<'MOCK'
#!/usr/bin/env bash
[[ "$*" == "${TEST_PICKER:-$TEST_MODE} --keep-freeze" ]] || { echo "picker args: $*" >> "$TEST_LOG"; exit 2; }
sleep 30 &
echo "$!" > "$TEST_LOG.freeze"
# Like the real picker, the freeze is named only once the pick is over, and
# slurp is a child that holds the pick open.
if [ -n "${TEST_HANG:-}" ]; then
  sleep 30 &
  echo "$!" > "$TEST_LOG.slurp"
  wait "$!"
fi
echo "$(cat "$TEST_LOG.freeze")"
[ -n "$TEST_SELECTION" ] && echo "$TEST_SELECTION"
exit 0
MOCK
cat > "$scratch/bin/grim" <<'MOCK'
#!/usr/bin/env bash
[ "$TEST_GRIM" = fail ] && exit 1
[[ "$1 $2" == "-g $TEST_SELECTION" ]] || exit 2
printf 'shot %s' "$TEST_MODE" > "$3"
MOCK
cat > "$scratch/bin/hyprctl" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  getoption) echo '{"int": 1}' ;;
  monitors) echo "[{\"name\":\"DP-1\",\"x\":0,\"y\":0,\"width\":${TEST_WIDTH:-3840},\"height\":2160,\"scale\":2,\"transform\":0,\"focused\":true}]" ;;
  keyword) echo "cursor $3" >> "$TEST_LOG" ;;
  *) exit 1 ;;
esac
MOCK
chmod +x "$scratch/bin/"*

fail() { echo "FAIL $*" >&2; exit 1; }
capture() {
  : > "$TEST_LOG"
  TEST_MODE="$1" TEST_SELECTION="$2" TEST_GRIM="$3" bash "$root/bin/postcard-capture" "$1" "${@:4}"
}
freeze_gone() { ! kill -0 "$(cat "$TEST_LOG.freeze")" 2>/dev/null; }
cursor_restored() { [ "$(cat "$TEST_LOG")" = $'cursor 0\ncursor 1' ]; }

dir="$XDG_RUNTIME_DIR/postcard-captures"
old="$dir/old.png"
printf previous > "$old"
result="$(capture region "" ok)"
[[ -z "$result" && -f "$old" ]] || fail "a cancelled pick returned a shot or removed the old one"
freeze_gone || fail "a cancelled pick left the screen frozen"
cursor_restored || fail "a cancelled pick left the cursor setting changed: $(cat "$TEST_LOG")"
result="$(capture region "0,0 10x10" fail)"
[[ -z "$result" && -z "$(find "$dir" -name 'screenshot-*')" ]] || fail "a failed grim returned a shot or left a file"

# Consecutive shots land in the same second; each must keep the one beside it.
previous="$old"
for mode in region windows fullscreen smart; do
  shot="$(capture "$mode" "10,20 300x200" ok "$previous")"
  [[ -f "$shot" && "$shot" != "$previous" ]] || fail "$mode returned no new shot"
  [[ "$(cat "$shot")" == "shot $mode" ]] || fail "$mode returned the wrong picture"
  [[ -f "$previous" ]] || fail "$mode removed the shot beside it"
  [[ "${shot%/*}" == "$dir" ]] || fail "$mode wrote outside the scratch directory"
  freeze_gone || fail "$mode left the screen frozen"
  cursor_restored || fail "$mode left the cursor setting changed"
  previous="$shot"
done
[[ ! -f "$old" ]] || fail "a shot no longer on the card was not cleaned up"
next="$(capture fullscreen "0,0 1920x1080" ok)"
[[ "$(find "$dir" -type f)" == "$next" ]] || fail "old captures were not cleaned up"

# The last pick comes back without the picker; fullscreen is not a pick.
memory="$XDG_RUNTIME_DIR/postcard-last-region"
rm -f "$memory" "$TEST_LOG.freeze"
[[ -z "$(bash "$root/bin/postcard-capture" --has-last)" ]] || fail "--has-last said yes with nothing kept"
shot="$(TEST_PICKER=region capture last "1,2 30x40" ok)"
[[ -f "$shot" && -e "$TEST_LOG.freeze" ]] || fail "last with nothing kept did not fall back to the region picker"
capture smart "5,6 70x80" ok >/dev/null
capture fullscreen "0,0 1920x1080" ok >/dev/null
[[ "$(bash "$root/bin/postcard-capture" --has-last)" == yes ]] || fail "--has-last missed a kept region"
[[ -z "$(TEST_WIDTH=2560 bash "$root/bin/postcard-capture" --has-last)" ]] || fail "--has-last took a region from another layout"
rm -f "$TEST_LOG.freeze"
shot="$(TEST_PICKER=none capture last "5,6 70x80" ok)"
[[ -f "$shot" && ! -e "$TEST_LOG.freeze" ]] || fail "last did not take the kept region without the picker"
cursor_restored || fail "last left the cursor setting changed"
rm -f "$TEST_LOG.freeze"
result="$(TEST_WIDTH=2560 TEST_PICKER=region capture last "" ok)"
[[ -z "$result" && -e "$TEST_LOG.freeze" ]] || fail "last took a region kept on another monitor layout"

# Killed mid-pick, as a plugin reload does: the picker, its slurp and its
# freeze all go, and the cursor setting comes back.
rm -f "$TEST_LOG.freeze" "$TEST_LOG.slurp"
: > "$TEST_LOG"
TEST_HANG=1 TEST_MODE=region TEST_SELECTION="1,1 5x5" TEST_GRIM=ok bash "$root/bin/postcard-capture" region >/dev/null &
cap=$!
for _ in $(seq 1 50); do [ -s "$TEST_LOG.slurp" ] && break; sleep 0.05; done
kill -TERM "$cap"; wait "$cap" 2>/dev/null || true
sleep 0.2
! kill -0 "$(cat "$TEST_LOG.slurp")" 2>/dev/null || fail "a killed capture left the picker running"
freeze_gone || fail "a killed capture left the screen frozen"
cursor_restored || fail "a killed capture left the cursor setting changed: $(cat "$TEST_LOG")"
echo "capture: every mode, cancel, grim failure, same-second shots, cleanup, freeze, cursor, last region and a killed pick OK"

