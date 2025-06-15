{
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib)
    mkOption
    genAttrs
    mkEnableOption
    attrNames
    mkMerge
    map
    mkIf
    filterAttrs
    mapAttrs
    elem
    hasPrefix
    any
    ;
  inherit (lib.types)
    str
    raw
    listOf
    deferredModule
    bool
    ;
  passthru = [
    "hyprland"
    "stylix"
    "ssh"
    "apps"
    "home-manager"
    "terminal"
    "tools"
    "nixvim"
    "firefox"
    "packages"
    "ulauncher"
    "waybar"
    "spotify"
  ];

in
{
  options.baseline =
    (genAttrs passthru (name: {
      enable = mkEnableOption "Enable ${name} home-manager configuration for all users";

      users = mkOption {
        type = listOf str;
        default = attrNames config.baseline.host.users;
      };
      anyEnabled = mkOption {
        readOnly = true;
        type = bool;
        default = (
          any (user: config.home-manager.users.${user}.baseline.${name}.enable) (
            attrNames config.baseline.host.users
          )
        );
      };
      root = mkEnableOption "Apply ${name} home-manager configuration for the root user";
      common = mkOption {
        description = "Common ${name} configuration for all home-manager users";
        type = raw // {
          merge = _: defs: mkMerge (map (x: x.value) defs);
        };
        default = { };
      };
    }))
    // {
      homeCommon = mkOption {
        type = deferredModule;
        default = _: { };
        description = ''
          Comon options to apply to all home-managers users. 
          Pass down the options that are on the hm side but are really set from the host e.g. network-manager applet
        '';
      };
      userCommon = mkOption {
        type = deferredModule;
        default = _: { };
        description = ''
          Common options to apply to all users. in the `users.users.*`
          Useful for extra groups for normal users
        '';

      };
    };
  config = {
    baseline.homeCommon =
      { name, ... }:
      {
        baseline = (
          filterAttrs (n: _: elem n passthru) (
            mapAttrs (
              n: v:
              mkMerge [
                { enable = mkIf (v.enable && (elem name v.users || (v.root && name == "root"))) true; }
                v.common
              ]
            ) config.baseline
          )
        );
      };
  };
}
