{ config, lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib) mkIf concatMapAttrs nameValuePair;
  inherit (lib.types)
    attrsOf
    listOf
    str
    path
    submodule
    ;
  fingerType =
    { ... }:
    {
      options = {
        name = mkOption { type = str; };
        slot = mkOption { type = str; };
        module = mkOption { type = str; };
        path = mkOption { type = path; };
      };
    };
in
{
  options = {
    users.users = mkOption {
      type = attrsOf (
        submodule (_submod: {
          options = {
            fingerprints = mkOption {
              type = listOf (submodule fingerType);
              default = [ ];
            };
          };

        })
      );
    };
  };

  config =
    let
      fingerprints = concatMapAttrs (
        userName: userVal:
        if userVal.fingerprints != [ ] then
          builtins.listToAttrs (
            map (
              finger:
              nameValuePair "${userName}-${finger.module}-${finger.slot}-${finger.name}" {
                user = userName;
                inherit (finger) path slot module;
                finger = finger.name;
              }
            ) userVal.fingerprints
          )
        else
          { }
      ) config.users.users;
    in
    mkIf (fingerprints != { }) {
      services.fprintd.enable = true;
      age.secrets = builtins.mapAttrs (_: attrs: {
        rekeyFile = attrs.path;
        path = "/var/lib/fprint/${attrs.user}/${attrs.module}/${attrs.slot}/${attrs.finger}";
        owner = "root";
        group = "root";
        mode = "644";
      }) fingerprints;
    };
}
