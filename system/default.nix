{ config
, pkgs
, lib
, nixosModulesPath
, ...
}: {
  imports = map (path: nixosModulesPath + path) [
    "/programs/wireshark.nix"
    "/security/wrappers"
  ];
  options = {
    # No-op option for now.
    security.apparmor = {
      includes = lib.mkOption {
        internal = true;
        default = { };
        type = lib.types.attrs;
      };
    };
    environment.extraInit = lib.mkOption {
      default = "";
      internal = true;
      type = lib.types.lines;
    };
    system.checks = lib.mkOption {
      default = [ ];
      internal = true;
      type = lib.types.list;
    };
  };
  config = {
    system-manager.allowAnyDistro = true;
    # Not supported at the moment
    programs.wireshark.enable = true;
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
