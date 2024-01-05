{ homeDirectory
, pkgs
, stateVersion
, system
, username
}:

let
  packages = import ./packages.nix { inherit pkgs; };
  configs = import ./programs { inherit pkgs; };
  file = configs.files;
in
rec {
  home = {
    inherit homeDirectory packages stateVersion username file;

    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };
  };

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    };
  };
  programs = configs.programs;

  services = import ./services;
}
