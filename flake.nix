{
  description = "Main NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };

    samaritan-sddm-src = {
      url = "github:omerwk/samaritan-sddm-theme";
      flake = false;
    };

    # GRUB themes (T4 System Bay used in nixos/configuration.nix).
    sidonia-src = {
      url = "github:Aleph1-9012/Sidonia";
      flake = false;
    };

    ambxst = {
      # url = "git+file:///home/rafael/Ambxst-fork";
      url = "github:Axenide/Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, spicetify-nix, ambxst, ... }@inputs:
    let
      system = "x86_64-linux";

      # matugen output outside git (needs --impure); missing = themes keep their red.
      bootColorsFile = /home/rafael/.cache/matugen/boot-colors.nix;
      bootPrimary =
        if builtins.pathExists bootColorsFile then (import bootColorsFile).primary else null;

      overlays = [
        (final: prev: {
          sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation {
            pname = "sf-mono-liga-bin";
            version = "dev";
            src = inputs.sf-mono-liga-src;
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              install -Dm444 -t $out/share/fonts/opentype $src/*.otf
            '';
          };

          # SDDM theme. utils/SystemInfo.js is a symlink to a file written at boot
          # by the samaritan-sysinfo service (nixos/configuration.nix).
          samaritan-sddm-theme = prev.stdenvNoCC.mkDerivation {
            pname = "samaritan-sddm-theme";
            version = "dev";
            src = inputs.samaritan-sddm-src;
            dontConfigure = true;
            dontBuild = true;
            dontCheckForBrokenSymlinks = true; # SystemInfo.js target only exists at runtime
            installPhase = ''
              mkdir -p $out/share/sddm/themes
              cp -r . $out/share/sddm/themes/samaritan
              install -Dm444 -t $out/share/fonts/truetype assets/fonts/*.ttf
              ln -sf /run/samaritan-sysinfo.js $out/share/sddm/themes/samaritan/utils/SystemInfo.js
            '' + prev.lib.optionalString (bootPrimary != null) ''
              # SDDM reads <ConfigFile>.user on top of the preset: matugen primary triangle.
              printf '[General]\ntriangleColor="%s"\n' '${bootPrimary}' \
                > $out/share/sddm/themes/samaritan/presets/dark.conf.user
            '';
          };

          # GRUB theme Sidonia T4 1080p, red accent (#D51F1D / #FF0000) replaced by the
          # matugen primary in theme.txt and all PNGs. Original colours if no matugen file.
          sidonia-t4-theme = prev.stdenvNoCC.mkDerivation {
            pname = "sidonia-t4-theme";
            version = "dev";
            src = "${inputs.sidonia-src}/themes/T4/1080p";
            nativeBuildInputs = [ (prev.python3.withPackages (p: [ p.pillow ])) ];
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              cp -r . $out
              chmod -R u+w $out
            '' + prev.lib.optionalString (bootPrimary != null) ''
              python3 -I ${./nixos/sidonia-recolor.py} $out '${bootPrimary}'
              sed -i -e 's/#D51F1D/${bootPrimary}/gI' -e 's/#FF0000/${bootPrimary}/gI' $out/theme.txt
            '';
          };
        })
      ];

      # Shared by both configs: makes the overlay visible to their own pkgs instance.
      overlayModule = { nixpkgs.overlays = overlays; };
    in
    {
      nixosConfigurations.BloodAndTears = nixpkgs.lib.nixosSystem {
        # Platform comes from nixpkgs.hostPlatform (hardware-configuration.nix).
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          ambxst.nixosModules.default
          overlayModule
        ];
      };

      # Home Manager re-imports nixpkgs with the module's nixpkgs.{config,overlays}
      # anyway, so the cached legacyPackages set is enough as the base (no extra
      # `import nixpkgs` at eval time). allowUnfree lives in home/home.nix.
      homeConfigurations.rafael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home/home.nix
          spicetify-nix.homeManagerModules.spicetify
          overlayModule
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
