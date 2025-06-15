{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.baseline) host user;
  inherit (lib) mkIf removeSuffix mkEnableOption;
  cfg = config.baseline.secrets;
in
{
  options.baseline.secrets.enable = (mkEnableOption "Enable baseline secrets") // {
    default = true;
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
            recipient = "${removeSuffix "\n" host.hostPubkey}", -- Replace with your AGE recipient
            identity = "${removeSuffix "\n" cfg.defaultIdentity}", -- Replace with the path to your AGE secret key
            tool = "rage"
        });
      '';
    };

    age = {
      identityPaths = [
        "${config.home.homeDirectory}/.ssh/id_${host.hostname}"
      ];
      rekey = {
        hostPubkey = user.userPubkey;
        # This is needed because the default uses UID which is not know to home-manager
        cacheDir = "/tmp/agenix-rekey.${config.home.username}";
      };
    };
    # Needed to allow derivation storageMode
    systemd.user.tmpfiles.rules = [
      "D ${config.age.rekey.cacheDir} 755 ${config.home.username} - - -"
    ];
  };
}
