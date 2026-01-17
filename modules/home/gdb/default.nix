{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    types
    options
    mkIf
    mkOption
    nameValuePair
    mkMerge
    unique
    ;
  inherit (options) mkEnableOption;
  inherit (types)
    lazyAttrsOf
    str
    enum
    listOf
    ;

  cfg = config.programs.gdb;

in
{
  options = {
    programs.gdb = {
      enable = mkEnableOption "Enable GDB configuration";
      extraConfig = mkOption {
        type = str;
        default = "";
      };
      pretty-printers = {
        selected = mkOption {
          type = listOf (enum (builtins.attrNames cfg.pretty-printers.available));
          default = [ ];
        };
        available = mkOption {
          type = lazyAttrsOf str;
          description = ''
            A set of possible pretty-printers that can be selection with the `pretty-printers.selected` option.
            Lazy to avoid needing to evaluate all the possible printers that any one adds.
          '';
        };
      };
    };
  };

  config = mkMerge [
    {
      programs.gdb.pretty-printers.available =
        let
          mkPrinter = type: (pkgs.callPackage ./${type}-pretty-printers.nix { }).gdbinit;
        in
        builtins.listToAttrs (
          builtins.map (type: (nameValuePair type (mkPrinter type))) [
            "libcxx"
            "libc++"
            "eigen"
            "llvm"
          ]
        );
    }
    (mkIf cfg.enable {
      home.packages = [ pkgs.gdb ];
      home.file."${config.xdg.configHome}/gdb/gdbinit".text = builtins.concatStringsSep "\n" (
        (unique (
          builtins.map (printer: cfg.pretty-printers.available.${printer}) cfg.pretty-printers.selected
        ))
        ++ [
          "set print pretty on"
          cfg.extraConfig
        ]
      );
    })
  ];
}
