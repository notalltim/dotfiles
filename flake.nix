{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixgl,
    fenix,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [nixgl.overlays.default fenix.overlays.default];
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-25.9.0"
        ];
        allowUnsupportedSystem = true;
        experimental-features = "nix-command flakes";
      };
    };
    lib = import ./lib.nix {inherit pkgs;};
  in {
    homeConfigurations.tgallion = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./home/tgallion.nix nixvim.homeManagerModules.nixvim];
      extraSpecialArgs = {
        inherit inputs;
        inherit (lib) writeNixGLWrapper;
      };
    };

    legacyPackages.${system} = pkgs;
    homeManagerMangerModules = import ./home;
  };
}
