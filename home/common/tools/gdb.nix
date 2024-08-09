{
  pkgs,
  config,
  lib,
  self,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  pretty-printers = pkgs.stdenvNoCC.mkDerivation {
    name = "gcc-python-pretty-printers";
    version = "13.3";
    src = self.inputs.gcc-python-pretty-printers;
    dontConfigure = true;
    dontBuild = true;
    dontPatch = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/python
      cp -r $src/libstdc++-v3/python $out
      runHook postInstall
    '';
  };
  cfg = config.baseline.gdb;
in {
  options = {
    baseline.gdb = {
      enable = mkEnableOption "Enable GDB configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.gdb
      pkgs.valgrind
      (lib.getBin (pkgs.elfutils.override {enableDebuginfod = true;}))
    ];
    home.file.".gdbinit".text = ''
      set debuginfod enabled on
      python
      import sys
      sys.path.insert(0, '${pretty-printers}/python')
      from libstdcxx.v6.printers import register_libstdcxx_printers
      register_libstdcxx_printers (None)
    '';
  };
}
