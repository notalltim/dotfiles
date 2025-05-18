{ inputs, lib, ... }:
let
  inherit (lib.fixedPoints) composeManyExtensions;
  inherit (lib.attrsets) attrValues;
  overlays = {
    fenix = inputs.fenix.overlays.default;
    nixgl = inputs.nixgl.overlays.default;
    agenix = inputs.agenix.overlays.default;
    agenix-rekey = inputs.agenix-rekey.overlays.default;
    packages = import ./packages.nix inputs;
    # nix = self.inputs.nix.overlays.default;
    packageOverrides = import ./overrides.nix;
  };
in
{
  flake.overlays = overlays // {
    default = composeManyExtensions (attrValues overlays);
  };
}
