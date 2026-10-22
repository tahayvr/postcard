#!/usr/bin/env bash
# Runs every check: JavaScript unit tests, shell script syntax, the Qt 6
# linter, and an offscreen render of the stage.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
fail=0

echo "== JavaScript unit tests"
node "$here/run.js" || fail=1

echo "== shell scripts"
bash "$here/capture.sh" || fail=1
for f in "$root"/bin/postcard-*; do
  case "$(head -c 40 "$f")" in *bash*) bash -n "$f" || fail=1 ;; *python3*) /usr/bin/python3 -B -m py_compile "$f" && rm -rf "$root/bin/__pycache__" || fail=1 ;; esac
done
[ -n "$(bash "$root/bin/postcard-dir")" ] && echo "postcard-dir: $(bash "$root/bin/postcard-dir")" || { echo "postcard-dir printed nothing"; fail=1; }
# A long line folds at the column limit, and a folded line keeps its gutter.
folded="$(printf 'let u = "%s";\n' "$(printf 'x%.0s' $(seq 1 120))" | bash "$root/bin/postcard-highlight" rs ansi 1 60 | sed 's/\x1b\[[0-9;]*m//g')"
[ "$(printf '%s\n' "$folded" | wc -l)" -ge 3 ] && printf '%s\n' "$folded" | sed -n 2p | grep -qE '^ {5}x' \
  && echo "postcard-highlight folds long lines under the gutter" || { echo "postcard-highlight did not fold a long line"; fail=1; }

# A crop is taken from the file, so the cut has to come out the size asked for.
# Two shots on one sheet: the first cropped 1:1, the second scaled into
# place, and nothing but transparency between them.
t="$XDG_RUNTIME_DIR/postcard-test-sheet"
magick -size 200x100 gradient:red-blue -depth 8 "$t-a.png" 2>/dev/null
magick -size 100x200 xc:'#00ff00' "$t-b.png" 2>/dev/null
bash "$root/bin/postcard-sheet" "$t.png" 120 50 "$t-a.png" 20 10 50 50 50 50 0 0 \
     "$t-b.png" 0 0 100 200 25 50 95 0 >/dev/null
sheet="$(magick "$t.png" -format "%wx%h %[pixel:p{97,25}] %[fx:p{60,25}.a] %z %[channels]" info: 2>/dev/null)"
cut="$(magick compare -metric AE "$t.png[50x50+0+0]" "$t-a.png[50x50+20+10]" null: 2>&1 | cut -d' ' -f1)"
[ "$sheet" = "120x50 srgba(0,255,0,1) 0 8 srgba 4.0" ] && [ "$cut" = "0" ] \
  && echo "postcard-sheet places, crops 1:1 and leaves the gap clear" \
  || { echo "postcard-sheet produced '$sheet', crop differed by $cut"; fail=1; }
rm -f "$t.png" "$t-a.png" "$t-b.png"

# The text row under a point: two lines of dark text and one of blue, each
# found from a point on it or just beside it; a flat area and a point between
# two lines that are too far apart find nothing; the second is the nearest
# line within reach.
r="$XDG_RUNTIME_DIR/postcard-test-rows.png"
magick -size 400x300 xc:'#f4f4f4' -fill '#222' -pointsize 18 -annotate +20+60 'The quick brown fox' \
       -annotate +20+100 'jumps over the dog' -fill '#3366cc' -pointsize 14 -annotate +20+200 'small blue line' "$r" 2>/dev/null
read -r t1 b1 <<<"$(bash "$root/bin/postcard-rows" "$r" 120 55)"
read -r t2 b2 <<<"$(bash "$root/bin/postcard-rows" "$r" 120 80)"
read -r t3 b3 <<<"$(bash "$root/bin/postcard-rows" "$r" 80 196)"
flat="$(bash "$root/bin/postcard-rows" "$r" 300 260)"
if [ "${t1:-}" ] && (( t1 >= 44 && t1 <= 50 && b1 >= 62 && b1 <= 68 )) \
   && [ "${t2:-}" ] && (( t2 >= 84 && t2 <= 92 )) && [ "${t3:-}" ] && (( b3 - t3 >= 8 && b3 - t3 <= 16 )) \
   && [ -z "$flat" ]; then
  echo "postcard-rows finds the line of text under a point ($t1-$b1, $t2-$b2, $t3-$b3)"
