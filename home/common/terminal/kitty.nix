{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatMapStringsSep;
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  font_features = types:
    concatMapStringsSep "\n"
    (type: "font_features CaskaydiaCoveNF-" + type + " +ss02 +ss20 +ss19")
    types;
  cfg = config.programs.kitty;
  baseline = config.baseline.kitty;
in {
  options = {
    baseline.kitty = {
      enableKeybind = mkEnableOption "Enable opening the termninal via ctrl+alt+t (uses dconf)";
    };
  };
  config = {
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      font = {
        name = "CaskaydiaCove Nerd Font";
        # Only pull in the CaskaydiaCove nerd font + Fall back REVISIT: Why need fall back?
        package =
          pkgs.nerdfonts.override {fonts = ["CascadiaCode" "Iosevka"];};
      };
      settings = {
        enable_audio_bell = false;
        disable_ligatures = "cursor";
      };
      theme = "Nightfox";
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
    # This is needed for kitty to find the font
    fonts.fontconfig.enable = true;

    xdg.desktopEntries.kitty = {
      name = "Kitty";
      type = "Application";
      genericName = "Terminal emulator";
      comment = "Fast, feature-rich, GPU based terminal";
      exec = "${cfg.package}/bin/kitty";
      icon = "${cfg.package}/share/icons/hicolor/256x256/apps/kitty.png";
      categories = ["System" "TerminalEmulator"];
    };

    xdg.desktopEntries.kitty-open = {
      name = "Kitty URL Launcher";
      type = "Application";
      genericName = "Terminal emulator";
      comment = "Open URLs with kitty";
      exec = "${cfg.package}/bin/kitty +open %U";
      icon = "${cfg.package}/share/icons/hicolor/256x256/apps/kitty.png";
      categories = ["System" "TerminalEmulator"];
      noDisplay = true;
      mimeType = [
        "image/*"
        "application/x-sh"
        "application/x-shellscript"
        "inode/directory"
        "text/*"
        "x-scheme-handler/kitty"
      ];
    };

    home.activation = {
      linkDesktopApplications = {
        after = ["writeBoundary" "createXdgUserDirectories"];
        before = [];
        data = ''
          rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/kitty* ${config.xdg.dataHome}/"applications/home-manager/"
        '';
      };
    };
    # Launch kitty with key command
    dconf.settings = mkIf baseline.enableKeybind {
      "org/gnome/desktop/applications/terminal" = {
        exec = "${cfg.package}/bin/kitty";
        exec-arg = "";
      };
    };
  };
}
