{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    escapeShellArg
    optionalString
    zipListsWith
    ;
  inherit (lib.types)
    path
    nullOr
    str
    listOf
    submodule
    bool
    enum
    ;
  cfg = config.nix;
  # Additions to the nix home-manager module to support generating netrc and access-tokens along with build time fetcher support
in
{
  options.nix = {
    enableBuildTimeFetchers = mkOption {
      type = bool;
      default = false;
      description = ''
        Enable build time fetchers this requires the user to be in to root group. 
        It also forces specific ownership and permissions on netrc and containing folders
      '';
    };
    netrc = {
      enabled = mkOption {
        type = bool;
        readOnly = true;
        default = cfg.netrc.logins != [ ];
        description = ''
          Read only option to indicate that a netrc file will be generated
        '';
      };
      file = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          The file path relative to the current flake that the generated secret will be stored in
        '';
      };
      logins = mkOption {
        type = listOf (submodule {
          options = {
            url = mkOption {
              type = str;
              description = ''
                URL of the site that access is granted to by this token
              '';
            };
            user = mkOption {
              type = str;
              default = config.home.username;
              description = ''
                The user name to be used after login in the netrc
              '';
            };
            pubkey = mkOption {
              type = nullOr str;
              default = null;
              description = ''
                If there is an associated public key then add it here and it is added to the `trusted-public-keys` in the nix conf
              '';
            };
            secret = mkOption {
              type = options.age.secrets.type.nestedTypes.elemType;
              description = ''
                secret containing the password portion of the expression. Does not need to be unique but should be from age.secrets
              '';
            };
          };
        });
        default = [ ];
        description = ''
          Logins to add to the netrc file and to the binary cache (if the cache is a binary cache).
          In the format `machine ''${login.url} login ''${login.user} password ''${login.secret.file}`
        '';
      };
    };
    access-tokens = {
      enabled = mkOption {
        type = bool;
        readOnly = true;
        default = cfg.access-tokens.tokens != [ ];
        description = ''
          read only option to indicate that access tokens will be generated  
        '';
      };

      file = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          Location of the file relative to the current flake that the generated access tokens will be stored in
        '';
      };
      tokens = mkOption {
        type = listOf (submodule {
          options = {
            url = mkOption {
              type = str;
              description = ''
                URL the token is associated with
              '';
            };
            tokenType = mkOption {
              type = nullOr (enum [
                "OAuth2"
                "PAT"
              ]);
              default = null;
              description = ''
                type if any that should be added in front of the token e.g. PAT:...
              '';
            };
            secret = mkOption {
              type = options.age.secrets.type.nestedTypes.elemType;
              description = ''
                secret containing the password portion of the expression. Does not need to be unique but should be from age.secrets
              '';
            };
          };
        });
        default = [ ];
        description = ''
          access tokens to add to the `access-tokens` section of the nix conf  
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.access-tokens.enabled -> cfg.access-tokens.file != null;
        message = "Access location for the generated access tokens must be provided if `config.baseline.nix.access-tokens` is populated";
      }
      {
        assertion = cfg.netrc.enabled -> cfg.netrc.file != null;
        message = "A location for the generated netrc must be provided if `config.baseline.nix.netrc.logins` is populated";
      }
    ];

    # Support build time fetchers
    home.activation = mkIf cfg.enableBuildTimeFetchers {
      chownHome = (
        builtins.concatStringsSep "\n" (
          builtins.map
            (path: ''
              chown ${config.home.username}:root ${path}
              chmod 710 ${path}
            '')
            [
              "${config.home.homeDirectory}"
              "${config.home.homeDirectory}/.config"
              "${config.home.homeDirectory}/.config/nix "
            ]
        )
      );
    };

    age.secrets = {
      netrc = mkIf cfg.netrc.enabled {
        rekeyFile = cfg.netrc.file;
        path = "${config.xdg.configHome}/nix/netrc";
        # Support build time fetchers
        symlink = !cfg.enableBuildTimeFetchers;
        mode = optionalString cfg.enableBuildTimeFetchers "0644";
        group = optionalString cfg.enableBuildTimeFetchers "root";
        generator = {
          dependencies = (builtins.map (val: val.secret) cfg.netrc.logins);
          tags = [
            "nix"
            "netrc"
          ];
          script =
            { decrypt, ... }:
            builtins.concatStringsSep "\n" (
              builtins.map (
                key:
                "printf 'machine ${key.url} login ${key.user} password %s\n' $(${decrypt} ${escapeShellArg key.secret.rekeyFile})"
              ) cfg.netrc.logins
            );
        };
      };

      nix-access-tokens = mkIf cfg.access-tokens.enabled {
        rekeyFile = cfg.access-tokens.file;
        path = "${config.xdg.configHome}/nix/access-tokens.conf";
        generator = {
          tags = [
            "nix"
            "nix-access-tokens"
          ];
          dependencies = (builtins.map (val: val.secret) cfg.access-tokens.tokens);
          script =
            { decrypt, deps, ... }:
            ''
              printf 'access-tokens = '
            ''
            + (builtins.concatStringsSep "\n" (
              zipListsWith (
                secret: meta:
                "printf '${meta.url}=${
                  optionalString (meta.tokenType != null) (meta.tokenType + ":")
                }%s ' $(${decrypt} ${escapeShellArg meta.secret.rekeyFile})"
              ) deps cfg.access-tokens.tokens
            ));
        };
      };
    };

    nix = {
      extraOptions = mkIf (cfg.access-tokens.enabled) ''
        !include ${config.age.secrets.nix-access-tokens.path}
      '';

      settings =
        let
          filterdCaches = (builtins.filter (val: val.pubkey != null) cfg.netrc.logins);
        in
        {
          netrc-file = mkIf cfg.netrc.enabled config.age.secrets.netrc.path;
          substituters = [
            "https://cache.nixos.org"
          ]
          ++ (builtins.map (val: "https://${val.url}") filterdCaches);
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ]
          ++ (builtins.map (val: val.pubkey) filterdCaches);
        };
    };
  };
}
