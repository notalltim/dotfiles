{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.baseline) host user;
  inherit (lib)
    mkIf
    removeSuffix
    mkEnableOption
    head
    escapeShellArg
    ;
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
      extraConfigLua =
        let
          masterIdentity = head config.age.rekey.masterIdentities;
        in
        ''
          require('age_secret').setup({
              recipient = "${removeSuffix "\n" masterIdentity.pubkey}", -- Replace with your AGE recipient
              identity = "${removeSuffix "\n" masterIdentity.identity}", -- Replace with the path to your AGE secret key
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
      secrets.userKey = {
        rekeyFile = host.hostPath + "/${user.username}.age";
        generator = {
          script = "hostkey";
          tags = [ "bootstrap-${host.hostname}" ];
        };
      };
    };
    # Needed to allow derivation storageMode
    systemd.user.tmpfiles.rules = [
      "D ${config.age.rekey.cacheDir} 755 ${config.home.username} - - -"
    ];
  };
}
