{ inputs, lib, ... }:
let
  shared = (
    lib.attrsets.concatMapAttrs (name: value: { "shared-${name}" = value; }) {
      secrets = ./shared/secrets;
      userspec = ./shared/userspec.nix;
      hostspec = ./shared/hostspec.nix;
      stylix = ./shared/stylix.nix;
      lib = ./shared/lib.nix;
    }
  );
  homeUpstream = (
    lib.attrsets.concatMapAttrs (name: value: { "upstream-${name}" = value; }) {
      spicetify = inputs.spicetify-nix.homeManagerModules.spicetify;
      stylix = inputs.stylix.homeModules.stylix;
      nixvim = inputs.nixvim.homeManagerModules.nixvim;
      agenix = inputs.agenix.homeManagerModules.default;
      agenix-rekey = inputs.agenix-rekey.homeManagerModules.default;
    }
  );
  nixosUpstream = (
    lib.attrsets.concatMapAttrs (name: value: { "upstream-${name}" = value; }) {
      home-manager = inputs.home-manager.nixosModules.home-manager;
      disko = inputs.disko.nixosModules.default;
      agenix = inputs.agenix.nixosModules.default;
      agenix-rekey = inputs.agenix-rekey.nixosModules.default;
      stylix = inputs.stylix.nixosModules.stylix;
    }
  );
in
{
  flake = {
    homeModules =
      {
        nixvim = import ./home/nixvim;
        terminal = import ./home/terminal;
        tool = import ./home/tools;
        services = import ./home/services;
        packages = import ./home/packages.nix;
        home-manager = import ./home/home-manager.nix;
        nix = import ./home/nix.nix;
        non-nixos = import ./home/non-nixos.nix;
        secrets = import ./home/secrets;
        ssh = import ./home/ssh.nix;
        firefox = ./home/firefox.nix;
        stylix = ./home/stylix.nix;
        apps = ./home/apps.nix;
        hyprland = ./home/hyprland;
        ulauncher = ./home/ulauncher.nix;
        waybar = ./home/waybar;
        wlogout = ./home/wlogout;
        spotify = ./home/spotify.nix;
      }
      // shared
      // homeUpstream;
    nixosModules =
      {
        secrets = ./nixos/secrets.nix;
        home-manager = ./nixos/home-manager.nix;
        nixos = ./nixos/nixos.nix;
        audio = ./nixos/audio.nix;
        network-manager = ./nixos/network-manager.nix;
        greetd = ./nixos/greetd.nix;
        spotify = ./nixos/spotify.nix;
        passthru = ./shared/passthru.nix;
        hyprland = ./nixos/hyprland.nix;
        secureboot = ./nixos/secureboot.nix;
      }
      // shared
      // nixosUpstream;
  };
}
