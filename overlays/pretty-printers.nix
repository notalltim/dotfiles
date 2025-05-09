inputs: final: _: {
  gcc-pretty-printers = final.callPackage ../pkgs/gcc-pretty-printers.nix {
    src = inputs.gcc-python-pretty-printers;
  };
}
