{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    optionalAttrs
    versionOlder
    mkOption
    types
    ;
  inherit (types) submodule str bool;
  inherit (lib.trivial) release;
  enabled = versionOlder release "25.11";
in
{
  options = (
    optionalAttrs enabled {
      nix.gc.dates = mkOption { type = str; };

      programs.git.settings.user = {
        name = mkOption {
          type = str;

        };
        email = mkOption { type = str; };
      };

      programs.ssh = {
        enableDefaultConfig = mkOption {
          type = bool;
          default = false;
        };
        matchBlocks = mkOption {
          type = lib.hm.types.dagOf (
            submodule (_: {
              options = {
                addKeysToAgent = mkOption { type = str; };
              };
            })
          );
        };
      };

    }
  );

  config = mkIf enabled {
    nix.gc.frequency = config.nix.gc.dates;
    programs.git.userName = config.programs.git.settings.user.name;
    programs.git.userEmail = config.programs.git.settings.user.email;
    programs.ssh.addKeysToAgent = config.programs.ssh.matchBlocks."*".data.addKeysToAgent;
  };
}
