{ config, lib, pkgs, ... }:

{
  # opencode.json is the base; the MCP command is injected with a pinned store path
  # (nixpkgs mcp-nixos, binary-cached) instead of `nix run github:...`, which re-fetches
  # and evaluates the flake on each start and blows opencode's 30 s MCP startup timeout.
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON (
    lib.recursiveUpdate (lib.importJSON ./opencode.json) {
      mcp.NixosMCP.command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
    }
  );
}
