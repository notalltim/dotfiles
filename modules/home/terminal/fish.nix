{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in
{
  programs.bash.enable = true;
  programs.fish = mkIf cfg.enable {
    enable = true;
    functions = {
      body = ''NCURSES_NO_UTF8_ACS=1 nvtop'';
      wraps = "nvtop";
    };
    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
          hash = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
        };
      }
    ];
  };
}
