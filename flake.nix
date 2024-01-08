{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, system-manager, nixgl }:
    let
      home = {
        username = "tgallion";
        system = "x86_64-linux";
        stateVersion = "23.11";
        email = "timbama@gmail.com";
        signingKey = "5A2DAA31F5457F29";
      };

      work = {
        username = "tim";
        system = "x86_64-linux";
        stateVersion = "23.11";
        email = "tgallion@anduril.com";
      };

      createConfig = attrs:
        let
          system = attrs.system;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nixgl.overlays.default ];
            config = { allowUnfree = true; };
          };

          homeDirectory = "/home/${attrs.username}";

          module = with attrs;
            (import ./home.nix {
              inherit homeDirectory pkgs stateVersion system username email
                signingKey;
            });
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ module ];
        };

    in {
      homeConfigurations.${home.username} = createConfig home;
      homeConfigurations.${work.username} = createConfig work;
      # Disabled for now not used yet
      # systemConfigs.default = system-manager.lib.makeSystemConfig {
      #   modules = [
      #     ./system
      #   ];
      # };
    };
}
