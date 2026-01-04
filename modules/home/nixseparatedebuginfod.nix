{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nixseparatedebuginfod;
  url = "127.0.0.1:${toString cfg.port}";
  inherit (lib)
    mkIf
    getExe
    mkDefault
    optionals
    ;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types)
    port
    str
    package
    nullOr
    listOf
    ;
  isV2 = cfg.package.pname == "nixseparatedebuginfod2";
  command = [
    (getExe cfg.package)
    "--listen-address ${url}"
  ]
  ++ optionals isV2 (
    [
      "--expiration ${cfg.cacheExpirationDelay}"
      "--cache-dir ${cfg.cacheDir}"
    ]
    ++ builtins.map (substituter: "--substituter ${substituter}") cfg.substituters
  );
in
{
  options = {
    services.nixseparatedebuginfod = {
      enable = mkEnableOption "nixseparatedebuginfod: Daemon for retrieving separate degubinfo from the nix store";
      port = mkOption {
        description = "port to listen";
        default = 1949;
        type = port;
      };
      cacheExpirationDelay = mkOption {
        type = str;
        description = "keep unused cache entries for this long. A number followed by a unit";
        default = "1d";
      };
      cacheDir = mkOption {
        type = str;
        default = "${config.xdg.cacheHome}/${cfg.package.pname}";
      };
      package = mkOption {
        type = nullOr package;
        default = null;
      };
      substituters = mkOption {
        type = listOf str;
        default = [ "local:" ] ++ config.nix.settings.substituters;
      };
    };
  };
  config = mkIf cfg.enable {

    services.nixseparatedebuginfod.package = mkDefault (
      pkgs.nixseparatedebuginfod2 or pkgs.nixseparatedebuginfod
    );

    home.sessionVariables = {
      DEBUGINFOD_URLS = "http://${url}";
    };
    # Required by valgrind
    home.packages = [ (lib.getBin pkgs.elfutils) ];
    programs.gdb.extraConfig = "set debuginfod enabled on";
    systemd.user.services.${cfg.package.pname} = {
      Unit = {
        Description = "Download and provide separate debuginfo via the nix store";
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Environment = "PATH=${lib.makeBinPath [ config.nix.package ]}";
        Restart = "on-failure";
        ExecStart = builtins.concatStringsSep " \\\n" command;
      };
    };
  };
}
