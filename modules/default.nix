{
  flake = {
    homeModules = {
      nix-enterprise = ./home/nix-enterprise.nix;
      agenix-chown = ./home/agenix-chown.nix;
      nixseparatedebuginfod = ./home/nixseparatedebuginfod.nix;
      yubi-touch-detector = ./home/yubi-touch-detector.nix;
      gdb = ./home/gdb;
    };

    nixosModules = {
      fingerprint = ./nixos/fingerprint.nix;
    };
  };
}
