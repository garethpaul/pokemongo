#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VALIDATOR="$ROOT_DIR/scripts/check-tutorial-assets.rb"
TMP_DIR=$(mktemp -d "$ROOT_DIR/../pokemongo-asset-tests.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

if ! baseline_output=$("$VALIDATOR" 2>&1); then
  printf '%s\n' "Tutorial asset baseline must pass before corruption mutations run." >&2
  printf '%s\n' "$baseline_output" >&2
  exit 1
fi

write_tiny_unitypackage() {
  ruby - "$1" <<'RUBY'
require 'stringio'
require 'zlib'

path = ARGV.fetch(0)

def write_tar_string(payload, offset, length, value)
  payload[offset, length] = value + ("\0" * (length - value.bytesize))
end

def write_tar_octal(payload, offset, length, value)
  payload[offset, length] = format("%0#{length - 1}o\0", value)
end

def refresh_tar_checksum(payload)
  payload[148, 8] = ' ' * 8
  payload[148, 8] = format("%06o\0 ", payload.byteslice(0, 512).bytes.sum)
end

body = 'payload'
header = "\0".b * 512
write_tar_string(header, 0, 100, './asset')
write_tar_octal(header, 100, 8, 0o644)
write_tar_octal(header, 108, 8, 0)
write_tar_octal(header, 116, 8, 0)
write_tar_octal(header, 124, 12, body.bytesize)
write_tar_octal(header, 136, 12, 0)
header[156, 1] = '0'
write_tar_string(header, 257, 6, 'ustar')
write_tar_string(header, 263, 2, '00')
refresh_tar_checksum(header)
payload = header + body + ("\0".b * ((512 - (body.bytesize % 512)) % 512)) + ("\0".b * 1024)
output = StringIO.new(''.b)
gzip = Zlib::GzipWriter.new(output)
gzip.write(payload)
gzip.close
File.binwrite(path, output.string)
RUBY
}

assert_rejected() {
  name=$1
  relative_path=$2
  expected=$3
  mutation=${4:-replace}
  case_dir="$TMP_DIR/$name"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
  write_tiny_unitypackage "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
  target="$case_dir/$relative_path"
  case "$mutation" in
    replace)
      rm "$target"
      printf '%s\n' 'corrupt tutorial asset' > "$target"
      ;;
    corrupt-png|truncate-png|append-png|truncate-jpeg|blender-pointer|blender-endian|blender-version-shape|blender-version|truncate-blender|fbx-header-version|fbx-footer-version|fbx-footer-padding|truncate-fbx|strip-fbx-footer|append-fbx|truncate-gzip|corrupt-gzip-crc|corrupt-gzip-size|append-gzip|corrupt-tar-checksum|malformed-tar-size|oversized-tar-member|corrupt-tar-padding|missing-tar-terminator|tar-traversal|tar-absolute|tar-symlink|trigger-signature)
      cp "$target" "$target.copy"
      mv "$target.copy" "$target"
      ruby - "$target" "$mutation" <<'RUBY'
require 'stringio'
require 'zlib'

path = ARGV.fetch(0)
mutation = ARGV.fetch(1)
data = File.binread(path)

def gzip_data(payload)
  output = StringIO.new(''.b)
  gzip = Zlib::GzipWriter.new(output)
  gzip.write(payload)
  gzip.close
  output.string
end

def write_tar_octal(payload, offset, length, value)
  payload[offset, length] = format("%0#{length - 1}o\0", value)
end

def refresh_tar_checksum(payload)
  payload[148, 8] = ' ' * 8
  payload[148, 8] = format("%06o\0 ", payload.byteslice(0, 512).bytes.sum)
end

def write_tar_string(payload, offset, length, value)
  raise 'tar field too long' if value.bytesize > length

  payload[offset, length] = value + ("\0" * (length - value.bytesize))
end

def tar_header(name:, typeflag: '0', size: 0, linkname: '')
  header = "\0".b * 512
  write_tar_string(header, 0, 100, name)
  write_tar_octal(header, 100, 8, 0o644)
  write_tar_octal(header, 108, 8, 0)
  write_tar_octal(header, 116, 8, 0)
  write_tar_octal(header, 124, 12, size)
  write_tar_octal(header, 136, 12, 0)
  header[148, 8] = ' ' * 8
  header[156, 1] = typeflag
  write_tar_string(header, 157, 100, linkname)
  write_tar_string(header, 257, 6, 'ustar')
  write_tar_string(header, 263, 2, '00')
  refresh_tar_checksum(header)
  header
