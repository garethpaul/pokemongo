#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ATTACKER_ROOT=/tmp/pokemongo-attacker-root
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/Pokemongo's [gate] XXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM

CHECKOUT="$TEMP_ROOT/exact \`touch pwned\` head"
mkdir -p "$CHECKOUT/scripts"
CHECKOUT=$(CDPATH= cd -- "$CHECKOUT" && pwd -P)
cp "$ROOT_DIR/Makefile" "$CHECKOUT/Makefile"
cat >"$CHECKOUT/scripts/check-tutorial-assets.rb" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$CHECKOUT/scripts/check-tutorial-assets.rb"

assert_plan() {
  scenario=$1
  target=$2
  output=$3
  printf '%s' "$output" | grep -Fq '$REPO_ROOT' || {
    printf '%s\n' "$scenario $target embedded the repository path instead of using the environment" >&2
    exit 1
  }
  if printf '%s' "$output" | grep -Fq "$CHECKOUT"; then
    printf '%s\n' "$scenario $target exposed a shell-active checkout path" >&2
    exit 1
  fi
  if printf '%s' "$output" | grep -Fq "$ATTACKER_ROOT"; then
    printf '%s\n' "$scenario $target accepted attacker root" >&2
    exit 1
  fi
}

for target in build check compile lint root-test test verify; do
  output=$(make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" "$target" 2>&1)
  assert_plan default "$target" "$output"
  output=$(make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" "REPO_ROOT=$ATTACKER_ROOT" "$target" 2>&1)
  assert_plan command-override "$target" "$output"
  output=$(REPO_ROOT=$ATTACKER_ROOT make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" "$target" 2>&1)
  assert_plan environment-override "$target" "$output"
done

cat >"$TEMP_ROOT/print-root.mk" <<'EOF'
print-root:
	@printf '%s\n' "$$REPO_ROOT"
EOF
reported_root=$(make --no-print-directory --file "$CHECKOUT/Makefile" --file "$TEMP_ROOT/print-root.mk" print-root)
if [ "$reported_root" != "$CHECKOUT" ]; then
  printf '%s\n' "Makefile reported the wrong repository root: $reported_root" >&2
  exit 1
fi

(cd "$TEMP_ROOT" && make --no-print-directory --file "$CHECKOUT/Makefile" lint)
if [ -e "$TEMP_ROOT/pwned" ]; then
  printf '%s\n' "shell-active checkout path executed during lint" >&2
  exit 1
fi

(cd "$TEMP_ROOT" && make --no-print-directory --file "$CHECKOUT/Makefile" 'DOTNET=`touch dotnet-pwned`' compile)
(cd "$TEMP_ROOT" && DOTNET='`touch dotnet-pwned`' make --environment-overrides --no-print-directory --file "$CHECKOUT/Makefile" compile)
if [ -e "$TEMP_ROOT/dotnet-pwned" ]; then
  printf '%s\n' "caller-controlled DOTNET executed as shell source" >&2
  exit 1
fi

if make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" MAKEFILE_LIST=/tmp/untrusted check >"$TEMP_ROOT/command.out" 2>&1; then
  printf '%s\n' "command MAKEFILE_LIST override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/command.out"

if MAKEFILE_LIST=/tmp/untrusted make --environment-overrides --no-print-directory --dry-run --file "$CHECKOUT/Makefile" check >"$TEMP_ROOT/environment.out" 2>&1; then
  printf '%s\n' "environment MAKEFILE_LIST override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/environment.out"

printf '%s\n' 'PRELOADED := yes' >"$TEMP_ROOT/preload.mk"
if make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" "MAKEFILES=$TEMP_ROOT/preload.mk" check >"$TEMP_ROOT/makefiles-command.out" 2>&1; then
  printf '%s\n' "command MAKEFILES override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILES must not be set" "$TEMP_ROOT/makefiles-command.out"

if MAKEFILES="$TEMP_ROOT/preload.mk" make --no-print-directory --dry-run --file "$CHECKOUT/Makefile" check >"$TEMP_ROOT/makefiles-environment.out" 2>&1; then
  printf '%s\n' "environment MAKEFILES override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILES must not be set" "$TEMP_ROOT/makefiles-environment.out"

cat >"$TEMP_ROOT/attacker-shell" <<EOF
#!/bin/sh
touch "$TEMP_ROOT/shell-pwned"
exec /bin/sh "\$@"
EOF
chmod +x "$TEMP_ROOT/attacker-shell"
make --no-print-directory --file "$CHECKOUT/Makefile" "SHELL=$TEMP_ROOT/attacker-shell" lint
SHELL="$TEMP_ROOT/attacker-shell" make --environment-overrides --no-print-directory --file "$CHECKOUT/Makefile" lint
if [ -e "$TEMP_ROOT/shell-pwned" ]; then
  printf '%s\n' "caller-controlled SHELL executed" >&2
  exit 1
fi

printf '%s\n' "Makefile root tests passed: root and tool overrides are data, shell-active paths are inert, and Make control variables fail closed"
