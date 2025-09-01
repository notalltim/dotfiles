{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (lib) mkDefault hiPrio;
  patchDesktop =
    pkg: appName: from: to:
    hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    )
    // {
      override = args: (patchDesktop (pkg.override args) appName from to);
    };
  GPUOffloadApp =
    pkg: desktopName:
    if config.hardware.nvidia.prime.offload.enable then
      patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload "
    else
      pkg;
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
  services.fwupd.enable = true;
  _module.args.GPUOffloadApp = GPUOffloadApp;
  # Set the default shell to use on the system.
  # this should be overriden all hosts
  system.stateVersion = mkDefault "25.05";
}
