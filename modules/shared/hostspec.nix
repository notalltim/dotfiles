{
  lib,
  options,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    mkMerge
    map
    attrNames
    ;
  inherit (lib.types)
    str
    enum
    attrsOf
    submodule
    nullOr
    path
    listOf
    ;
  hostType = submodule (
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = str;
          default = name;
        };
        hostname = mkOption {
          type = str;
          default = name;
          description = ''
            hostname of the host is used for networking
          '';
        };
        platform = mkOption {
          type = enum [
            "nixos"
            "hm"
          ];
        };
        desktopEnvironment = mkOption {
          type = enum [
            "gnome"
            "hyprland"
          ];
        };
        hostPubkey = mkOption {
          type = nullOr options.age.rekey.hostPubkey.type;
          default = null;
        };

        defaultIdentity = mkOption {
          type = path;
          default = ./identities/yubikey-3314879-piv.pub;
        };

        users = mkOption {
          type = attrsOf options.baseline.user.type;
          default = config.baseline.users;
        };
      };
      config = {
        users = config.baseline.users;
      };
    }
  );
in
{
  options.baseline = {
    hosts = mkOption {
      type = attrsOf hostType;
      default = { };
    };
    host = mkOption {
      type = hostType;
    };
    hostNames = mkOption {
      type = listOf str;
      default = [ ];
    };
  };
}
