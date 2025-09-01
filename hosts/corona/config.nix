# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  lib,
  GPUOffloadApp,
  ...
}:
let
  inherit (lib) mkIf;
  host = config.baseline.host.name;
in
{
  config = (
    mkIf (host == "corona") {
      # Modules
      baseline = {
        audio.enable = true;
        stylix.enable = true;
        secureboot = {
          enable = true;
          factorySignatures = {
            dell-KEK = {
              file = ./secureboot/factory/dell-KEK.esl;
              type = "KEK";
            };
            dell-db = {
              file = ./secureboot/factory/dell-db.esl;
              type = "db";
            };
          };
        };
        homeCommon = {
          programs.firefox.package = (GPUOffloadApp pkgs.firefox "firefox");
          services.kanshi = {
            enable = true;
            settings = [
              {
                profile = {
                  name = "roaming";
                  outputs = [
                    {
                      criteria = "Sharp Corporation 0x149A Unknown";
                      status = "enable";
                      scale = 1.0;
                      mode = "1920x1080@60.00Hz";
                    }
                  ];
                };
              }
              {
                profile = {
                  name = "docked-office";
                  outputs = [
                    {
                      criteria = "GIGA-BYTE TECHNOLOGY CO., LTD. M27Q 20120B000001";
                      status = "enable";
                      scale = 1.0;
                      position = "1920,0";
                      mode = "--custom 2560x1440@143.86Hz";
                    }
                    {
                      criteria = "Sceptre Tech Inc T27 Unknown";
                      status = "enable";
                      scale = 1.0;
                      position = "0,0";
                      mode = "1920x1080@74.97Hz";
                    }
                    {
                      criteria = "Sharp Corporation 0x149A Unknown";
                      status = "disable";
                    }
                  ];
                };
              }
            ];
          };
        };
      };
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # boot.kernelPackages = pkgs.linuxPackages_latest;
      # Enable networking
      networking.networkmanager.enable = true;

      # Enable the GNOME Desktop Environment.
      # services.xserver.displayManager.gdm.enable = true;
      # services.xserver.displayManager.gdm.wayland = true;
      # services.xserver.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;
      services.openssh.enable = true;

      # Install firefox.
      programs.firefox.enable = true;
      programs.fish.enable = true;
      # Allow unfree packages

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        git
        nvtopPackages.full
      ];

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "24.11"; # Did you read the comment?
    }
  );
}
