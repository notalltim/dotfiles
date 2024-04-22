{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.git;
  hasKey = config.programs.git.signing.key != null;
in {
  options.baseline.git = {
    enable = mkEnableOption "Enable baseline git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      signing.signByDefault = hasKey;

      includes = [
        {
          contents = {
            commit = {gpgSign = hasKey;};
            core = {
              editor = "nvim";
              autocrlf = "input";
            };
            color = {ui = "auto";};
            push = {autoSetupRemote = true;};
          };
        }
      ];
    };
  };
}
