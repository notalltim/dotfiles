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
      base16Scheme = "${pkgs.vimPlugins.nightfox-nvim}/extra/nightfox/base16.yaml";
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
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
