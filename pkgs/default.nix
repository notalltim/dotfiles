{
  config,
  inputs,
  ...
}:
{
  perSystem =
    {
      system,
      pkgs,
      ...
    }:
    {
      legacyPackages = pkgs;
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          config.flake.overlays.default
        ];
      };
    };
}
