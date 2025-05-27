{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    mkOption
    ;
  inherit (lib.types)
    nullOr
    path
    ;
  cfg = config.baseline.secrets;
in
{
  options.baseline.secrets = {
    hostPubkey = mkOption {
      type = nullOr options.age.rekey.hostPubkey.type;
      default = null;
    };
    userPubkey = mkOption {
      type = nullOr options.age.rekey.hostPubkey.type;
      default = null;
      description = ''
        The user scope key to use for rekey
      '';
    };
    defaultIdentity = mkOption {
      type = path;
      default = ./identities/yubikey-3314879-piv.pub;
    };
  };

  config = {
    age = {
      rekey = {
        # Keys that will be tried for unlock
        masterIdentities = [
          (cfg.defaultIdentity)
        ];

        # Keys that will also be used for encryption but not for decryption
        # for backup keys
        extraEncryptionPubkeys = [
          # public key of ./pub/yubikey-3314879-hmac.pub
          "age1tztn7rsjt6r3x2jpr0qmjnrd4jdtqu4lw7e6sdhdr8zx6fdze49q873qdm"
          # public key of ./pub/yubikey-30665035-piv.pub
          "age1yubikey1qwa56syvllfur4astym20v52qwgw47akehcjvrvgyycxx44t9szdu3d9vl8"
        ];

        # Use this for now we are not building on remote hosts at the moment
        storageMode = "derivation";

        # I am using the FIDO2 and PIV
        agePlugins = with pkgs; [
          age-plugin-fido2-hmac
          age-plugin-yubikey
        ];

      };
    };
    nix.settings.extra-sandbox-paths = [ "${config.age.rekey.cacheDir}" ];
  };
}
