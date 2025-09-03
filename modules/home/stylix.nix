{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.baseline.stylix;
in
{
  options.baseline.stylix.enable = mkEnableOption "Enable baseline style";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      adw-gtk3
    ];
    stylix = {
      overlays.enable = false;
      targets = {
        firefox = {
          profileNames = [ config.baseline.firefox.profile ];
          colorTheme.enable = true;
        };
        nixvim.enable = false;
        waybar.font = "sansSerif";
        kde.enable = config.baseline.host.desktopEnvironment != "gnome";
      };
      iconTheme = {
        enable = true;
        package = pkgs.morewaita-icon-theme;
        dark = "Adwaita";
      };
      fonts.sizes = {
        desktop = 12;
      };
    };
  };
}
