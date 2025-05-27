{
  inputs,
  withSystem,
  config,
  self,
  lib,
  ...
}:
let
  flake = config.flake;
  mkHost = host: user: {
    ${host} = withSystem "x86_64-linux" (
      {
        system,
        pkgs,
        ...
      }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = builtins.attrValues flake.nixosModules ++ [
          ../users/${user}/userspec.nix
          ./${host}
          inputs.nixos-hardware.nixosModules.dell-xps-15-9570
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ../users/${user};
            home-manager.sharedModules = builtins.attrValues flake.homeModules ++ [ ./${host}/hostspec.nix ];
            home-manager.extraSpecialArgs = {
              inherit self;
            };
          }
        ];
      }
    );
  };
in
{
  flake = {
    # nixosConfigurations."piezo" = withSystem "x86_64-linux" (
    #   { system, ... }:
    #   inputs.nixpkgs.lib.nixosSystem {
    #     inherit system;
    #     modules = builtins.attrValues config.flake.nixosModules ++ [ ./piezo ];
    #   }
    # );
    nixosConfigurations = mkHost "corona" "tgallion";
  };
}
