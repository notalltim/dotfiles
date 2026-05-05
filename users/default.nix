{ self, ... }:
{
  flake = {
    nixosModules.user-tgallion = ./tgallion/user.nix;
    homeModules.user-tgallion = ./tgallion;
  };
  perSystem = _: { agenix-rekey.homeConfigurations = self.homeConfigurations; };
}