else
  echo "postcard-rows gave '$t1 $b1' / '$t2 $b2' / '$t3 $b3' / flat '$flat'"; fail=1
fi
rm -f "$r"

# Recent cards: six recorded, five kept, newest first, the shot copied in and
# a thumbnail made; forgetting one leaves four. The directory has a space in
# it, and a folder named like the part before the space must survive the
# pruning. A card recorded again with another shot drops the copy it stopped
# using.
rd="$XDG_RUNTIME_DIR/postcard-test recent"
decoy="$XDG_RUNTIME_DIR/postcard-test"
rm -rf "$rd" "$decoy"
mkdir -p "$decoy"
magick -size 60x40 xc:'#ff00ff' "$rd-shot.png" 2>/dev/null
for i in 1 2 3 4 5 6; do
  printf '{"version":1,"id":"r%s","stamp":%s,"kind":"shot","title":"t%s","slots":[{"source":"%s/r%s/0-shot.png","w":60,"h":40}]}' \
    "$i" "$((1000 + i))" "$i" "$rd" "$i" \
    | bash "$root/bin/postcard-recent" record "$rd" "r$i" "" "$rd-shot.png" "0-shot.png" >/dev/null
  sleep 0.02
done
kept="$(bash "$root/bin/postcard-recent" list "$rd" | jq -r '[.[].id] | join(",")')"
thumb="$(magick identify -format '%wx%h' "$rd/r6/thumb.png" 2>/dev/null)"
copied="$(magick compare -metric AE "$rd/r6/0-shot.png" "$rd-shot.png" null: 2>&1 | cut -d' ' -f1)"
printf '{"version":1,"id":"r6","stamp":2000,"kind":"shot","title":"t6","slots":[]}' \
  | bash "$root/bin/postcard-recent" record "$rd" r6 "" "$rd-shot.png" "b-shot.png" >/dev/null
swapped="$(cd "$rd/r6" && ls -- *-shot.png | tr '\n' ' ')"
bash "$root/bin/postcard-recent" forget "$rd" r6 >/dev/null
left="$(bash "$root/bin/postcard-recent" list "$rd" | jq 'length')"
[ "$kept" = "r6,r5,r4,r3,r2" ] && [ "$thumb" = "60x40" ] && [ "$copied" = "0" ] && [ "$left" = "4" ] \
  && [ -d "$decoy" ] && [ "$swapped" = "b-shot.png " ] \
  && echo "postcard-recent keeps the last five, copies the shot, drops unused copies and forgets on request" \
  || { echo "postcard-recent: kept '$kept', thumb '$thumb', copy differs by '$copied', left '$left', decoy $([ -d "$decoy" ] && echo kept || echo deleted), copies '$swapped'"; fail=1; }
rm -rf "$rd" "$rd-shot.png" "$decoy"

echo "== qmllint"
lintroot="$(mktemp -d)"
ln -s "${OMARCHY_PATH:-/usr/share/omarchy}/shell" "$lintroot/qs"
# Only hard problems fail the run. The shell's singletons declare their
# members on inline QtObjects, which the linter cannot see through.
out="$(/usr/lib/qt6/bin/qmllint -I "$lintroot" -I /usr/lib/qt6/qml \
         "$root"/*.qml "$root"/ui/*.qml "$root"/ui/controls/*.qml 2>&1 \
       | grep -E "\[(duplicated-name|property-override|syntax|inheritance-cycle|unresolved-type|type-error|compiler)\]")"
rm -rf "$lintroot"
if [ -n "$out" ]; then echo "$out"; fail=1; else echo "no blocking warnings"; fi

echo "== offscreen render"
bash "$here/qml/render.sh" || fail=1

if [ $fail -eq 0 ]; then echo "ALL OK"; else echo "FAILED"; fi
exit $fail
