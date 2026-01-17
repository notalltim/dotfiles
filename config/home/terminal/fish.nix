{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf getExe;
  cfg = config.baseline.terminal;
in
{
  programs.bash.enable = true;
  programs.fish = mkIf cfg.enable {
    enable = true;
    functions = {
      nvtop = {
        body = "NCURSES_NO_UTF8_ACS=1 command nvtop";
        wraps = "nvtop";
      };
      nixpy = {
        body = "command nix develop --expr \"let pkgs = import <nixpkgs> {}; in pkgs.mkShell { packages = [ (pkgs.python3.withPackages (ps: with ps; [$argv]))];}\" --impure";
        wraps = "nix";
      };
      init-py-shell = {
        body = "echo \"let pkgs = import <nixpkgs> {}; in pkgs.mkShell { packages = [ (pkgs.python3.withPackages (ps: with ps; [$argv]))];}\" | ${getExe pkgs.nixfmt}  > shell.nix";
      };
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
