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
    corrupt-png|truncate-png|append-png|truncate-jpeg|blender-pointer|blender-endian|blender-version-shape|blender-version|truncate-blender|fbx-header-version|fbx-footer-version|fbx-footer-padding|truncate-fbx|strip-fbx-footer|append-fbx|truncate-gzip|corrupt-gzip-crc|corrupt-gzip-size|append-gzip|corrupt-tar-checksum|malformed-tar-size|oversized-tar-member|corrupt-tar-padding|missing-tar-terminator|trigger-signature)
      cp "$target" "$target.copy"
      mv "$target.copy" "$target"
      ruby - "$target" "$mutation" <<'RUBY'
require 'stringio'
require 'zlib'

path = ARGV.fetch(0)
mutation = ARGV.fetch(1)
data = File.binread(path)

def gzip_payload(data)
  Zlib::GzipReader.new(StringIO.new(data)).read
end

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
  payload = gzip_payload(data)
  payload.setbyte(0, payload.getbyte(0) ^ 0x01)
  data = gzip_data(payload)
when 'malformed-tar-size'
  payload = gzip_payload(data)
  payload[124, 12] = "xxxxxxxxxxx\0"
  refresh_tar_checksum(payload)
  data = gzip_data(payload)
when 'oversized-tar-member'
  payload = gzip_payload(data)
  write_tar_octal(payload, 124, 12, payload.bytesize + 512)
  refresh_tar_checksum(payload)
  data = gzip_data(payload)
when 'corrupt-tar-padding'
  payload = gzip_payload(data)
  offset = 0
  mutated = false
  while offset + 512 <= payload.bytesize
    header = payload.byteslice(offset, 512)
    break if header == "\0".b * 512

    size = header.byteslice(124, 12).sub(/\0.*\z/m, '').strip.to_i(8)
    padding_size = (512 - (size % 512)) % 512
    if padding_size.positive?
      padding_offset = offset + 512 + size
      payload.setbyte(padding_offset, 1)
      mutated = true
      break
    end
    offset += 512 + size
  end
  raise 'tar fixture has no padded member' unless mutated
  data = gzip_data(payload)
when 'missing-tar-terminator'
  payload = gzip_payload(data)
  last_nonzero = payload.bytesize - 1
  last_nonzero -= 1 while last_nonzero >= 0 && payload.getbyte(last_nonzero).zero?
  payload = payload.byteslice(0, last_nonzero + 1)
  data = gzip_data(payload)
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
assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"
assert_rejected "trigger-signature" "001_collisions/Assets/Scripts/HitObject.cs" "must use the supported OnTriggerEnter(Collider other) callback signature" "trigger-signature"

printf '%s\n' "Tutorial asset integrity mutation tests passed."
