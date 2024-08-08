{
  config,
  lib,
  self,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixpkgs;
in {
  options.baseline.nixpkgs = {
    enable = mkEnableOption "nixpkgs config managments";
  };

  config = mkIf cfg.enable {
    nixpkgs = {
      config = import ./nixpkgs-config.nix;
      overlays = [self.inputs.nixgl.overlays.default self.inputs.fenix.overlays.default];
    };
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };
}
