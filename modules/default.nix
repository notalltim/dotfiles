{
  flake = {
    homeModules = {
      nix-enterprise = ./home/nix-enterprise.nix;
      agenix-chown = ./home/agenix-chown.nix;
      nixseparatedebuginfod = ./home/nixseparatedebuginfod.nix;
      yubi-touch-detector = ./home/yubi-touch-detector.nix;
    };

    nixosModules = {
      fingerprint = ./nixos/fingerprint.nix;
    };
  };
}
