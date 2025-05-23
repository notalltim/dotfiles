{
  inputs,
  withSystem,
  config,
  self,
  ...
}:
{
  flake = {
    homeConfigurations.${"tgallion@aurora"} = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = (builtins.attrValues config.flake.homeModules) ++ [ ./tgallion ];
        extraSpecialArgs = {
          hostPubkey = ../hosts/aurora/id_ed25519.pub;
          hostSecrets = ../hosts/aurora/secrets;
          nonNixos = true;
          inherit self;
        };
      }
    );
  };
  perSystem =
    { ... }:
    {
      agenix-rekey.homeConfigurations = self.homeConfigurations;
    };
}
