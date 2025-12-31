{
  self,
  ...
}:
{
  flake = {
    nixosModules.user-tgallion = ./tgallion/user.nix;
    homeModules.user-tgallion = ./tgallion;
  };
  perSystem =
    { ... }:
    {
      agenix-rekey.homeConfigurations = self.homeConfigurations;
    };
}
