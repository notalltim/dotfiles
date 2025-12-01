{
  lib,
  options,
  config,
  ...
}:
let
  inherit (lib) mkOption attrNames;
  inherit (lib.types)
    str
    submodule
    attrsOf
    nullOr
    path
    listOf
    deferredModule
    ;
  # User specific host agnostic options
  userComponent =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = str;
          default = name;
        };
        username = mkOption {
          type = str;
          default = name;
          description = ''
            primary user on the system
          '';
        };
        fullName = mkOption {
          type = str;
          default = name;
          description = ''
            Full name in the form "First Last";
          '';
        };

        defaultIdentity = mkOption {
          type = path;
          default = ./secrets/identities/yubikey-3314879-piv.pub;
        };
      };
    };
  # User specific host specific options
  hostComponent =
    { ... }:
    {
      options = {
        userPubkey = mkOption {
          type = nullOr options.age.rekey.hostPubkey.type;
          default = null;
          description = ''
            The user scope key to use for rekey
          '';
        };
      };
    };
  # User settings that do not depend on the host
  userType = submodule userComponent;

  # All user settings even ones that depend on the host
  userHostType = submodule [
    userComponent
    hostComponent
  ];

in
{
  options.baseline = {
    users = mkOption {
      type = attrsOf userType;
      default = { };
    };
    user = mkOption {
      type = userHostType;
      default = { };
    };
    userNames = mkOption {
      readOnly = true;
      type = listOf str;
      default = attrNames config.baseline.users;
    };
    userModule = mkOption {
      type = deferredModule;
      default = { };
    };
  };
}
