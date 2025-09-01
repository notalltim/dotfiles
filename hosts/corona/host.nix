{
  baseline = {
    hostNames = [ "corona" ];
    hosts.corona = {
      platform = "nixos";
      users.tgallion.userPubkey = ./tgallion.pub;
      hostPubkey = ./corona.pub;
      desktopEnvironment = "hyprland";
      hostPath = ./.;
    };
  };

}
