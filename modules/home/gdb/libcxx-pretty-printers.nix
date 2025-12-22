{
  libcxxStdenv,
  libcxx ? libcxxStdenv.cc.libcxx,
  stdenvNoCC,
}:
let
  inherit (libcxx) src version;
  pythonName = "libcxx_${builtins.replaceStrings [ "." ] [ "_" ] version}_pretty_printers";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "libcxx-pretty-printers";
  inherit src version;
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp libcxx/utils/gdb/libcxx/printers.py $out/${pythonName}.py
    runHook postInstall
  '';
  passthru.gdbinit = ''
    python
    import sys
    sys.path.insert(0, '${finalAttrs.finalPackage}')
    from ${pythonName} import register_libcxx_printer_loader
    register_libcxx_printer_loader()
    end
  '';

})
