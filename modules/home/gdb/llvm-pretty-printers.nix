{
  clangStdenv,
  libllvm ? clangStdenv.cc.cc.libllvm,
  stdenvNoCC,
}:
let
  inherit (libllvm) src version;
  pythonName = "llvm_${builtins.replaceStrings [ "." ] [ "_" ] version}_pretty_printers";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "llvm-pretty-printers";
  inherit src version;
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp llvm/utils/gdb-scripts/prettyprinters.py $out/${pythonName}.py
    runHook postInstall
  '';
  passthru.gdbinit = ''
    python
    import sys
    sys.path.insert(0, '${finalAttrs.finalPackage}')
    import ${pythonName}
    end
  '';

})
