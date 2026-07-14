#! /usr/bin/env bash
#
# devenv wrapper: if invoked with a single argument that exactly names a
# dev-shell template under $dot/dev-shells/languages (matched recursively and
# containing a devenv.nix), copy that template's devenv.nix / devenv.yaml /
# flake.nix into the current directory. Otherwise, forward all arguments to the
# real `devenv` binary.

set -euo pipefail

dot="${dot:-$HOME/.dotfiles}"
languages_dir="$dot/dev-shells/languages"

# Not exactly one argument -> passthrough.
if [ "$#" -ne 1 ]; then
    exec devenv "$@"
fi

name="$1"

# Recursively find a directory whose basename matches $name exactly and which
# contains a devenv.nix.
match=""
while IFS= read -r -d '' nixfile; do
    dir="$(dirname "$nixfile")"
    if [ "$(basename "$dir")" = "$name" ]; then
        match="$dir"
        break
    fi
done < <(find "$languages_dir" -type f -name devenv.nix -print0 2>/dev/null)

# No template matched -> passthrough to real devenv.
if [ -z "$match" ]; then
    exec devenv "$@"
fi

# Copy the template files into the current directory (skip any that are absent).
for file in devenv.nix devenv.yaml flake.nix; do
    if [ -f "$match/$file" ]; then
        cp "$match/$file" "./$file"
        echo "copied $file"
    fi
done

echo "dev-shell '$name' initialized in $PWD"
