{
  nixvim = import ./common/nixvim;
  terminal = import ./common/terminal;
  tool = import ./common/tools;
  services = import ./common/services;
  packages = import ./common/packages.nix;
  home-manager = import ./common/home-manager.nix;
  gpu = import ./common/gpu.nix;
  nix = import ./common/nix.nix;
  nixpkgs = import ./common/nixpkgs;
}
