{ self, lib }:
let
  inherit (lib.fixedPoints) composeManyExtensions;
  inherit (lib.attrsets) attrValues;
  overlays = {
    pretty-printers = import ./pretty-printers.nix { inherit self; };
    fenix = self.inputs.fenix.overlays.default;
    nixgl = self.inputs.nixgl.overlays.default;
    nix = self.inputs.nix.overlays.default;
  };
in
overlays // { default = composeManyExtensions (attrValues overlays); }
