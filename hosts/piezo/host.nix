{
  baseline.hosts.piezo = {
    platform = "nixos";
    desktopEnvironment = "headless";
    users.tgallion.userPubkey = ../piezo/tgallion.pub;
    hostPubkey = ../piezo/piezo.pub;
    hostPath = ./.;
  };
}
