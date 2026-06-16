#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DOTNET=${DOTNET:-dotnet}
BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/pokemongo-hit-object-compile.XXXXXX")

cleanup() {
    rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

"$DOTNET" build "$ROOT/tests/HitObjectCompile/HitObjectCompile.csproj" \
    --configuration Release \
    --nologo \
    --verbosity minimal \
    --property:BaseIntermediateOutputPath="$BUILD_DIR/obj/" \
    --property:BaseOutputPath="$BUILD_DIR/bin/" \
    --property:RestoreIgnoreFailedSources=true
