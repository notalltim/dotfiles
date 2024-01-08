{ config, pkgs, internalLib, lib, isHome, ... }:
let
  inherit (internalLib) writeIntelGLWrapper;
  kitty = writeIntelGLWrapper pkgs.kitty;
  font_features = types:
    lib.strings.concatMapStringsSep "\n"
    (type: "font_features CaskaydiaCoveNF-" + type + " +ss02 +ss20 +ss19")
    types;
in {
  programs.kitty = {
    enable = true;
    package = kitty;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "CaskaydiaCove Nerd Font";
      # Only pull in the CaskaydiaCove nerd font + Fall back REVISIT: Why need fall back?
      package =
        (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" "Iosevka" ]; });
    };
    settings = {
      enable_audio_bell = false;
      disable_ligatures = "cursor";
    };
    theme = "Nightfox";
    extraConfig = (font_features [
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
    ]);
  };
  # This is needed for kitty to find the font
  fonts.fontconfig.enable = true;

  xdg.desktopEntries.kitty = {
    name = "Kitty";
    type = "Application";
    genericName = "Terminal emulator";
    comment = "Fast, feature-rich, GPU based terminal";
    exec = "${kitty}/bin/kitty";
    icon = "${kitty}/share/icons/hicolor/256x256/apps/kitty.png";
    categories = [ "System" "TerminalEmulator" ];
  };

  xdg.desktopEntries.kitty-open = {
    name = "Kitty URL Launcher";
    type = "Application";
    genericName = "Terminal emulator";
    comment = "Open URLs with kitty";
    exec = "${kitty}/bin/kitty +open %U";
    icon = "${kitty}/share/icons/hicolor/256x256/apps/kitty.png";
    categories = [ "System" "TerminalEmulator" ];
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
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        rm -rf ${config.xdg.dataHome}/"applications/home-manager"
        mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
        cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
      '';
    };
  };

  dconf.settings = (if isHome then
    { }
  else {
    "org/gnome/desktop/applications/terminal" = {
      exec = "${kitty}/bin/kitty";
      exec-arg = "";
    };
  });

}
