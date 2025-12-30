{
  self,
  lib,
  config,
  pkgs,
  flakeSource ? null,
  host,
  ...
}:
let
  inherit (lib)
    genAttrs
    attrValues
    attrNames
    mapAttrs
    mkMerge
    ;
  baseline = config.baseline;
in
{
  stylix.homeManagerIntegration = {
    autoImport = false;
    followSystem = false;
  };
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = attrValues self.homeModules ++ [
      baseline.homeCommon
      {
        baseline.host = config.baseline.host;
        baseline.nix.flakeSource = flakeSource;
      }
    ];
    extraSpecialArgs = {
      inherit self host flakeSource;
    };
    users = genAttrs (attrNames baseline.host.users) (
      name: _: {
        _module.args.user = name;
      }
    );
  };
  users.users = mapAttrs (
    _name: user:
    let
      userspec = user.baseline;
    in
    mkMerge [
      (_: baseline.userCommon)
      (_: userspec.userModule)
      {
        isNormalUser = true;
        description = userspec.user.fullName;
        extraGroups = [
          "wheel"
        ];
        shell = pkgs.fish;
      }
    ]
  ) (config.home-manager.users);
}
