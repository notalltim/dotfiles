{ ... }:
{
  _module.args.baselineLib = {
    mkPathReproducible =
      path:
      builtins.path {
        inherit path;
      };

  };
}
