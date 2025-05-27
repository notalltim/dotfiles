{
  inputs,
  withSystem,
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib) cartesianProduct foldl';
  mkHome = user: host: {
    "${user}@${host}" = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          (builtins.attrValues config.flake.homeModules)
          ++ [ ../hosts/${host}/hostspec.nix ]
          ++ [ ./${user} ];
        extraSpecialArgs = {
          inherit self;
        };
      }
    );
  };
  mkHomes =
    hosts: users:
    (foldl' (acc: el: acc // (mkHome el.user el.host))) { } (cartesianProduct {
      user = users;
      host = hosts;
    });
in
{
  flake = {
    homeConfigurations = mkHomes [ "corona" ] [ "tgallion" ];
  };
  perSystem =
    { ... }:
    {
      agenix-rekey.homeConfigurations = self.homeConfigurations;
    };
}
