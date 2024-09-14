{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nixseparatedebuginfod;
  url = "127.0.0.1:${toString cfg.port}";
  inherit (lib) mkIf getExe;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) port;
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
      package = mkPackageOption pkgs "nixseparatedebuginfod" { };
      nixPackage = mkPackageOption pkgs "nix" { };
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      DEBUGINFOD_URLS = "http://${url}";
    };
    systemd.user.services.nixseperatedebuginfod = {
      Unit = {
        Description = "Download and provide separate debuginfo via the nix store";
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Environment = "PATH=${lib.makeBinPath [ cfg.nixPackage ]}";
        Restart = "on-failure";
        ExecStart = "${getExe cfg.package} -l ${url}";
      };
    };
  };
}
