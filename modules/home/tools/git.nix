{ lib, config, ... }:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault;
  cfg = config.baseline.git;
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

      includes = [
        {
          contents = {
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
