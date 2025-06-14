{
  inputs,
  withSystem,
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib) foldl' recursiveUpdate;

  flake = config.flake;

  mkNixOSHost = host: extraModules: {
    ${host} = withSystem "x86_64-linux" (
      { system, pkgs, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = builtins.attrValues flake.nixosModules ++ extraModules;
        specialArgs = { inherit self host; };
      }
    );
  };
  mkHomeManagerHost = user: host: {
    "${user}@${host}" = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = (builtins.attrValues config.flake.homeModules) ++ [
          (
            { config, ... }:
            {
              baseline.host = config.baseline.hosts.${host};
              baseline.user = config.baseline.host.users.${user};
            }
          )
        ];
        extraSpecialArgs = {
          inherit self;
        };
      }
    );
  };
  moduleOutput = host: {
    homeModules.${host} = ./${host}/host.nix;
    nixosModules.${host} = ./${host};
  };
  moduleOutputs = hosts: foldl' (acc: host: recursiveUpdate acc (moduleOutput host)) { } hosts;
in
{
  flake =
    {
      nixosConfigurations = mkNixOSHost "corona" [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9570-nvidia
      ];
      homeManagerConfigurations = mkHomeManagerHost "tgallion" "corona";
    }
    // moduleOutputs [
      "corona"
      "aurora"
    ];
}
