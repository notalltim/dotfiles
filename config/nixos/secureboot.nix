{
  config,
  lib,
  pkgs,
  baselineLib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    escapeShellArg
    removeSuffix
    removePrefix
    getExe
    getExe'
    mapAttrsToList
    filterAttrs
    concatStringsSep
    mkMerge
    mapAttrs
    ;
  inherit (lib.types)
    nullOr
    path
    submodule
    str
    attrsOf
    enum
    ;
  inherit (baselineLib) mkPathReproducible;
  cfg = config.baseline.secureboot;
  inherit (config.baseline.host) hostPath hostname;
  fromSecret =
    file: srcExt: ext:
    escapeShellArg (removeSuffix ".${srcExt}.age" file + ".${ext}");
  decryptFile = decrypt: file: "${decrypt} ${escapeShellArg file}";

  securebootTags = [
    "secureboot"
    "secureboot-${hostname}"
  ];
in
{
  options.baseline.secureboot = {
    enable = mkEnableOption "Enable secureboot configuration";
    enableMicrosoftKeys = mkEnableOption "Enable microsoft signing keys" // {
      default = true;
    };
    pkiPath = mkOption {
      type = nullOr path;
      default = hostPath + "/secureboot";
    };
    factorySignatures = mkOption {
      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              name = mkOption {
                type = str;
                default = name;
              };
              file = mkOption {
                apply = mkPathReproducible;
                type = path;
              };
              type = mkOption {
                type = enum [
                  "db"
                  "KEK"
                ];
              };
            };
          }
        )
      );
      default = { };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableMicrosoftKeys) {
      baseline.secureboot.factorySignatures =
        let
          fetchMicrosoft =
            {
              name,
              id,
              hash,
              ...
            }:
            {
              fetchurl,
              sbsigntool,
              runCommand,
            }:
            let
              src = fetchurl {
                url = "https://go.microsoft.com/fwlink/p/?linkid=${id}";
                inherit hash name;
              };
            in
            runCommand "${name}.esl" { } ''
              ${sbsigntool}/bin/sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output $out ${src}
            '';
        in
        mapAttrs
          (name: info: {
            inherit (info) type;
            file = (pkgs.callPackage (fetchMicrosoft (info // { inherit name; })) { });
          })
          {
            "ms-db-2011" = {
              id = "321192";
              hash = "sha256-6OlfBzOlXoute+ChQT7iPFH86mSzyPpqeGk1/dzHGWE=";
              type = "db";
            };
            "ms-kek-2011" = {
              id = "321185";
              hash = "sha256-oRF/UWoyzvy6Py0azhCoeXL9a76P4NC5luCeZdgCpQM=";
              type = "KEK";
            };
            "ms-uefi-db-2011" = {
              id = "321194";
              hash = "sha256-SOmbmR9X/FL3YUlZm/8KWMRxVCKbn41gOsQNNQAkhQc=";
              type = "db";
            };
            "ms-db-2023" = {
              id = "2239776";
              hash = "sha256-B28f6pCsKRVev3fBdoL3Xx/dG+GW2jAtyEYeNQqa4zA=";
              type = "db";
            };
            "ms-kek-2023" = {
              id = "2239775";
              hash = "sha256-PNPwMJ7a4ih2epdt1A2fSv/E+9Uhjy6Mw8ndl+isb50=";
              type = "KEK";
            };
            "ms-uefi-db-2023" = {
              id = "2239872";
              hash = "sha256-9hJONBJb7j/m15pXTqp7kcDnvZ2SnBoyEXjv1hHa2QE=";
              type = "db";
            };
          };
    })
    (mkIf (cfg.enable) {
      age = {
        generators =
          let
            authScript =
              {
                name,
                pkgs,
                crtFile,
                keyCommand,
                keyCrt,
                eslFile,
                guidCommand,
              }:
              let
                cert-to-efi-sig-list = getExe' pkgs.efitools "cert-to-efi-sig-list";
                sign-efi-sig-list = getExe' pkgs.efitools "sign-efi-sig-list";
                mkfifo = getExe' pkgs.coreutils "mkfifo";
                printf = getExe' pkgs.coreutils "printf";
                rm = getExe' pkgs.coreutils "rm";
                cat = getExe' pkgs.coreutils "cat";
                factorySignatures = concatStringsSep " " (
                  mapAttrsToList (_: sig: "${sig.file}") (
                    filterAttrs (_: sig: sig.type == name) cfg.factorySignatures
                  )
                );
              in
              ''
                ${mkfifo} priv_key_pipe auth_pipe
                ${keyCommand} > priv_key_pipe &
                ${printf} "\tGenerating ${name} ESL\n" >&2
                ${cert-to-efi-sig-list} -g "$(${guidCommand})" ${crtFile} ${eslFile}
                ${cat} /dev/null ${factorySignatures} >> ${eslFile}

                ${printf} "\tSigning ${name} ESL to Auth\n" >&2
                ${sign-efi-sig-list} -g "$(${guidCommand})" \
                                     -k priv_key_pipe -c ${keyCrt} \
                                     ${name} ${eslFile} auth_pipe &
                ${cat} auth_pipe
                ${rm} priv_key_pipe auth_pipe
              '';
            keyScript =
              {
                name,
                pkgs,
                crtFile,
                cerFile,
              }:
              let
                openssl = getExe pkgs.openssl;
                mkfifo = getExe' pkgs.coreutils "mkfifo";
                printf = getExe' pkgs.coreutils "printf";
                rm = getExe' pkgs.coreutils "rm";
                cat = getExe' pkgs.coreutils "cat";
              in
              ''
                ${mkfifo} key_pipe
                ${printf} "\tGenerating ${name} Key and CRT\n" >&2
                ${openssl} req -newkey rsa:4096 -nodes \
                               -keyout key_pipe -new -x509 -sha256 \
                               -days 3650 -subj "/CN=${hostname} ${name}/" \
                               -out ${crtFile} 2> /dev/null &
                ${cat} key_pipe
                ${printf} "\tGenerating ${name} DER\n" >&2
                ${openssl} x509 -outform DER -in ${crtFile} -out ${cerFile}
                ${rm} key_pipe
              '';
          in
          {
            GUID =
              { pkgs, ... }:
              ''
                ${pkgs.util-linux}/bin/uuidgen --random
              '';

            secureboot-key =
              {
                pkgs,
                file,
                name,
                ...
              }:
              keyScript {
                inherit pkgs;
                name = (removeSuffix "-key" (removePrefix "secureboot-" name));
                crtFile = fromSecret file "key" "crt";
                cerFile = fromSecret file "key" "cer";
              };

            secureboot-auth =
              {
                pkgs,
                decrypt,
                deps,
                name,
                file,
                ...
              }:
              authScript {
                inherit pkgs;
                name = (removeSuffix "-auth" (removePrefix "secureboot-" name));
                guidCommand = decryptFile decrypt deps.secureboot-GUID.file;
                keyCommand = decryptFile decrypt deps.signingKey.file;
                keyCrt = fromSecret deps.signingKey.file "key" "crt";
                crtFile = fromSecret file "auth" "crt";
                eslFile = fromSecret file "auth" "esl";
              };

            noPK =
              {
                pkgs,
                decrypt,
                deps,
                ...
              }:
              authScript {
                inherit pkgs;
                name = "PK";
                guidCommand = decryptFile decrypt deps.secureboot-GUID.file;
                keyCommand = decryptFile decrypt deps.secureboot-PK-key.file;
                keyCrt = fromSecret deps.secureboot-PK-key.file "key" "crt";
                crtFile = "/dev/null";
                eslFile = "/dev/null";
              };

          };
        secrets = {

          secureboot-GUID = {
            rekeyFile = cfg.pkiPath + "/GUID.age";
            generator = {
              script = "GUID";
              tags = securebootTags ++ [ "secureboot-GUID-${hostname}" ];
            };
          };

          secureboot-PK-key = {
            rekeyFile = cfg.pkiPath + "/keys/PK/PK.key.age";
            generator = {
              script = "secureboot-key";
              tags = securebootTags ++ [ "secureboot-PK-${hostname}-key" ];
            };
          };

          secureboot-PK-auth = {
            rekeyFile = cfg.pkiPath + "/keys/PK/PK.auth.age";
            generator = {
              script = "secureboot-auth";
              dependencies = {
                inherit (config.age.secrets) secureboot-GUID secureboot-PK-key;
                signingKey = config.age.secrets.secureboot-PK-key;
              };
              tags = securebootTags;
            };
          };

          secureboot-noPK-auth = {
            rekeyFile = cfg.pkiPath + "/keys/noPK/noPK.auth.age";
            generator = {
              dependencies = { inherit (config.age.secrets) secureboot-GUID secureboot-PK-key; };
              script = "noPK";
              tags = securebootTags;
            };

          };

          secureboot-KEK-key = {
            rekeyFile = cfg.pkiPath + "/keys/KEK/KEK.key.age";
            generator = {
              script = "secureboot-key";
              tags = securebootTags ++ [ "secureboot-KEK-${hostname}-key" ];
            };
          };

          secureboot-KEK-auth = {
            rekeyFile = cfg.pkiPath + "/keys/KEK/KEK.auth.age";
            generator = {
              script = "secureboot-auth";
              dependencies = {
                inherit (config.age.secrets) secureboot-GUID secureboot-PK-key secureboot-KEK-key;
                signingKey = config.age.secrets.secureboot-PK-key;
              };
              tags = securebootTags;
            };
          };

          secureboot-db-key = {
            rekeyFile = cfg.pkiPath + "/keys/db/db.key.age";
            generator = {
              script = "secureboot-key";
              tags = securebootTags ++ [ "secureboot-db-${hostname}-key" ];
            };
          };

          secureboot-db-auth = {
            rekeyFile = cfg.pkiPath + "/keys/db/db.auth.age";
            generator = {
              script = "secureboot-auth";
              dependencies = {
                inherit (config.age.secrets) secureboot-GUID secureboot-KEK-key secureboot-db-key;
                signingKey = config.age.secrets.secureboot-KEK-key;
              };
              tags = securebootTags;
            };
          };
        };
      };
      # Nixos only
      environment.systemPackages = with pkgs; [
        sbctl
        efitools
        efivar
      ];
    })
  ];
}
