#!/usr/bin/env bash
# Exercise the capture handoff without a compositor or a real screenshot.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
helper="${POSTCARD_CAPTURE_HELPER:-$root/bin/postcard-capture}"
scratch="$(mktemp -d)"
trap 'rm -rf -- "$scratch"' EXIT
export XDG_RUNTIME_DIR="$scratch/runtime with spaces"
mkdir -p "$scratch/bin" "$XDG_RUNTIME_DIR/postcard-captures"
export PATH="$scratch/bin:$PATH"
# An inherited output directory must not override the per-capture directory.
export OMASNAP_SCREENSHOT_DIR="$scratch/unrelated"
cat > "$scratch/bin/omarchy" <<'MOCK'
#!/usr/bin/env bash
set -eu
[[ "$*" == "capture screenshot $TEST_CAPTURE_MODE save" ]]
[[ "$OMARCHY_SCREENSHOT_DIR" == "$OMASNAP_SCREENSHOT_DIR" ]]
case "$TEST_BACKEND" in
  cancel) exit 0 ;;
  fail) exit 1 ;;
  silent|legacy)
    printf 'image %s' "$TEST_CAPTURE_MODE" > "$OMARCHY_SCREENSHOT_DIR/shot with spaces.png"
    if [[ "$TEST_BACKEND" == legacy ]]; then
      printf 'Saved screenshot\n%s\n' "$OMARCHY_SCREENSHOT_DIR/shot with spaces.png"
    fi
    ;;
esac
MOCK
chmod +x "$scratch/bin/omarchy"
fail() { echo "FAIL $*" >&2; exit 1; }
capture() {
  TEST_BACKEND="$1" TEST_CAPTURE_MODE="$2" bash "$helper" "$2" "${@:3}"
}
dir="$XDG_RUNTIME_DIR/postcard-captures"
old="$dir/old.png"
printf previous > "$old"
for backend in cancel fail; do
  result="$(capture "$backend" fullscreen)"
  [[ -z "$result" && -f "$old" ]] || fail "$backend reused or removed an old shot"
done

# The same backend filename on consecutive captures must not overwrite shots
# still on a multi-shot card; unreferenced captures should be removed.
previous="$old"
for mode in region windows fullscreen smart; do
  shot="$(capture silent "$mode" "$previous")"
  [[ -f "$shot" && "$shot" != "$previous" ]] || fail "silent $mode returned no new shot"
  [[ "$(cat "$shot")" == "image $mode" ]] || fail "$mode returned the wrong image"
  [[ -f "$previous" ]] || fail "$mode removed a retained shot"
  [[ "${shot%/*}" == "$dir" && "${shot##*/}" != .* ]] || fail "shot is hidden or outside cleanup directory"
  previous="$shot"
done
[[ ! -f "$old" ]] || fail "unreferenced old shot was not cleaned up"

shot="$(capture legacy fullscreen "$previous")"
[[ -f "$shot" && -f "$previous" && "$shot" != "$previous" ]] || fail "legacy path output or retention failed"
result="$(capture cancel fullscreen)"
[[ -z "$result" && -f "$shot" ]] || fail "cancellation returned a previous capture"
next="$(capture silent fullscreen)"
[[ -f "$next" && ! -f "$shot" && ! -f "$previous" ]] || fail "old captures were not cleaned up"
[[ -z "$(find "$dir" -mindepth 1 -type d -print -quit)" ]] || fail "request directory leaked"
[[ ! -e "$scratch/unrelated" ]] || fail "inherited output directory was used"
echo "capture: silent and legacy backends, all modes, cancellation, failure, retention and cleanup OK"
