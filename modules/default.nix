{ inputs, lib, ... }:
let
  shared = (
    lib.attrsets.concatMapAttrs (name: value: { "shared-${name}" = value; }) {
      secrets = ./shared/secrets;
      userspec = ./shared/userspec.nix;
      hostspec = ./shared/hostspec.nix;
    }
  );
in
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
      nixvimUpstream = inputs.nixvim.homeManagerModules.nixvim;
      non-nixos = import ./home/non-nixos.nix;
      secrets = import ./home/secrets;
      ssh = import ./home/ssh.nix;
      agenix = inputs.agenix.homeManagerModules.default;
      agenix-rekey = inputs.agenix-rekey.homeManagerModules.default;
    } // shared;
    nixosModules = {
      disko = inputs.disko.nixosModules.default;
      home-manager = inputs.home-manager.nixosModules.home-manager;
      agenix = inputs.agenix.nixosModules.default;
      agenix-rekey = inputs.agenix-rekey.nixosModules.default;
      secrets = ./nixos/secrets.nix;
    } // shared;
  };
}