end

def tiny_tar(name: './asset', body: 'payload', typeflag: '0', linkname: '')
  payload = ''.b
  payload << tar_header(name: name, typeflag: typeflag, size: body.bytesize, linkname: linkname)
  payload << body
  payload << ("\0".b * ((512 - (body.bytesize % 512)) % 512))
  payload << ("\0".b * 1024)
  payload
end

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
when 'blender-pointer'
  data.setbyte(7, 'x'.ord)
when 'blender-endian'
  data.setbyte(8, 'x'.ord)
when 'blender-version-shape'
  data[9, 3] = '2x2'
when 'blender-version'
  data[9, 3] = '999'
when 'truncate-blender'
  data = data.byteslice(0, 11)
when 'fbx-header-version'
  data[23, 4] = [9999].pack('V')
when 'fbx-footer-version'
  data[-140, 4] = [9999].pack('V')
when 'fbx-footer-padding'
  data.setbyte(data.bytesize - 136, 1)
when 'truncate-fbx'
  data = data.byteslice(0, 100)
when 'strip-fbx-footer'
  data = data.byteslice(0, data.bytesize - 16)
when 'append-fbx'
  data << 'trailing bytes'
when 'truncate-gzip'
  data = data.byteslice(0, data.bytesize - 8)
when 'corrupt-gzip-crc'
  data.setbyte(data.bytesize - 8, data.getbyte(data.bytesize - 8) ^ 0x01)
when 'corrupt-gzip-size'
  data.setbyte(data.bytesize - 1, data.getbyte(data.bytesize - 1) ^ 0x01)
when 'append-gzip'
  data << 'trailing bytes'
when 'corrupt-tar-checksum'
  payload = tiny_tar
  payload.setbyte(0, payload.getbyte(0) ^ 0x01)
  data = gzip_data(payload)
when 'malformed-tar-size'
  payload = tiny_tar
  payload[124, 12] = "xxxxxxxxxxx\0"
  refresh_tar_checksum(payload)
  data = gzip_data(payload)
when 'oversized-tar-member'
  payload = tiny_tar
  write_tar_octal(payload, 124, 12, 4096)
  refresh_tar_checksum(payload)
  data = gzip_data(payload)
when 'corrupt-tar-padding'
  payload = tiny_tar(body: 'x')
  payload.setbyte(513, 1)
  data = gzip_data(payload)
when 'missing-tar-terminator'
  payload = tiny_tar.byteslice(0, 1024)
  data = gzip_data(payload)
when 'tar-traversal'
  data = gzip_data(tiny_tar(name: '../evil'))
when 'tar-absolute'
  data = gzip_data(tiny_tar(name: '/tmp/evil'))
when 'tar-symlink'
  data = gzip_data(tiny_tar(name: './link', body: ''.b, typeflag: '2', linkname: './target'))
when 'trigger-signature'
  data.sub!(/OnTriggerEnter\s*\(\s*Collider\s+\w+\s*\)/, 'OnTriggerEnter()')
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

