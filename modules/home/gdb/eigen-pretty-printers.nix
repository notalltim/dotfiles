{ eigen, stdenvNoCC }:
let
  inherit (eigen) src version;
  pythonName = "eigen_${builtins.replaceStrings [ "." "-" ] [ "_" "_" ] version}_pretty_printers";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eigen-pretty-printers";
  inherit src version;
  phases = [
    "unpackPhase"
    "patchPhase"
    "installPhase"
  ];
  patches = [ ./regex-fix.patch ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp debug/gdb/printers.py $out/${pythonName}.py
    runHook postInstall
  '';
  passthru.gdbinit = ''
    python
    import sys
    sys.path.insert(0, '${finalAttrs.finalPackage}')
    from ${pythonName} import register_eigen_printers
    register_eigen_printers(None)
    end
  '';

})
