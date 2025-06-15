{
  baseline = {
    hostNames = [ "corona" ];
    hosts.aurora = {
      platform = "hm";
      users.tgallion.userPubkey = ./id_ed25519.pub;
      desktopEnvironment = "gnome";
    };
  };

}
