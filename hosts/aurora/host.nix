{
  baseline = {
    hostNames = [ "aurora" ];
    hosts.aurora = {
      platform = "nixos";
      users.tgallion.userPubkey = ./tgallion.pub;
      hostPubkey = ./aurora.pub;
      desktopEnvironment = "hyprland";
      hostPath = ./.;
    };
  };
}
