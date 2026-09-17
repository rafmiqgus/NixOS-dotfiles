#! /run/current-system/sw/bin/bash
#
# devenv wrapper: if invoked with a single argument that exactly names a
# dev-shell template under $dot/dev-shells/languages (matched recursively and
# containing a devenv.nix), copy that template's devenv.nix / devenv.yaml /
# flake.nix into the current directory. Otherwise, forward all arguments to the
# real `devenv` binary.
#
# This runs on every shell prompt (via the fish `devenv` function, which the
# fish_prompt devenv hook calls as `devenv hook-should-activate`), so the
# passthrough path must stay fork-free: no `find`, no subshells.

set -euo pipefail

dot="${dot:-$HOME/.dotfiles}"
languages_dir="$dot/dev-shells/languages"

# Not exactly one argument -> passthrough.
if [ "$#" -ne 1 ]; then
    exec devenv "$@"
fi

name="$1"

# A devenv subcommand is never a template name; passthrough before touching the
# filesystem. `hook-should-activate` in particular runs once per prompt.
case "$name" in
    -* | *' '* | hook | hook-should-activate | shell | init | info | up | down | \
    processes | tasks | test | container | inputs | update | search | build | \
    eval | repl | gc | version | changelogs | direnvrc | allow | revoke | mcp | \
    lsp | generate | user-config | help)
        exec devenv "$@"
        ;;
esac

# Recursively find a directory whose basename matches $name exactly and which
# contains a devenv.nix. Bash parameter expansion replaces dirname/basename so
# no process is forked per candidate.
match=""
while IFS= read -r -d '' nixfile; do
    dir="${nixfile%/*}"
    if [ "${dir##*/}" = "$name" ]; then
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
