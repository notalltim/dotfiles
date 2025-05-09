{
  inputs,
  withSystem,
  config,
  self,
  ...
}:
{
  flake = {
    homeConfigurations.${"tgallion"} = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = (builtins.attrValues config.flake.homeModules) ++ [ ./tgallion ];
        extraSpecialArgs = {
          nonNixos = true;
          inherit self;
        };
      }
    );
  };
}
