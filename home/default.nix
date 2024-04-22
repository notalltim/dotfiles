{
  nixvim = import ./common/nixvim;
  terminal = import ./common/terminal;
  tool = import ./common/tools;
  services = import ./common/services;
  packages = import ./common/packages.nix;
  home-manager = ./common/home-manager.nix;
}
