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
      kanshi
      read-edid
      edid-decode
      shikane
      pciutils
      glib
      avahi
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

  age.secrets = {
    cachix-authtoken = {
      intermediary = true;
      rekeyFile = ./secrets/cachix-authtoken.age;
    };
    github-token = {
      intermediary = true;
      rekeyFile = ./secrets/github-token.age;
    };
    gitlab-token = {
      intermediary = true;
      rekeyFile = ./secrets/gitlab-token.age;
    };
  };

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
    nix.enable = true; # TODO: this does not cover the case I want it does not control the nix version
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
    userEmail = "timbama@gmail.com";
    userName = tgallion.fullName;
  };

  services.auto-gc-roots = {
    automatic = true;
    flakes = {
      "self" = {
        url = "path:${config.baseline.nix.flakeSource}";
      };
    };
  };

  programs.obs-studio = {
    enable = true;
  };
  nix = {
    access-tokens = {
      file = ./secrets/access-tokens.age;
      tokens = [
        {
          url = "github.com";
          secret = config.age.secrets.github-token;
        }
        {
          url = "gitlab.com";
          tokenType = "PAT";
          secret = config.age.secrets.gitlab-token;
        }
      ];
    };
    netrc = {
      file = ./secrets/netrc.age;
      logins = [
        {
          url = "hyprland.cachix.org";
          pubkey = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
          secret = config.age.secrets.cachix-authtoken;
        }
      ];
    };
  };
})
