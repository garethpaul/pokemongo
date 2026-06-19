#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VALIDATOR="$ROOT_DIR/scripts/check-tutorial-assets.rb"
TMP_DIR=$(mktemp -d "$ROOT_DIR/../pokemongo-asset-tests.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

assert_rejected() {
  name=$1
  relative_path=$2
  expected=$3
  case_dir="$TMP_DIR/$name"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/$relative_path"
  printf '%s\n' 'corrupt tutorial asset' > "$case_dir/$relative_path"

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

assert_truncated_tga() {
  relative_path=$1
  case_dir="$TMP_DIR/TGA-payload"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/$relative_path"
  dd if="$ROOT_DIR/$relative_path" of="$case_dir/$relative_path" bs=18 count=1 2>/dev/null

  if output=$(TUTORIAL_ROOT="$case_dir" "$VALIDATOR" 2>&1); then
    printf '%s\n' "Validator accepted truncated TGA pixel data." >&2
    exit 1
  fi

  if ! printf '%s\n' "$output" | grep -Fq "must contain complete TGA pixel data"; then
    printf '%s\n' "Validator rejected truncated TGA without the expected pixel-data error." >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

assert_short_tga_header() {
  relative_path=$1
  case_dir="$TMP_DIR/TGA-short-header"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/$relative_path"
  dd if="$ROOT_DIR/$relative_path" of="$case_dir/$relative_path" bs=10 count=1 2>/dev/null

  if output=$(TUTORIAL_ROOT="$case_dir" "$VALIDATOR" 2>&1); then
    printf '%s\n' "Validator accepted a short TGA header." >&2
    exit 1
  fi

  if ! printf '%s\n' "$output" | grep -Fq "must have a valid TGA header"; then
    printf '%s\n' "Validator rejected a short TGA without the expected header error." >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

assert_tga_header_byte_rejected() {
  name=$1
  relative_path=$2
  offset=$3
  value=$4
  case_dir="$TMP_DIR/$name"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/$relative_path"
  cp "$ROOT_DIR/$relative_path" "$case_dir/$relative_path"
  ruby -e 'path, offset, value = ARGV; data = File.binread(path); data.setbyte(Integer(offset), Integer(value)); File.binwrite(path, data)' \
    "$case_dir/$relative_path" "$offset" "$value"

  if output=$(TUTORIAL_ROOT="$case_dir" "$VALIDATOR" 2>&1); then
    printf '%s\n' "Validator accepted invalid $name TGA metadata." >&2
    exit 1
  fi

  if ! printf '%s\n' "$output" | grep -Fq "must have a valid uncompressed true-color TGA header"; then
    printf '%s\n' "Validator rejected invalid $name TGA metadata without the expected header error." >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

if ! baseline_output=$(TUTORIAL_ROOT="$ROOT_DIR" "$VALIDATOR" 2>&1); then
  printf '%s\n' "Tutorial asset baseline must pass before corruption mutations run." >&2
  printf '%s\n' "$baseline_output" >&2
  exit 1
fi

assert_rejected "PNG" "screenshots/001/001.png" "must have a valid PNG signature"
assert_rejected "JPEG" "screenshots/004/001.jpg" "must have a valid JPEG signature"
assert_rejected "Blender" "002_characters/Pikachu.blend" "must have a valid Blender signature"
assert_rejected "gzip" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip signature"
assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"
assert_rejected "TGA-header" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" "must have a valid uncompressed true-color TGA header"
assert_short_tga_header "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga"
assert_tga_header_byte_rejected "TGA-color-map" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 1 1
assert_tga_header_byte_rejected "TGA-image-type" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 2 10
assert_tga_header_byte_rejected "TGA-zero-width" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 13 0
assert_tga_header_byte_rejected "TGA-pixel-depth" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 16 16
assert_truncated_tga "001_collisions/Assets/Objects/Pikachu.fbm/PikachuEyeDh.tga"

printf '%s\n' "Tutorial asset signature mutation tests passed."
