{ ulauncher, lib, ... }:
let
  inherit (lib) optional;
  inherit (lib.versions) major;
in
ulauncher.overrideAttrs (old: {
  patches =
    old.patches
    ++ optional ((major old.version) == "5") ./uwsm-launcher-v5.patch
    ++ optional ((major old.version) == "6") ./uwsm-launcher-v6.patch;
})
