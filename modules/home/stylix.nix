{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.baseline.stylix;
in
{
  options.baseline.stylix.enable = mkEnableOption "Enable baseline style";
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.vimPlugins.nightfox-nvim}/extra/nightfox/base16.yaml";
      image = pkgs.fetchurl {
        url = "https://images.pexels.com/photos/3081835/pexels-photo-3081835.jpeg";
        hash = "sha256-qhkXsZHZCMJP40347QajOfIsaskYl+zCVGAeUWkoEig=";
      };
      targets = {
        firefox.profileNames = [ config.baseline.firefox.profile ];
        nixvim.enable = false;
      };
      polarity = "dark";
      fonts = {
        serif = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCoveNerdFontPropo";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCoveNerdFontPropo";
        };

        monospace = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCoveNerdFontMono";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
