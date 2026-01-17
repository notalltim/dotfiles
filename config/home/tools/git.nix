{
  lib,
  config,
  pkgs,
  ...
}:
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

    home = {
      packages = with pkgs; [
        git-filter-repo
        lazygit
        rs-git-fsmonitor
      ];
      file."${config.xdg.configHome}/git/allowed_signers".text =
        "${config.programs.git.settings.user.email} ${builtins.readFile config.baseline.ssh.pubkey}     ";
    };
    programs.git = {
      enable = mkDefault true;
      lfs.enable = mkDefault true;
      signing = {
        signByDefault = true;
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_${config.home.username}.pub";
      };

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
            gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
          };
        }
      ];
    };
  };
}