assert_truncated_tga() {
  relative_path=$1
  case_dir="$TMP_DIR/TGA-payload"

  cp -al "$ROOT_DIR/." "$case_dir"
  rm "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
  write_tiny_unitypackage "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
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
  rm "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
  write_tiny_unitypackage "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
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
  rm "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
  write_tiny_unitypackage "$case_dir/004_slippy_maps/PokemonMap.unitypackage"
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

assert_rejected "PNG" "screenshots/001/001.png" "must have a valid PNG signature"
assert_rejected "JPEG" "screenshots/004/001.jpg" "must have a valid JPEG signature"
assert_rejected "PNG-CRC" "screenshots/001/001.png" "must have valid PNG chunk CRCs" "corrupt-png"
assert_rejected "PNG-IEND" "screenshots/001/002.png" "must end with exactly one PNG IEND chunk" "truncate-png"
assert_rejected "PNG-trailing" "screenshots/002/001.png" "must end with exactly one PNG IEND chunk" "append-png"
assert_rejected "JPEG-EOI" "screenshots/004/001.jpg" "must end with a JPEG end-of-image marker" "truncate-jpeg"
assert_rejected "Blender" "002_characters/Pikachu.blend" "must have a valid Blender signature"
assert_rejected "Blender-pointer" "002_characters/Pikachu.blend" "must have a valid Blender pointer-width marker" "blender-pointer"
assert_rejected "Blender-endian" "002_characters/Pikachu.blend" "must have a valid Blender endianness marker" "blender-endian"
assert_rejected "Blender-version-shape" "002_characters/Pikachu.blend" "must have a three-digit Blender version" "blender-version-shape"
assert_rejected "Blender-version" "002_characters/Pikachu.blend" "must retain Blender version 272" "blender-version"
assert_rejected "Blender-truncated" "002_characters/Pikachu.blend" "must have a complete 12-byte Blender header" "truncate-blender"
assert_rejected "FBX-header-version" "001_collisions/Assets/Objects/Pikachu.FBX" "must retain binary FBX version 7300" "fbx-header-version"
assert_rejected "FBX-footer-version" "001_collisions/Assets/Objects/Pikachu.FBX" "must have matching binary FBX header and footer versions" "fbx-footer-version"
assert_rejected "FBX-footer-padding" "001_collisions/Assets/Objects/pokeball2.fbx" "must have zeroed binary FBX footer padding" "fbx-footer-padding"
assert_rejected "FBX-truncated" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a complete binary FBX container" "truncate-fbx"
assert_rejected "FBX-footer-missing" "001_collisions/Assets/Objects/Pikachu.FBX" "must end with the binary FBX footer magic" "strip-fbx-footer"
assert_rejected "FBX-trailing" "001_collisions/Assets/Objects/pokeball2.fbx" "must end with the binary FBX footer magic" "append-fbx"
assert_rejected "gzip" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip signature"
assert_rejected "gzip-truncated" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip container" "truncate-gzip"
assert_rejected "gzip-CRC" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip container" "corrupt-gzip-crc"
assert_rejected "gzip-size" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip container" "corrupt-gzip-size"
assert_rejected "gzip-trailing" "004_slippy_maps/PokemonMap.unitypackage" "must not contain trailing bytes after the gzip stream" "append-gzip"
assert_rejected "tar-checksum" "004_slippy_maps/PokemonMap.unitypackage" "must contain a valid tar archive" "corrupt-tar-checksum"
assert_rejected "tar-size" "004_slippy_maps/PokemonMap.unitypackage" "must contain a valid tar archive" "malformed-tar-size"
assert_rejected "tar-payload" "004_slippy_maps/PokemonMap.unitypackage" "must contain a valid tar archive" "oversized-tar-member"
assert_rejected "tar-padding" "004_slippy_maps/PokemonMap.unitypackage" "must contain a valid tar archive" "corrupt-tar-padding"
assert_rejected "tar-terminator" "004_slippy_maps/PokemonMap.unitypackage" "must contain a valid tar archive" "missing-tar-terminator"
assert_rejected "tar-traversal" "004_slippy_maps/PokemonMap.unitypackage" "must contain safe relative tar paths" "tar-traversal"
assert_rejected "tar-absolute" "004_slippy_maps/PokemonMap.unitypackage" "must contain safe relative tar paths" "tar-absolute"
assert_rejected "tar-symlink" "004_slippy_maps/PokemonMap.unitypackage" "must not contain tar links or special entries" "tar-symlink"
assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"
assert_rejected "trigger-signature" "001_collisions/Assets/Scripts/HitObject.cs" "must use the supported OnTriggerEnter(Collider other) callback signature" "trigger-signature"
assert_rejected "TGA-header" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" "must have a valid uncompressed true-color TGA header"
assert_short_tga_header "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga"
assert_tga_header_byte_rejected "TGA-color-map" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 1 1
assert_tga_header_byte_rejected "TGA-image-type" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 2 10
assert_tga_header_byte_rejected "TGA-zero-width" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 13 0
assert_tga_header_byte_rejected "TGA-pixel-depth" "001_collisions/Assets/Objects/Pikachu.fbm/PikachuDh.tga" 16 16
assert_truncated_tga "001_collisions/Assets/Objects/Pikachu.fbm/PikachuEyeDh.tga"

printf '%s\n' "Tutorial asset integrity mutation tests passed."
