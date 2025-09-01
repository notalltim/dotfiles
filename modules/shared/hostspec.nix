{
  lib,
  options,
  config,
  baselineLib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    str
    enum
    attrsOf
    submodule
    nullOr
    path
    listOf
    ;
  inherit (baselineLib) mkPathReproducible;
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
        hostPath = mkOption {
          # apply = mkPathReproducible;
          type = path;
          description = ''
            root path where the host definition is  
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
            "headless"
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
          apply = mkPathReproducible;
          default = ./secrets/identities/yubikey-3314879-piv.pub;
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
