{
  inputs,
  withSystem,
  config,
  ...
}:
{
  flake = {
    nixosConfigurations."piezo" = withSystem "x86_64-linux" (
      { system, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = builtins.attrValues config.flake.nixosModules ++ [ ./piezo ];
      }
    );
  };
}
