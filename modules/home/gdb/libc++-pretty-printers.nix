{ stdenv, stdenvNoCC }:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gcc-pretty-printers";
  inherit (stdenv.cc.cc) src version;
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/python
    cp -r libstdc++-v3/python $out
    runHook postInstall
  '';

  passthru.gdbinit = ''
    python
    import sys
    sys.path.insert(0, '${finalAttrs.finalPackage}/python')
    from libstdcxx.v6.printers import register_libstdcxx_printers
    register_libstdcxx_printers(None)
    end
  '';

})
