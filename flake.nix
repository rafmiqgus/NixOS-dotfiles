{
  description = "Main NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.url = "github:kaylorben/nixcord";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, nixcord, spicetify-nix, sf-mono-liga-src, ... }@inputs: 
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      Overlays = [
        (final: prev: {
          sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation rec {
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
        BloodAndTears = lib.nixosSystem rec {
          inherit system;
          modules = [ 
            ./nixos/configuration.nix
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
          extraSpecialArgs = { inherit inputs; };
        };
      };
  };
}
