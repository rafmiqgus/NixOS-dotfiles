# starship + direnv hooks are injected by home-manager (programs.starship / programs.direnv).
# any-nix-shell fish --info-right | source

function fish_greeting
    if not set -q PENTEST
        fastfetch
    end
end

# Start zellij only in a real Linux VT (ctrl+alt+Fn), not in a DM terminal like kitty.
# Real VTs report /dev/tty1..N; DM terminals report /dev/pts/N, so the regex excludes them.
# if status is-interactive; and string match -qr '^/dev/tty[0-9]+$' (tty)
#     set -gx TERM xterm-256color
#     if not set -q ZELLIJ
#         exec zellij attach --create main
#     end
# end

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Dir abrv
set -g dot ~/.dotfiles
set -g conf ~/.dotfiles/home/config

set -g direnv_fish_mode disable_arrow

## ------------------------------ aliases ------------------------------

# ls -> eza with preferred flags (eza module handles icons/git config; these
# aliases override the module's plain `eza` aliases to keep --group-directories-first).
# `cd` is zoxide (programs.zoxide options = --cmd cd); `cdi` for interactive.
alias ls='eza --color=always --group-directories-first --icons=always' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons=always'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons=always'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
alias l.="eza -a | grep -e '^\.'"                                     # show only dotfiles

# Flake path passed explicitly so these work even when NH_FLAKE is not in the env.
# `add -N` (intent-to-add) makes new files visible to the flake without staging their content.
alias nr='git -C /home/rafael/.dotfiles add -N . && nh os switch /home/rafael/.dotfiles'
alias hms='git -C /home/rafael/.dotfiles add -N . && nh home switch /home/rafael/.dotfiles'
alias gc='nh clean all --keep 5 --keep-since 14d'
alias holy-update='sudo ~/.dotfiles/nixos/holy-update.sh'
alias epitech='distrobox enter Epitech'
alias lock='sudo vlock -an'

# alias claude='herdr'

function nix-deep-clean
    echo "\n[*] verifying nix-store...\n"
    and sudo nix-store --verify --check-contents --repair
    and echo "\n[*] optimizing store\n"
    and sudo nix-store --optimize
    and echo "\n[*] garbage-collecting...\n"
    and nh clean all --keep 5 --keep-since 7d
end

function pentest
    set -gx PENTEST 1
    set -lx orig_dir $PWD
    set -lx iface tun0

    if set -q argv[1]
        set iface $argv[1]
    end

    sudo iptables -D nixos-fw -i $iface -j ACCEPT 2>/dev/null

    function _pentest_cleanup --on-signal SIGHUP --on-signal SIGTERM
        echo "[*] Caught signal — restoring firewall on $iface..."
        sudo iptables -D nixos-fw -i $iface -j ACCEPT 2>/dev/null
        cd $orig_dir
        set -eg PENTEST
        functions -e _pentest_cleanup
        return
    end

    if not sudo iptables -I nixos-fw -i $iface -j ACCEPT
        echo "[!] Failed to open $iface (sudo/iptables) — aborting."
        functions -e _pentest_cleanup
        set -eg PENTEST
        return 1
    end

    cd /home/rafael/.dotfiles/dev-shells/pentest
    devenv shell -- fish

    # Guard: signal path already ran cleanup and erased the function.
    if functions -q _pentest_cleanup
        echo "[*] Closing $iface..."
        sudo iptables -D nixos-fw -i $iface -j ACCEPT 2>/dev/null
        functions -e _pentest_cleanup

        cd $orig_dir
        set -eg PENTEST
    end
end

function devenv
    ~/.dotfiles/dev-shells/devenv-wrapper.sh $argv
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

# Herdr paints its own chrome but lets panes show the host terminal through, so
# kitty's background_opacity makes the terminal panes transparent. Force an
# opaque background for the duration of the session, then restore the configured
# opacity on exit. Needs dynamic_background_opacity + allow_remote_control (both
# set in kitty/default.nix). Outside kitty the wrapper is a plain passthrough.
function herdr
    if not set -q KITTY_PID
        command herdr $argv
        return $status
    end
    # kitty has no query for the current opacity, so read the configured value
    # back from the HM-generated kitty.conf.
    set -l saved (string match -rg '^background_opacity\s+(\S+)' < ~/.config/kitty/kitty.conf | tail -1)
    test -z "$saved"; and set saved 1.0
    kitten @ set-background-opacity 1.0 2>/dev/null
    command herdr $argv
    set -l herdr_status $status
    kitten @ set-background-opacity $saved 2>/dev/null
    return $herdr_status
end
