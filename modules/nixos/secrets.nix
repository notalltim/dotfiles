{
  config,
  ...
}:
let
  primaryUser = config.baseline.userspec.username;
in
{
  # Avoid issue where the nix build user owns the secrets
  age.rekey = {
    inherit (config.baseline.secrets) hostPubkey;
    cacheDir = "/tmp/agenix-rekey/${config.networking.hostName}";
  };
  systemd.tmpfiles.rules = [
    "D ${config.age.rekey.cacheDir} 755 ${primaryUser} ${primaryUser} - -"
  ];
  # Required to set sandbox paths
  nix.settings.trusted-users = [ "${primaryUser}" ];

  # Smart card (yubi key PIV)
  services.pcscd.enable = true;
}
