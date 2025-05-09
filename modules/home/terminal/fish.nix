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
  programs.fish = mkIf cfg.enable {
    enable = true;
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
      # {
      #   name = "nix.fish";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "kidonng";
      #     repo = "nix.fish";
      #     rev = "ad57d970841ae4a24521b5b1a68121cf385ba71e";
      #     hash = "sha256-GMV0GyORJ8Tt2S9wTCo2lkkLtetYv0rc19aA5KJbo48=";
      #   };
      # }
    ];
  };
}
