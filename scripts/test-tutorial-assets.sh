#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VALIDATOR="$ROOT_DIR/scripts/check-tutorial-assets.rb"
TMP_DIR=$(mktemp -d "$ROOT_DIR/../pokemongo-asset-tests.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

"$VALIDATOR" >/dev/null

assert_rejected() {
  name=$1
  relative_path=$2
  expected=$3
  mutation=${4:-replace}
  case_dir="$TMP_DIR/$name"

  cp -al "$ROOT_DIR/." "$case_dir"
  target="$case_dir/$relative_path"
  case "$mutation" in
    replace)
      rm "$target"
      printf '%s\n' 'corrupt tutorial asset' > "$target"
      ;;
    corrupt-png|truncate-png|append-png|truncate-jpeg)
      cp "$target" "$target.copy"
      mv "$target.copy" "$target"
      ruby - "$target" "$mutation" <<'RUBY'
path = ARGV.fetch(0)
mutation = ARGV.fetch(1)
data = File.binread(path)

case mutation
when 'corrupt-png'
  offset = 8
  loop do
    length = data.byteslice(offset, 4).unpack1('N')
    type = data.byteslice(offset + 4, 4)
    if type == 'IDAT'
      payload_offset = offset + 8
      data.setbyte(payload_offset, data.getbyte(payload_offset) ^ 0x01)
      break
    end
    offset += 12 + length
  end
when 'truncate-png'
  data = data.byteslice(0, data.bytesize - 12)
when 'append-png'
  data << 'trailing bytes'
when 'truncate-jpeg'
  data = data.byteslice(0, data.bytesize - 2)
end

File.binwrite(path, data)
RUBY
      ;;
  esac

  if output=$(TUTORIAL_ROOT="$case_dir" "$VALIDATOR" 2>&1); then
    printf '%s\n' "Validator accepted corrupt $name asset." >&2
    exit 1
  fi

  if ! printf '%s\n' "$output" | grep -Fq "$expected"; then
    printf '%s\n' "Validator rejected corrupt $name asset without expected error: $expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

assert_rejected "PNG" "screenshots/001/001.png" "must have a valid PNG signature"
assert_rejected "JPEG" "screenshots/004/001.jpg" "must have a valid JPEG signature"
assert_rejected "PNG-CRC" "screenshots/001/001.png" "must have valid PNG chunk CRCs" "corrupt-png"
assert_rejected "PNG-IEND" "screenshots/001/002.png" "must end with exactly one PNG IEND chunk" "truncate-png"
assert_rejected "PNG-trailing" "screenshots/002/001.png" "must end with exactly one PNG IEND chunk" "append-png"
assert_rejected "JPEG-EOI" "screenshots/004/001.jpg" "must end with a JPEG end-of-image marker" "truncate-jpeg"
assert_rejected "Blender" "002_characters/Pikachu.blend" "must have a valid Blender signature"
assert_rejected "gzip" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip signature"
assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"

printf '%s\n' "Tutorial asset integrity mutation tests passed."
