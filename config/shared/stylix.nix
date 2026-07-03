{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.baseline.stylix;
in
{
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme =
        builtins.fetchGit {
          url = "https://github.com/EdenEast/nightfox.nvim";
          rev = "ccefc3e8b3dfe41d9fab2e0dd7ebe2e30c5f8feb";
        }
        + "/extra/nightfox/base16.yaml";
      image = pkgs.fetchurl {
        url = "https://images.pexels.com/photos/3081835/pexels-photo-3081835.jpeg";
        hash = "sha256-qhkXsZHZCMJP40347QajOfIsaskYl+zCVGAeUWkoEig=";
      };

      cursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };

      polarity = "dark";
      fonts = {
        serif = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove Nerd Font Propo";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove Nerd Font Propo";
        };

        monospace = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove Nerd Font Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
