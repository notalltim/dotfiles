{ inputs, lib, ... }:
let
  inherit (lib.fixedPoints) composeManyExtensions;
  inherit (lib.attrsets) attrValues;
  overlays = {
    pretty-printers = import ./pretty-printers.nix inputs;
    fenix = inputs.fenix.overlays.default;
    nixgl = inputs.nixgl.overlays.default;
    # nix = self.inputs.nix.overlays.default;
  };
in
{
  flake.overlays = overlays // {
    default = composeManyExtensions (attrValues overlays);
  };
}
