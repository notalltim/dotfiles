{
  config,
  lib,
  hostSecrets,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    escapeShellArg
    removeSuffix
    removePrefix
    hasAttr
    nameValuePair
    cartesianProduct
    listToAttrs
    ;
  inherit (lib.types) nullOr path;
  cfg = config.baseline.secureboot;
  keyInPath = hostSecrets + /secureboot/keys;
  keyOutPath =
    if config.baseline.non-nixos.enable then "${config.home.homeDirectory}/keys" else "/var/lib/sbctl";
  fromSecret = file: ext: escapeShellArg (removeSuffix ".age" file + ".${ext}");

  publicFiles =
    names: exts:
    listToAttrs (
      map
        (
          { name, ext }:
          nameValuePair "${keyOutPath}/${name}/${name}.${ext}" {
            source = "${keyInPath}/${name}/${name}.${ext}";
          }
        )
        (cartesianProduct {
          name = names;
          ext = exts;
        })
    );

in
{
  options.baseline.secureboot = {
    enable = mkEnableOption "Enable secureboot configuration";
    keys = mkOption {
      type = nullOr path;
      default = null;
    };
  };
  config = mkIf (cfg.enable) (mkMerge [
    {
      # assertions = [
      #   {
      #     assertion = cfg.enable -> cfg.keys != null;
      #     message = "secureboot requires the option `baseline.secureboot.securebootKeys` to bes set";
      #   }
      # ];
    }
    # Home-manager comaptible options
    {
      age.secrets.secureboot-GUID = {
        rekeyFile = hostSecrets + /secureboot/GUID.age;
        path = keyOutPath + "/GUID";
        generator = {
          script = "GUID";
          tags = [ "secureboot" ];
        };

      };
      age.generators.GUID =
        { pkgs, ... }:
        ''
          ${pkgs.util-linux}/bin/uuidgen --random
        '';

      age.generators.secureboot-key =
        {
          pkgs,
          file,
          deps,
          decrypt,
          name,
          ...
        }:
        let
          inherit (pkgs) openssl efitools;
          guidFile = "${decrypt} ${escapeShellArg deps.secureboot-GUID.file}";
          keyFile = if hasAttr deps ? signingKey then deps.signingKey.file else "keyout.key";
          keyCrt = if hasAttr deps ? signingCrt then deps.signingKey.file else crtFile;
          toFile = fromSecret file;
          crtFile = toFile "crt";
          cerFile = toFile "cer";
          eslFile = toFile "esl";
          authFile = toFile "auth";
        in
        ''
          ${openssl}/bin/openssl req -newkey rsa:4096 -nodes -keyout keyout.key -new -x509 -sha256 -days 3650 -subj "/CN=my Platform Key/" -out ${crtFile} 2> /dev/null
          cat keyout.key
          ${openssl}/bin/openssl x509 -outform DER -in ${crtFile} -out ${cerFile}
          ${efitools}/bin/cert-to-efi-sig-list -g "$(${guidFile})" ${crtFile} ${eslFile}
          ${efitools}/bin/sign-efi-sig-list -g "$(${guidFile})" -k ${keyFile} -c ${keyCrt} ${removePrefix "secureboot-" name} ${eslFile} ${authFile}
        '';

      age.secrets.secureboot-PK = {
        rekeyFile = keyInPath + /PK/PK.age;
        path = keyOutPath + "/PK.key";
        generator = {
          dependencies = { inherit (config.age.secrets) secureboot-GUID; };
          script = "secureboot-key";
          tags = [ "secureboot" ];
        };
      };

      age.secrets.secureboot-KEK = {
        rekeyFile = keyInPath + /KEK/KEK.age;
        path = keyOutPath + "/KEK.key";
        generator = {
          dependencies = {
            inherit (config.age.secrets) secureboot-GUID secureboot-PK;
            signingKey = config.age.secrets.secureboot-PK;
            signingCrt = config.age.secrets.secureboot-PK // {
              file = "${removeSuffix ".age" config.age.secrets.secureboot-PK.file + ".crt"}";
            };
          };
          script = "secureboot-key";
          tags = [ "secureboot" ];
        };
      };
      age.secrets.secureboot-db = {
        rekeyFile = keyInPath + /db/db.age;
        path = keyOutPath + "/db.key";
        generator = {
          dependencies = {
            inherit (config.age.secrets) secureboot-GUID secureboot-KEK;
            signingKey = config.age.secrets.secureboot-KEK;
            signingCrt = config.age.secrets.secureboot-KEK // {
              file = "${removeSuffix ".age" config.age.secrets.secureboot-KEK.file + ".crt"}";
            };
          };
          script = "secureboot-key";
          tags = [ "secureboot" ];
        };
      };
      home.file = mkIf (cfg.non-nixos.enable) (
        publicFiles [ "PK" "KEK" "db" ] [ "crt" "esl" "cer" "auth" ]
      );
    }
    # Nixos only
    (mkIf (!config.baseline.non-nixos.enable) {
      environment.systemPackages = with pkgs; [
        sbctl
        efitools
        efivar
      ];
    })
  ]);

}
