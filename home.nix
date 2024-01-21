{
  homeDirectory,
  pkgs,
  stateVersion,
  system,
  username,
  email,
  signingKey ? "",
  useAstro ? false,
}: let
  isHome = email == "timbama@gmail.com";
  internalLib = import ./lib.nix {inherit pkgs isHome;};
  packages = import ./packages.nix {inherit pkgs internalLib isHome;};
in rec {
  home = {
    inherit homeDirectory packages stateVersion username;
    enableDebugInfo = true;
    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };
  };
  imports =
    [./terminal ./tools ./services]
    ++ (
      if useAstro
      then [./editor/astronvim]
      else [./editor/neovim]
    )
    ++ (
      if isHome
      then []
      else [./system/display.nix]
    );

  _module.args.internalLib = internalLib;
  _module.args.userEmail = email;
  _module.args.signingKey = signingKey;
  _module.args.isHome = isHome;

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.enable = true;
  news.display = "silent";
  manual = {
    html.enable = true;
    json.enable = true;
    manpages.enable = true;
  };

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    };
  };
}
