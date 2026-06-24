{
  description = "Main NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
    ambxst = {
      url = "git+file:///home/rafael/Ambxst-fork";
      # url = "github:Axenide/Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
    spotatui = {
      url = "github:LargeModGames/spotatui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, sf-mono-liga-src, ambxst, ... }@inputs: 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      Overlays = [
        (final: prev: {
          sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation {
            pname = "sf-mono-liga-bin";
            version = "dev";
            src = inputs.sf-mono-liga-src;
            dontConfigure = true;
            installPhase = ''
              mkdir -p $out/share/fonts/opentype
              cp -R $src/*.otf $out/share/fonts/opentype/
            '';
          };
        }) 
      ];
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = Overlays;
      };
      

    in {
      nixosConfigurations = {
        BloodAndTears = lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/configuration.nix
            ambxst.nixosModules.default
            { nixpkgs.overlays = Overlays; }
          ];
        };
      };

      homeConfigurations = {
        rafael = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ 
            ./home/home.nix
            spicetify-nix.homeManagerModules.spicetify
          ];
          extraSpecialArgs = { inherit inputs system; };
        };
      };
  };
}
