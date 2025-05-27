{ config, ... }:
{
  baseline = {
    hostspec = {
      hostname = "corona";
      platform = "nixos";
    };

    secrets = {
      hostPubkey = ./ssh_host_ed25519_key.pub;
      userPubkey = ./id_corona_${config.baseline.userspec.username}.pub;
    };
  };
}
