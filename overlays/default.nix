{ self, lib }:
let
  inherit (lib.fixedPoints) composeManyExtensions;
  inherit (lib.attrsets) attrValues;
  overlays = {
    pretty-printers = import ./pretty-printers.nix self;
    fenix = self.inputs.fenix.overlays.default;
    nixgl = self.inputs.nixgl.overlays.default;
  };
in
overlays // { default = composeManyExtensions (attrValues overlays); }
