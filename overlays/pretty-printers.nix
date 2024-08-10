{self}: final: _: {
  gcc-pretty-printers = final.callPackage ../pkgs/gcc-pretty-printers.nix {src = self.inputs.gcc-python-pretty-printers;};
}
