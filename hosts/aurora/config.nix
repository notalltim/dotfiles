{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  host = config.baseline.host.name;
in
{
  config = (
    mkIf (host == "aurora") {
      # Modules
      baseline = {
        audio.enable = true;
        stylix.enable = true;
        displays.enable = true;
        networking.enable = true;
      };
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

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
      programs.zoom-us.enable = true;

      # $ nix search wget
      environment.systemPackages = with pkgs; [
        git
        nvtopPackages.full
      ];
      # common home-manager options
      baseline.homeCommon = {
        services.kanshi = {
          enable = true;
          settings = [
            {
              profile = {
                name = "office";
                outputs = [
                  {
                    criteria = "GIGA-BYTE TECHNOLOGY CO., LTD. M27Q 20120B000001";
                    status = "enable";
                    scale = 1.0;
                    position = "1920,0";
                    mode = "--custom 2560x1440@143.86Hz";
                  }
                  {
                    criteria = "DP-1";
                    status = "enable";
                    scale = 1.0;
                    position = "0,0";
                    mode = "1920x1080@74.97Hz";
                  }
                  {
                    criteria = "DP-2";
                    status = "enable";
                    scale = 1.0;
                    position = "4480,0";
                    transform = "270";
                    mode = "1920x1080@74.97Hz";
                  }
                ];
              };
            }
          ];
        };
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.05"; # Did you read the comment?
    }
  );
}
