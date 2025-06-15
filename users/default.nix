{
  self,
  ...
}:
{
  flake = {
    nixosModules.tgallion = ./tgallion/user.nix;
    homeModules.tgallion = ./tgallion;
  };
  perSystem =
    { ... }:
    {
      agenix-rekey.homeConfigurations = self.homeConfigurations;
    };
}
