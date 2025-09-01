{
  baseline.hosts.piezo = {
    platform = "nixos";
    desktopEnvironment = "headless";
    users.tgallion.userPubkey = ../corona/id_corona_tgallion.pub;
    hostPubkey = ../corona/ssh_host_ed25519_key.pub;
    hostPath = ./.;
  };
}
