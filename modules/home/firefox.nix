{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkEnableOption
    mkIf
    mkOption
    listToAttrs
    nameValuePair
    ;
  inherit (lib.types) str;
  cfg = config.baseline.firefox;
  addons = pkgs.nur.repos.rycee.firefox-addons;
  perProfile = names: attrs: listToAttrs (map (name: nameValuePair name attrs) names);
in
{
  options.baseline.firefox = {
    enable = mkEnableOption "Enable firefox configuration";
    profile = mkOption {
      type = str;
      default = config.home.username;
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      programs.firefox = {
        enable = true;
        package = config.lib.nixGL.wrap pkgs.firefox;
      };
    }
    {
      programs.firefox.profiles = (
        perProfile
          ([
            cfg.profile
          ])
          {
            extensions = {
              packages = with addons; [ bitwarden ];
            };

            settings = {
              "extensions.autoDisableScopes" = 0;
            };

            bookmarks = {
              force = true;
              settings = [
                {
                  toolbar = true;
                  name = "toolbar";
                  bookmarks = [
                    {
                      name = "nixpkgs-manual";
                      url = "https://nixos.org/manual/nixpkgs/stable/";
                      tags = [
                        "docs"
                        "nix"
                      ];
                    }
                  ];
                }
              ];
            };

            search = {
              force = true;
              engines = {
                nix-packages = {
                  name = "Nix Packages";
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "channel";
                          value = "25.05";
                        }
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "@np"
                    "@nixpkgs"
                  ];
                };
                nixos-options = {
                  name = "NixOS Options";
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        {
                          name = "channel";
                          value = "25.05";
                        }
                        {
                          name = "type";
                          value = "options";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "@no"
                    "@nixos"
                  ];
                };

                home-manager = {
                  name = "Home Manager";
                  urls = [
                    {
                      template = "https://home-manager-options.extranix.com";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                        {
                          name = "release";
                          # TODO: this should be 25.05 but it is not up yet
                          value = "master";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "@hm"
                    "@home-manager"
                  ];
                };

                nixos-wiki = {
                  name = "NixOS Wiki";
                  urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
                  iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                  definedAliases = [ "@nw" ];
                };

                github = {
                  name = "Github";
                  urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
                  iconMapObj."32" = "https://github.com/favicon.ico";
                  definedAliases = [
                    "@gh"
                    "@github"
                  ];
                };

                noogle = {
                  name = "Noogle";
                  urls = [ { template = "https://noogle.dev/q?q={searchTerms}&term={searchTerms}"; } ];
                  iconMapObj."256" = "https://noogle.dev/favicon.ico";
                  definedAliases = [
                    "@ng"
                    "@noogle"
                  ];
                };

                bing.metaData.hidden = true;
              };
            };
          }
      );
    }
  ]);
}
