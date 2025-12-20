{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
  inherit (types)
    attrsOf
    submodule
    nullOr
    str
    ;
  cfg = config.age.secrets;
in
{
  options.age.secrets = mkOption {
    type = attrsOf (
      submodule (_submod: {
        options = {
          # Owner does not make sense with home-manager
          # we need to own the file so we can manipulate it
          group = mkOption {
            type = nullOr str;
            default = null;
          };
        };
      })
    );
  };

  config =
    let
      chownSecrets = builtins.filter (secret: secret.group != null) (builtins.attrValues cfg);
      owner = config.home.username;
    in
    mkIf (chownSecrets != [ ]) {
      home.activation.chownSecrets = lib.hm.dag.entryAfter [ "reloadSystemd" ] (
        builtins.concatStringsSep "\n" (
          builtins.map (secret: ''
            if [ !  -f ${secret.path} ]; then
              systemctl --user restart agenix.service
            fi
            echo "Chowning ${secret.path} with ${owner}:${secret.group}..."
            chown ${owner}:${secret.group} ${secret.path}
          '') chownSecrets
        )
      );
    };

}
