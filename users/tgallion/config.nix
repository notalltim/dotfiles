{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.baseline.users) tgallion;
  inherit (config.baseline) host user;
  inherit (lib) mkIf;
  gpuWrapCheck = config.lib.nixGL.wrap;
in
(mkIf (user.name == "tgallion") {

  home = {
    stateVersion = "24.11";
    homeDirectory = "/home/${tgallion.username}";
    username = tgallion.username;
    enableDebugInfo = true;

    packages = with pkgs; [
      (gpuWrapCheck kicad)
      (gpuWrapCheck freecad)
      jellyfin-media-player
      discord
      radeontop
      bitwarden
      audacity
      mprime
      openrgb-with-all-plugins
      kanshi
      hyprland
      read-edid
      edid-decode
      shikane
      pciutils
      spotifyd
      glib
      (python3.withPackages (
        pkgs: with pkgs; [
          numpy
          scipy
          matplotlib
        ]
      ))
    ];
  };
  programs.fish.functions = {
    sudos = {
      body = ''command sudo env "PATH=\$PATH" $argv'';
      wraps = "sudo";
    };
  };

  # For gdb debugging
  services.nixseparatedebuginfod.enable = true;

  # Common config expressed as basic modules
  baseline = {
    nixvim = {
      enableAll = true;
      completion.codeium.apikey = ./secrets/codeium-apikey.age;
      enableWayland = true;
    };
    kitty.enableKeybind = true;
    packages.enable = true;
    home-manager.enable = true;
    nix = {
      enable = true;
      accessTokensPath = ./secrets/access-tokens.age;
    }; # TODO: this does not cover the case I want it does not control the nix version
    tools.enable = true;
    terminal.enable = true;
    non-nixos = {
      enable = host.platform != "nixos";
      gpu.enableVulkan = true;
    };
    ssh = {
      enable = true;
      pubkey = ./id_ed25519.pub;
      privkey = ./secrets/ssh-key-home.age;
    };
    firefox = {
      enable = true;
    };
    stylix.enable = true;
    spotify = {
      enable = true;
    };
  };

  services.gpg-agent.enable = true;
  programs.gpg.enable = true;
  programs.git = {
    signing = {
      key = "5A2DAA31F5457F29";
    };
    userEmail = "timbama@gmail.com";
    userName = tgallion.fullName;
  };
})
