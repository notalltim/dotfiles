{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Manage user level configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Unified styling
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.follows = "nur";
      };
    };
    # Nix driven neovim config
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    # End of the deps that require using the same release of nixpkgs

    # Lots of stuff but firefox addons for now
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # Styling for spofity
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Non-nixos GPU support
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Index of nixpkgs
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarativce disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware specific modules
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # Configure flakes throug modules
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    # Formatters
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # Secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    age-secret-nvim = {
      url = "github:notalltim/age-secret.nvim/develop";
      flake = false;
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        imports = with inputs; [
          home-manager.flakeModules.default
          treefmt-nix.flakeModule
          agenix-rekey.flakeModule
          ./config
          ./modules
          ./users
          ./overlays
          ./pkgs
          ./hosts
        ];

        systems = [
          # systems for which you want to build the `perSystem` attributes
          "x86_64-linux"
          # ...
        ];
        perSystem =
          { pkgs, ... }:
          {
            treefmt.programs = {
              nixf-diagnose = {
                enable = true;
                variableLookup = true;
              };
              nixfmt = {
                enable = true;
                strict = true;
              };
            };
            devShells.default = pkgs.mkShell { inputsFrom = [ pkgs.hello ]; };
          };
      }
    );
}
