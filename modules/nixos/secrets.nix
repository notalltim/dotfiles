{
  config,
  lib,
  ...
}:
let
  inherit (lib) attrNames;
  inherit (config.baseline) host;
in
{

  # users.groups.secrets.members = attrNames host.users;
  # Avoid issue where the nix build user owns the secrets
  age.rekey = {
    inherit (host) hostPubkey;
    cacheDir = "/tmp/agenix-rekey/${host.hostname}";
  };
  systemd.tmpfiles.rules = [
    "D ${config.age.rekey.cacheDir} 775 root wheel - -"
  ];
  # Required to set sandbox paths
  nix.settings.trusted-users = attrNames host.users;

  # Smart card (yubi key PIV)
  services.pcscd.enable = true;
}
