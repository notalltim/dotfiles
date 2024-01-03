{ pkgs }:
let
  fs = pkgs.lib.fileset;
  config = {
    enable = true;
    defaultEditor = true;
  };

  files = {
    ".config/nvim".source =
      (pkgs.stdenvNoCC.mkDerivation
        rec {
          name = "astronvim";
          version = "3.40.3";
          src = (pkgs.fetchFromGitHub {
            owner = "AstroNvim";
            repo = "AstroNvim";
            rev = "v${version}";
            hash = "sha256-h019vKDgaOk0VL+bnAPOUoAL8VAkhY6MGDbqEy+uAKg=";
          });
          user = ./.;
          preInstall = ''
            ls -R $src
            ls -R $user
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/lua/user
            cp -r $src/* $out
            ls $out
            cp -r $user/* $out/lua/user
            runHook postInstall
          '';
        }).outPath;
  };
in
{ inherit config; inherit files; }
