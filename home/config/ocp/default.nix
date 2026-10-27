{ config, lib, pkgs, inputs, ... }:

# OCP (Open Claude Proxy): Claude subscription as an OpenAI-compatible API on 127.0.0.1:3456.
# Source is the non-flake input `ocp`, run straight from the store (no npm deps). State lives in
# ~/.ocp (db, logs, keys). `ocp update` cannot work (git pull in the store): use
# `nix flake update ocp` + hms instead.

let
  ocpPath = lib.makeBinPath [
    pkgs.nodejs_24
    pkgs.claude-code
    pkgs.python3
    pkgs.git
    pkgs.curl
    pkgs.bash
    pkgs.coreutils
  ];

  # CLI wrapper: the upstream script resolves its own dir via BASH_SOURCE and shells out to
  # node (restart resolver), curl and python3.
  ocp-cli = pkgs.writeShellScriptBin "ocp" ''
    export PATH=${ocpPath}:$PATH
    exec ${pkgs.bash}/bin/bash ${inputs.ocp}/ocp "$@"
  '';
in
{
  home.packages = [ ocp-cli ];

  # Same unit name as upstream's setup.mjs, so `ocp restart` finds it.
  systemd.user.services.ocp-proxy = {
    Unit = {
      Description = "OCP (Open Claude Proxy)";
    };
    Service = {
      ExecStart = "${pkgs.nodejs_24}/bin/node ${inputs.ocp}/server.mjs";
      Environment = [
        "CLAUDE_BIND=127.0.0.1"
        "CLAUDE_PROXY_PORT=3456"
        "CLAUDE_BIN=${pkgs.claude-code}/bin/claude"
        # spawned claude processes also get the user profile, like an interactive session
        "PATH=${ocpPath}:/home/rafael/.nix-profile/bin:/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
