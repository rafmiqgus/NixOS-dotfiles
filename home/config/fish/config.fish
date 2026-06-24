starship init fish | source
any-nix-shell fish --info-right | source

function fish_greeting
    fastfetch
end

# Start zellij only in a real Linux VT (ctrl+alt+Fn), not in a DM terminal like kitty.
# Real VTs report /dev/tty1..N; DM terminals report /dev/pts/N, so the regex excludes them.
if status is-interactive; and string match -qr '^/dev/tty[0-9]+$' (tty)
    set -gx TERM xterm-256color
    if not set -q ZELLIJ
        exec zellij attach --create main
    end
end

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

## ------------------------------ aliases ------------------------------
#
# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons=always' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons=always'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons=always'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
alias l.="eza -a | grep -e '^\.'"                                     # show only dotfiles

alias nr='sudo nixos-rebuild switch --flake /home/rafael/.dotfiles#BloodAndTears'
alias hms='git add -A /home/rafael/.dotfiles && home-manager switch --flake /home/rafael/.dotfiles/.#rafael'
alias gc='sudo nix-collect-garbage -d'
alias holy-update='sudo ~/.dotfiles/nixos/holy-update.sh'
alias epitech='distrobox enter Epitech'
alias lock='sudo vlock -an'

function nix-deep-clean
    echo "-> verifying nix-store..."
    and sudo nix-store --verify --check-contents --repair
    and echo "-> optimizing store"
    and sudo nix-store --optimize
    and echo "-> garbage-collecting..."
    and sudo nix-collect-garbage -d
end

function pentest
    echo $PWD > /tmp/.pentest_prev_dir
    and cd /home/rafael/.dotfiles/dev-shells/pentest
    and devenv shell -- fish
    and cd --
end

## ---------------------------------------------------------------------

function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T ' $argv
end

function backup --argument filename
    cp $filename $filename.bak
end
