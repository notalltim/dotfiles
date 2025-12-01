# Stolen from @jmoo
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    getExe
    mkDefault
    ;
  inherit (lib.types)
    nullOr
    package
    submodule
    attrsOf
    str
    ;
in
{
  options.baseline.apps = mkOption {
    description = "Default apps";
    type = attrsOf (
      submodule (
        { name, config, ... }:
        {
          options = {
            enable = (mkEnableOption "Enable default app") // {
              default = true;
            };

            name = mkOption {
              type = str;
              default = name;
            };

            package = mkOption {
              type = nullOr package;
              default = null;
            };

            command = mkOption {
              type = str;
              default = getExe config.package;
            };
          };
        }
      )
    );
    default = { };
  };

  config.baseline.apps = with pkgs; {
    terminal.package = mkDefault config.programs.kitty.package;
    bluetoothManager.package = mkDefault blueberry;
    audioManager.package = mkDefault pavucontrol;
    launcher.package = mkDefault config.baseline.ulauncher.package;
    displayManager.package = mkDefault wdisplays;
    fileManager.package = mkDefault nemo;
    sessionManager.package = mkDefault config.programs.wlogout.package;
  };
}
