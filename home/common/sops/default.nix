self:
{
  lib,
  configVars ? {
    enableSops = false;
  },
  ...
}:
let
  imports = lib.optionals (configVars.enableSops) [
    self.inputs.sops.homeManagerModules.sops
    (import ./.)
  ];
in
{
  inherit imports;
}
