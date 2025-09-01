{
  baseline = {
    hostNames = [ "corona" ];
    hosts.corona = {
      platform = "nixos";
      users.tgallion.userPubkey = ./id_corona_tgallion.pub;
      hostPubkey = ./ssh_host_ed25519_key.pub;
      desktopEnvironment = "hyprland";
      hostPath = ./.;
    };
  };

}
