{ inputs, ... }:
{
  flake = {
    homeModules = {
      nixvim = import ./home/nixvim;
      terminal = import ./home/terminal;
      tool = import ./home/tools;
      services = import ./home/services;
      packages = import ./home/packages.nix;
      home-manager = import ./home/home-manager.nix;
      nix = import ./home/nix.nix;
      nixpkgs = import ./home/nixpkgs;
      nixvimUpstream = inputs.nixvim.homeManagerModules.nixvim;
      non-nixos = import ./home/non-nixos.nix;
      secrets = import ./home/secrets;
      ssh = import ./home/ssh.nix;
      agenix = inputs.agenix.homeManagerModules.default;
      agenix-rekey = inputs.agenix-rekey.homeManagerModules.default;
    };
    nixosModules = {
      disko = inputs.disko.nixosModules.default;
    };
  };
}
