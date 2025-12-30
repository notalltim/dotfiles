{
  inputs,
  withSystem,
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib) foldl' recursiveUpdate fileset;
  inherit (fileset) toSource unions;
  # Make the build more reproducible perhaps there is a better way
  flakeSource = toSource {
    root = ../.;
    fileset = unions [
      ../default.nix
      ../flake.nix
      ../flake.lock
      ../overlays
      ../pkgs
      ../config/default.nix
      ../modules/default.nix
      ../hosts/default.nix
      ../users/default.nix
    ];
  };

  flake = config.flake;

  mkNixOSHost = host: extraModules: {
    ${host} = withSystem "x86_64-linux" (
      { system, pkgs, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = builtins.attrValues flake.nixosModules ++ extraModules;
        specialArgs = { inherit self host flakeSource; };
      }
    );
  };
  mkHomeManagerHost = user: host: {
    "${user}@${host}" = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = (builtins.attrValues config.flake.homeModules);
        extraSpecialArgs = {
          inherit
            self
            host
            user
            flakeSource
            ;
        };
      }
    );
  };
  moduleOutput = host: {
    homeModules.${host} = ./${host}/host.nix;
    nixosModules.${host} = ./${host};
  };
  moduleOutputs =
    hosts:
    foldl' (acc: host: recursiveUpdate acc (moduleOutput host)) {
      nixosModules.piezo = ./piezo/host.nix;
      homeModules.piezo = ./piezo/host.nix;
    } hosts;
in
{
  flake = {
    nixosConfigurations =
      (mkNixOSHost "corona" [
        ./corona/hardware.nix
      ])
      // (mkNixOSHost "piezo" [ ./piezo ])
      // (mkNixOSHost "aurora" [ ./aurora/hardware.nix ]);

    homeConfigurations = mkHomeManagerHost "tgallion" "corona";
  }
  // moduleOutputs [
    "corona"
    "aurora"
  ];
}
