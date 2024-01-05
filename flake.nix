{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
      # Values you should modify
      username = "tgallion"; # $USER
      system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      stateVersion = "23.11";     # See https://nixos.org/manual/nixpkgs/stable for most recent

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlays.default ];
        config = {
          allowUnfree = true;
        };
      };

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      home = (import ./home.nix {
        inherit homeDirectory pkgs stateVersion system username;
      });

    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          home
        ];
      };
      # Disabled for now not used yet
      # systemConfigs.default = system-manager.lib.makeSystemConfig {
      #   modules = [
      #     ./system
      #   ];
      # };
    };
}
