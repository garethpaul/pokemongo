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

assert_rejected "PNG" "screenshots/001/001.png" "must have a valid PNG signature"
assert_rejected "JPEG" "screenshots/004/001.jpg" "must have a valid JPEG signature"
assert_rejected "Blender" "002_characters/Pikachu.blend" "must have a valid Blender signature"
assert_rejected "gzip" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip signature"
assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"

printf '%s\n' "Tutorial asset signature mutation tests passed."
