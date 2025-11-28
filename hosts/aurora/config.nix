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
      system.stateVersion = "25.05"; # Did you read the comment?
    }
  );
}
