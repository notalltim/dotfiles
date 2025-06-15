{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (lib) mkDefault;
  hostspec = config.baseline.hosts.${host};
in
{
  baseline.host = hostspec;
  networking.hostName = hostspec.hostname; # Define your hostname.
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  nix.settings = {
    trusted-users = [ "@wheel" ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  environment.systemPackages = with pkgs; [
    git
  ];
  security.polkit.enable = true;

  # Set the default shell to use on the system.
  # this should be overriden all hosts
  system.stateVersion = mkDefault "25.05";
}
