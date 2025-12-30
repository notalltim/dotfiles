{
  flake = {
    homeModules = {
      nix-enterprise = ./home/nix-enterprise.nix;
      agenix-chown = ./home/agenix-chown.nix;
      nixseparatedebuginfod = ./home/nixseparatedebuginfod.nix;
      yubi-touch-detector = ./home/yubi-touch-detector.nix;
      gdb = ./home/gdb;
      auto-gc-roots = ./home/auto-gc-roots;
    };

    nixosModules = {
      fingerprint = ./nixos/fingerprint.nix;
    };
  };
}
