{ pkgs, ... }: {
  imports =
    [ ./direnv.nix ./eza.nix ./git.nix ./gpg.nix ./home-manager.nix ./gdb.nix ];
}
