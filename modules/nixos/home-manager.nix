{
  self,
  lib,
  config,
  pkgs,
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
      { baseline.host = config.baseline.host; }
    ];
    extraSpecialArgs = {
      inherit self;
    };
    users = genAttrs (attrNames baseline.host.users) (
      name: _: {
        baseline.user = baseline.host.users.${name};
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
