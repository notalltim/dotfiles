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
      nixvim = (inputs.nixvim.homeModules or inputs.nixvim.homeManagerModules).nixvim;
      agenix = inputs.agenix.homeManagerModules.default;
      agenix-rekey = import "${inputs.agenix-rekey}/modules/agenix-rekey.nix" inputs.nixpkgs;
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
      (lib.attrsets.concatMapAttrs (name: value: { "config-${name}" = value; }) {
        nixvim = ./home/nixvim;
        terminal = ./home/terminal;
        tool = ./home/tools;
        home-manager = ./home/home-manager.nix;
        nix = ./home/nix.nix;
        non-nixos = ./home/non-nixos.nix;
        secrets = ./home/secrets;
        ssh = ./home/ssh.nix;
        firefox = ./home/firefox.nix;
        stylix = ./home/stylix.nix;
        apps = ./home/apps.nix;
        hyprland = ./home/hyprland;
        ulauncher = ./home/ulauncher.nix;
        waybar = ./home/waybar;
        wlogout = ./home/wlogout;
        spotify = ./home/spotify.nix;
        "25-05-compat" = ./home/25-05-compat.nix;
      })
      // shared
      // homeUpstream;
    nixosModules =
      (lib.attrsets.concatMapAttrs (name: value: { "config-${name}" = value; }) {
        secrets = ./nixos/secrets.nix;
        home-manager = ./nixos/home-manager.nix;
        nixos = ./nixos/nixos.nix;
        audio = ./nixos/audio.nix;
        networking = ./nixos/networking.nix;
        greetd = ./nixos/greetd.nix;
        spotify = ./nixos/spotify.nix;
        passthru = ./shared/passthru.nix;
        hyprland = ./nixos/hyprland.nix;
        secureboot = ./nixos/secureboot.nix;
        displays = ./nixos/displays.nix;
        "25-05-compat" = ./nixos/25-05-compat.nix;
      })
      // shared
      // nixosUpstream;
  };
}
