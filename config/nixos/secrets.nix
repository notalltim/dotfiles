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
  age = {
    identityPaths = [ "/etc/ssh/ssh_${host.hostname}_ed25519_key" ];
    rekey = {
      inherit (host) hostPubkey;
      cacheDir = "/tmp/agenix-rekey/${host.hostname}";
    };
    secrets.hostKey = {
      rekeyFile = host.hostPath + "/${host.hostname}.age";
      generator = {
        script = "hostkey";
        tags = [ "bootstrap-${host.hostname}" ];
      };
    };
  };
  systemd.tmpfiles.rules = [
    "D ${config.age.rekey.cacheDir} 775 root wheel - -"
  ];
  # Required to set sandbox paths
  nix.settings.trusted-users = attrNames host.users;

  # Smart card (yubi key PIV)
  services.pcscd.enable = true;
}
