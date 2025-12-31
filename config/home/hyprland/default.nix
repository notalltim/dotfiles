# Stolen from @jmoo
{
  config,
  lib,
  pkgs,
  wrapHyprCommand,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    mkForce
    optionalString
    getExe
    mkDefault
    mapAttrsToList
    mapAttrs'
    attrValues
    ;
  inherit (lib.types) str attrsOf;
  cfg = config.baseline.hyprland;
in
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpolkitagent.nix
  ];

  options.baseline = {
    hyprland = {
      enable = mkEnableOption "Enable hyprland home-manager configuration";

      nvidia = mkEnableOption "Set to true if using an nvidia gpu";

      sessionVariables = mkOption {
        description = "Session variables that need to be included in the hyprland session.";
        type = attrsOf str;
        default = { };
      };

      uwsm = mkEnableOption "Manages graphical-session systemd user targets and scopes with uwsm";

    };
  };

  config = mkMerge [
    {
      # Make QT apps happy
      baseline.hyprland.sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
      };

      # Wrapping all executables called from hyprland. This will wrap
      # everything with uwsm calls if uwsm is enabled.
      _module.args.wrapHyprCommand =
        x: "${optionalString (cfg.enable && cfg.uwsm) "${getExe pkgs.uwsm} app -- "}${x}";
    }

    # Hyprland
    (mkIf cfg.enable {
      home = {
        packages =
          with pkgs;
          [
            # Include xterm so there is always a non-gpu accelerated terminal avaibaselinele
            xterm

            # font viewer
            font-manager
          ]

          # Add default apps to the environment
          ++ (map (x: x.package) (attrValues config.baseline.apps));

        sessionVariables = cfg.sessionVariables;
      };

      # Enable default programs and services for a complete
      # out of the box hyprland experience.
      baseline = {
        hyprlock.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        # hyprpaper.enable = mkDefault false;
        hyprpolkitagent.enable = mkDefault true;
        # theme.enable = mkDefault true;
        ulauncher.enable = mkDefault true;
        waybar.enable = mkDefault true;
        wlogout.enable = mkDefault true;
      };

      # Notification daemon
      services.swaync.enable = mkDefault true;

      systemd.user.sessionVariables = cfg.sessionVariables;

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = builtins.readFile ./config/hyprland.conf;
        settings = mkMerge [
          {
            # Set default mod variables
            "$mod" = mkDefault "SUPER";
            "$modCtrl" = mkDefault "SUPER+CTRL";
            "$modAlt" = mkDefault "SUPER+ALT";
            "$modShift" = mkDefault "SUPER+SHIFT";
            "$modShiftCtrl" = mkDefault "SUPER+SHIFT+CTRL";

            # Set sessionVariables
            env = mapAttrsToList (n: v: "${n},${v}") cfg.sessionVariables;

            # Enable default anime wallpapers
            misc = {
              force_default_wallpaper = mkDefault (-1);
              disable_hyprland_logo = mkDefault false;
            };
          }

          # Set variables for default apps
          (mapAttrs' (n: v: {
            name = "\$${n}";
            value = mkDefault (wrapHyprCommand v.command);
          }) config.baseline.apps)
        ];

        xwayland.enable = true;
      };
    })

    # Environment flags for nvidia GPUs
    (mkIf cfg.nvidia {
      baseline.hyprland.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    })

    # UWSM - Manages graphical-session systemd user targets and scopes
    (mkIf cfg.uwsm {
      baseline = {
        # Patched version of ulauncher that launches everything with uwsm
        ulauncher.package = mkIf cfg.uwsm pkgs.ulauncher-uwsm;

        # Override waybar launcher commands with uwsm variants
        waybar.settings = {
          bluetooth.on-click = wrapHyprCommand config.baseline.apps.bluetoothManager.command;
          pulseaudio.on-click = wrapHyprCommand config.baseline.apps.audioManager.command;

          "custom/session-manager".on-click = wrapHyprCommand config.baseline.apps.sessionManager.command;
        };
      };

      # Hyprland is started by UWSM so we need to disable the systemd service
      wayland.windowManager.hyprland.systemd.enable = mkForce false;
    })
  ];
}
