{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.strings) concatMapStringsSep;
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault optionalString;
  gpuWrapCheck = config.lib.nixGL.wrap;
  font_features =
    types:
    concatMapStringsSep "\n" (
      type: "font_features CaskaydiaCoveNF-" + type + " +ss02 +ss20 +ss19"
    ) types;
  cfg = config.programs.kitty;
  baseline = config.baseline.kitty;
  inherit (config.baseline) terminal;
in
{
  options = {
    baseline.kitty = {
      enableKeybind = mkEnableOption "Enable opening the termninal via ctrl+alt+t (uses dconf)";
    };
  };
  config = mkIf terminal.enable {

    home.packages = with pkgs.nerd-fonts; [
      caskaydia-mono
      iosevka
    ];

    programs.kitty = {
      enable = mkDefault true;
      shellIntegration.enableFishIntegration = mkDefault true;

      settings = {
        enable_audio_bell = false;
        disable_ligatures = "cursor";
      };
      # Support kitty on non nixos system
      package = gpuWrapCheck pkgs.kitty;

      extraConfig = font_features [
        "Regular"
        "Bold"
        "BoldItalic"
        "ExtraLight"
        "ExtraLightItalic"
        "Italic"
        "Light"
        "LightItalic"
        "SemiBold"
        "SemiBoldItalic"
        "SemiLight"
        "SemiLightItalic"
      ];
    };

    programs.fish.interactiveShellInit = optionalString config.baseline.non-nixos.enable ''
      set -e LD_LIBRARY_PATH VK_LAYER_PATH VK_ICD_FILENAMES LIBGL_DRIVERS_PATH LIBVA_DRIVER_NAME LIBVA_DRIVERS_PATH __GLX_VENDOR_LIBRARY_NAME __EGL_VENDOR_LIBRARY_FILENAMES
    '';
    # This is needed for kitty to find the font
    fonts.fontconfig.enable = true;

    # Launch kitty with key command
    dconf.settings = mkIf baseline.enableKeybind {
      "org/gnome/desktop/applications/terminal" = {
        exec = "${cfg.package}/bin/kitty";
        exec-arg = "";
      };
    };
  };
}
