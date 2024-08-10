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
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Input sources for internal packages
    gcc-python-pretty-printers = {
      url = "github:gcc-mirror/gcc?ref=releases/gcc-13.3.0&shallow=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixgl,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [nixgl.overlays.default];
    };
  in {
    homeConfigurations.tgallion = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./home/tgallion.nix];
      extraSpecialArgs = {
        inherit self;
      };
    };

    legacyPackages.${system} = pkgs;
    gpuWrappers = nixgl.packages;
    homeManagerModules = import ./home;
    overlays = import ./overlays {
      inherit self;
      lib = nixpkgs.lib;
    };
  };
}
