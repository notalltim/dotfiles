{ stdenv }:
stdenv.mkDerivation {
  pname = "gcc-pretty-printers";
  inherit (stdenv.cc.cc) src version;
  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/python
    cp -r libstdc++-v3/python $out
    runHook postInstall
  '';
}
