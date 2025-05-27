{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) path;
  cfg = config.baseline.ssh;
in
{
  options.baseline.ssh = {
    enable = mkEnableOption "Enable ssh handling";
    pubkey = mkOption {
      type = path;
    };
    privkey = mkOption {
      type = path;
    };
  };
  config = mkIf cfg.enable {
    age.secrets.ssh-key = {
      rekeyFile = cfg.privkey;
      path = "${config.home.homeDirectory}/.ssh/id_${config.home.username}";
      mode = "600";
    };
    home.file."${config.home.homeDirectory}/.ssh/id_${config.home.username}.pub".source = cfg.pubkey;

    services.ssh-agent.enable = true;
    # systemd.user.tmpfiles.rules = [ "d %h/.ssh 700 - - - -" ];
    programs.ssh = {
      enable = true;
      forwardAgent = true;
      addKeysToAgent = "yes";
      matchBlocks = {
        "*" = {
          identityFile = [
            config.age.secrets.ssh-key.path
          ];
        };
      };
    };
  };
}
