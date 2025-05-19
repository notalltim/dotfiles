{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    removeSuffix
    ;
  inherit (lib.types)
    nullOr
    str
    path
    coercedTo
    ;
  cfg = config.baseline.secrets;
in
{
  options.baseline.secrets = {
    enable = mkEnableOption "Enable secrets handling";
    hostPubkey = mkOption {
      type = nullOr options.age.rekey.hostPubkey.type;
      default = null;
    };
    defaultIdentity = mkOption {
      type = coercedTo path toString str;
      default = ./pub/yubikey-3314879-piv.pub;
    };
  };
  config = mkIf cfg.enable {

    # Used for enrolling keys and editing
    home.packages = with pkgs; [
      rage
      agenix-rekey
      age-plugin-fido2-hmac
      age-plugin-yubikey
    ];

    services.yubikey-touch-detector = {
      enable = true;
      # socket.enable = true;
    };

    programs.nixvim = mkIf config.baseline.nixvim.enable {
      extraPlugins = [
        pkgs.agenix-secret-nvim
      ];
      extraConfigLua = ''
        require('age_secret').setup({
            recipient = "${removeSuffix "\n" config.age.rekey.hostPubkey}", -- Replace with your AGE recipient
            identity = "${removeSuffix "\n" cfg.defaultIdentity}", -- Replace with the path to your AGE secret key
            tool = "rage"
        });
      '';
    };

    age = {
      rekey = {
        inherit (cfg) hostPubkey;
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

        # This is needed because the default uses UID which is not know to home-manager
        cacheDir = mkIf (config.baseline.non-nixos.enable) "/tmp/agenix-rekey.${config.home.username}";
      };
    };
    # Needed to allow derivation storageMode
    systemd.user.tmpfiles.rules = mkIf (config.baseline.non-nixos.enable) [
      "D ${config.age.rekey.cacheDir} 755 ${config.home.username} ${config.home.username} - -"
    ];
    nix.settings.extra-sandbox-paths = [ "${config.age.rekey.cacheDir}" ];
  };
}
