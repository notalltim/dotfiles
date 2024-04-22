{pkgs}: let
  inherit (pkgs) writeShellApplication stdenvNoCC;
in {
  writeNixGLWrapper = runner: package:
    stdenvNoCC.mkDerivation {
      name = package.name;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r ${package}/* $out
        cp -rf $src/* $out
        runHook postInstall
      '';
      src = writeShellApplication {
        name = package.pname;
        runtimeInputs = [package runner];
        text = ''
          ${runner.name} ${package.pname};
        '';
      };
    };
}
