{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.nixseparatedebuginfod;
  url = "127.0.0.1:${toString cfg.port}";
  # REVISIT: not needed after 24.05
  nixseparatedebuginfod = pkgs.callPackage ./nixseparatedebuginfod.nix {};
in {
  options = {
    services.nixseparatedebuginfod = {
      enable = lib.mkEnableOption "nixseparatedebuginfod: Daemon for retrieving separate degubinfo from the nix store";
      port = lib.mkOption {
        description = "port to listen";
        default = 1949;
        type = lib.types.port;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      DEBUGINFOD_URLS = "http://${url}";
    };
    systemd.user.services.nixseperatedebuginfod = {
      Unit = {
        Description = "Download and provide separate debuginfo via the nix store";
      };
      Install.WantedBy = ["default.target"];
      Service = {
        Environment = "PATH=${lib.makeBinPath [pkgs.nix]}";
        Restart = "on-failure";
        ExecStart = "${nixseparatedebuginfod}/bin/nixseparatedebuginfod -l ${url}";
      };
    };
  };
}
