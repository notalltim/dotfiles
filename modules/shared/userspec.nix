{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) str;
in
{
  options.baseline.userspec = {
    username = mkOption {
      type = str;
      default = "unspecified";
      description = ''
        primary user on the system
      '';
    };
    fullName = mkOption {
      type = str;
      default = "Unspecified Name";
      description = ''
        Full name in the form "First Last";
      '';
    };
  };
}
