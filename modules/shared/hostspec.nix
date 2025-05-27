{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    str
    enum
    ;
in
{
  options.baseline.hostspec = {
    hostname = mkOption {
      type = str;
      default = "unspecified";
      description = ''
        hostname of the host is used for networking
      '';
    };
    platform = mkOption {
      type = enum [
        "nixos"
        "hm"
      ];
    };
  };
}
