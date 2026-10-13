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
        })
      ];

      # Shared by both configs: makes the overlay visible to their own pkgs instance.
      overlayModule = { nixpkgs.overlays = overlays; };
    in
    {
      nixosConfigurations.BloodAndTears = nixpkgs.lib.nixosSystem {
        # Platform comes from nixpkgs.hostPlatform (hardware-configuration.nix).
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
