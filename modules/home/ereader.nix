{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkEnableOption
    mkOption
    ;

  cfg = config.baseline.ereader;
in
{
  options.baseline.ereader = {
    enable = mkEnableOption "ereader";
    calibrePlugins = mkOption {
      type = with types; listOf path;
      default = [ ];
      description = "List of plugins to install for calibre";
    };
    dpt = {
      serial = mkOption { type = types.str; };
      deviceid = mkOption { type = types.path; };
      privatekey = mkOption { type = types.path; };
    };

  };

  config = mkIf cfg.enable {
    age.secrets = {
      dpt-device-id = {
        rekeyFile = cfg.dpt.deviceid;
        path = "${config.xdg.configHome}/dpt/deviceid.dat";
      };
      dpt-private-key = {
        rekeyFile = cfg.dpt.privatekey;
        path = "${config.xdg.configHome}/dpt/privatekey.dat";
      };
    };

    home.packages = [
      pkgs.calibre
      pkgs.dpt-rp1-py
    ];

    xdg.configFile."dpt-rp1.conf".source = pkgs.writers.writeYAML "dpt-rp1.conf" {
      dptrp1 = {
        serial = "${cfg.dpt.serial}";
        client-id = "${config.xdg.configHome}/dpt/deviceid.dat";
        key = "${config.xdg.configHome}/dpt/privatekey.dat";
      };
    };

    systemd.user.services.dptmount = {
      Unit = {
        Description = "Mount dpt-rp1 device";
      };
      Service =
        let
          mountDir = "${config.xdg.userDirs.documents}/dpt/";
        in
        {
          ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${mountDir}";
          ExecStart = "${lib.getExe' pkgs.dpt-rp1-py "dptmount"} ${mountDir}";

          # Retry Logic
          Restart = "on-failure"; # Options: always, on-failure, on-abnormal, etc.
          RestartSec = "5s"; # Time to wait before retrying
        };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # home.activation.installCalibrePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   plugin_hash="${(builtins.concatStringsSep "" cfg.calibrePlugins)}"
    #   marker="$HOME/.config/calibre/.plugins-installed-hash"
    #   if [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$plugin_hash" ]; then
    #     for plugin in ${
    #       lib.concatMapStringsSep " " (plugin: builtins.toString plugin) cfg.calibrePlugins
    #     }; do
    #       $DRY_RUN_CMD ${lib.getExe' pkgs.calibre "calibre-customize"} -a "$plugin"
    #     done
    #     echo -n "$plugin_hash" > "$marker"
    #   fi
    # '';
  };
}
