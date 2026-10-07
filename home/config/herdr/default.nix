{ config, lib, pkgs, ... }:

let
  # HM's programs.herdr.settings writes config.toml as a read-only store symlink,
  # which matugen cannot rewrite. Herdr has no include/import directive either, so
  # the live config is a concatenation:
  #   ~/.config/herdr/base.toml            (this file, HM-owned, static settings)
  # + ~/.cache/matugen/herdr-theme.toml    (matugen, [theme] + [theme.custom])
  # = ~/.config/herdr/config.toml          (mutable, written by matugen's post_hook
  #                                         and by the activation script below)
  # programs.herdr.settings is left empty so the module only installs the package.
  settings = {
    onboarding = false;

    keys = {
      prefix = "alt+j";
      switch_tab = "prefix+1..9";
      switch_workspace = "prefix+shift+1..9";

      command = [
        {
          command = "lazygit";
          key = "prefix+alt+g";
          type = "popup";
          description = "run lazygit";
          width = "80%";
          height = "80%";
        }
      ];
    };

    terminal = {
      default_shell = "fish";
    };

    ui = {
      status_indicators = "symbols";
      toast.delivery = "system";
    };
  };

  baseToml = (pkgs.formats.toml { }).generate "herdr-base.toml" settings;
in
{
  programs.herdr.enable = true;

  xdg.configFile."herdr/base.toml".source = baseToml;

  # Rebuild the spliced config on every activation, so a `hms` without a matugen
  # run still picks up base.toml changes. Missing theme fragment = base only.
  home.activation.herdrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    theme="$HOME/.cache/matugen/herdr-theme.toml"
    out="$HOME/.config/herdr/config.toml"
    if [ -v DRY_RUN_CMD ] && [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would splice ${baseToml} + $theme -> $out"
    else
      mkdir -p "$HOME/.config/herdr"
      cat ${baseToml} > "$out.new"
      if [ -f "$theme" ]; then cat "$theme" >> "$out.new"; fi
      mv -f "$out.new" "$out"
      ${lib.getExe pkgs.herdr} server reload-config || true
    fi
  '';
}
