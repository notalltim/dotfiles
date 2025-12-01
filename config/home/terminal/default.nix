{ lib, ... }:
let
  inherit (lib.options) mkEnableOption;
in
{
  imports = [
    ./fish.nix
    ./kitty.nix
    ./zellij.nix
    ./starship.nix
  ];
  options = {
    baseline.terminal.enable = mkEnableOption "Enable baseline terminal / shell configuration";
  };
}
