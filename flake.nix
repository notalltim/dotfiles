{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: Remove this when the flake-module is availible on stable
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      flake = false;
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
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # Input sources for internal packages
    gcc-python-pretty-printers = {
      url = "github:gcc-mirror/gcc?ref=releases/gcc-13.3.0&shallow=1";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [ (import "${home-manager-unstable}/flake-module.nix") ];

      flake = {
        # Put your original flake attributes here.
        overlays = import ./overlays {
          inherit self;
          inherit (inputs.nixpkgs) lib;
        };
        homeModules = (import ./home) self;

        homeConfigurations.${"tgallion"} = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home/tgallion.nix ];
          extraSpecialArgs = {
            nonNixos = true;
            inherit self;
          };
        };
      };
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          legacyPackages = pkgs;
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
