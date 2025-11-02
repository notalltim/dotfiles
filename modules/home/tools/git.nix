{ lib, config, ... }:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault;
  cfg = config.baseline.git;
  hasKey = config.programs.git.signing.key != null;
  nixvimEnabled = config.baseline.nixvim.enable;
in
{
  options.baseline.git = {
    enable = mkEnableOption "Enable baseline git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = mkDefault true;
      lfs.enable = mkDefault true;
      signing.signByDefault = mkDefault hasKey;

      includes = [
        {
          contents = {
            commit = {
              gpgSign = mkDefault hasKey;
            };
            core = {
              editor = mkIf nixvimEnabled "nvim";
              autocrlf = mkDefault "input";
              fsmonitor = mkDefault true;
            };
            color = {
              ui = mkDefault "auto";
            };
            push = {
              autoSetupRemote = mkDefault true;
            };
          };
        }
      ];
    };
  };
}
