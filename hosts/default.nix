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
            stylix.homeManagerIntegration = {
              autoImport = false;
              followSystem = false;
            };
            home-manager = {
              backupFileExtension = "bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ../users/${user};
              sharedModules = builtins.attrValues flake.homeModules ++ [ ./${host}/hostspec.nix ];
              extraSpecialArgs = {
                inherit self;
              };
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
