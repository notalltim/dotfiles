{ src, stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "gcc-pretty-printers";
  version = "13.3";
  inherit src;
  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/python
    cp -r $src/libstdc++-v3/python $out
    runHook postInstall
  '';
}
