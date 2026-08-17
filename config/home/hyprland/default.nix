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
  inherit (lib.generators) mkLuaInline;
  cfg = config.baseline.hyprland;

  # TODO: move all these to a lib so that other modules can declare bindings
  mkVar = val: { _var = val; };

  mkModifier = mod: keys: if mod != null then mkLuaInline "${mod} .. \" + ${keys}\"" else keys;

  mkMultiArgFunction = args: { _args = args; };

  mkBindWithFlags = flags: mod: key: description: dispatcher: {
    _args = [
      (mkModifier mod key)
      (mkLuaInline dispatcher)
      ({ inherit description; } // (builtins.listToAttrs (map (flag: lib.nameValuePair flag true) flags)))
    ];
  };

  mkBind = mkBindWithFlags [ ];

  toDir =
    key:
    {
      left = "l";
      right = "r";
      up = "u";
      down = "d";
    }
    .${key};

  toWsDir =
    key:
    {
      left = "-1";
      right = "+1";
      "mouse_up" = "-1";
      "mouse_down" = "+1";
    }
    .${key};

  mkMultiBindWithFlags =
    flags: keys: mod: descriptionByKey: dispatcherByKey:
    map (
      key:
      let
        evalByKey = byKey: if builtins.isFunction byKey then byKey key else byKey;
      in
      mkBindWithFlags flags mod key (evalByKey descriptionByKey) (evalByKey dispatcherByKey)
    ) keys;

  mkMultiBind = mkMultiBindWithFlags [ ];
  mkLRBinds = mkMultiBind [
    "left"
    "right"
  ];

  mkAllDirBinds = mkMultiBind [
    "left"
    "right"
    "up"
    "down"
  ];

  mkNumericBinds = mkMultiBind (map toString (lib.range 0 9));
  mkScrollBinds = mkMultiBind [
    "mouse_up"
    "mouse_down"
  ];

  mkRepeatingBinds =
    mkMultiBindWithFlags
      [ "locked" "repeat" ]
      [ "XF86AudioRaiseVolume" "XF86AudioLowerVolume" "XF86MonBrightnessUp" "XF86MonBrightnessDown" ]
      null;
  mkMediaBinds =
    mkMultiBindWithFlags
      [ "locked" "repeat" ]
      [
        "XF86AudioMute"
        "XF86AudioMicMute"
        "XF86AudioNext"
        "XF86AudioPrev"
        "XF86AudioPlay"
        "XF86AudioPause"
      ]
      null;

  map0To10 =
    index:
    let
      indexAsInt = lib.toIntBase10 index;
    in
    toString (if indexAsInt != 0 then indexAsInt else 10);

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
        XCURSOR_SIZE = "16";
        HYPRCURSOR_SIZE = "16";
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

        inherit (cfg) sessionVariables;
      };

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

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
      # Screenshots
      services.flameshot.enable = mkDefault true;

      systemd.user.sessionVariables = cfg.sessionVariables;

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";

        # TODO: Move these to seperate files and maybe split some into modules (media controls, brightness etc.)
        settings = mkMerge [
          {

            # Set sessionVariables
            env = mapAttrsToList (
              n: v:
              mkMultiArgFunction [
                n
                v
              ]
            ) cfg.sessionVariables;
          }

          # Set variables for default apps
          (mapAttrs' (name: v: {
            inherit name;
            value = mkDefault (mkVar (wrapHyprCommand v.command));
          }) config.baseline.apps)
          # Display settings
          {
            config = {
              general = {
                gaps_in = 5;
                gaps_out = 10;

                border_size = 2;

                # Set to true enable resizing windows by clicking and dragging on borders and gaps
                resize_on_border = true;

                # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
                allow_tearing = false;

                layout = "dwindle";
              };
              decoration = {
                rounding = 10;

                # Change transparency of focused and unfocused windows
                active_opacity = 1.0;
                inactive_opacity = 1.0;

                shadow = {
                  enabled = true;
                  range = 4;
                  render_power = 3;
                };

                # https://wiki.hyprland.org/Configuring/Variables/#blur
                blur = {
                  enabled = true;
                  size = 3;
                  passes = 1;

                  vibrancy = 0.1696;
                };
              };
              dwindle.preserve_split = true;
              master.new_status = "master";
              # Disable default anime wallpapers
              misc = {
                force_default_wallpaper = mkDefault (-1);
                disable_hyprland_logo = mkDefault false;
              };
            };
          }
          # Animations
          {
            config.animations.enabled = true;
            curve =
              let
                mkBezierCurve =
                  name: points:
                  mkMultiArgFunction [
                    name
                    {
                      type = "bezier";
                      inherit points;
                    }
                  ];
              in
              [
                (mkBezierCurve "easeOutQuint" [
                  [
                    0.23
                    1.
                  ]
                  [
                    0.32
                    1.
                  ]
                ])
                (mkBezierCurve "easeInOutCubic" [
                  [
                    0.65
                    0.05
                  ]
                  [
                    0.36
                    1.
                  ]
                ])
                (mkBezierCurve "linear" [
                  [
                    0.0
                    0.0
                  ]
                  [
                    1.0
                    1.0
                  ]
                ])
                (mkBezierCurve "almostLinear" [
                  [
                    0.5
                    0.5
                  ]
                  [
                    0.75
                    1.0
                  ]
                ])
                (mkBezierCurve "quick" [
                  [
                    0.15
                    0.0
                  ]
                  [
                    0.1
                    1.
                  ]
                ])
              ];
            animation =
              let
                mkAnimationWithStyle =
                  style: curve: speed: leaf:
                  mkMultiArgFunction [
                    (
                      {
                        inherit leaf speed;
                        # TODO(tgallion): this sucks because now we need to pass around the curve type :(
                        bezier = curve;

                        enabled = true;
                      }
                      // (lib.optionalAttrs (style != null) { inherit style; })
                    )
                  ];
                mkAnimation = mkAnimationWithStyle null;
              in
              [
                (mkAnimation "default" 10 "global")
                (mkAnimation "easeOutQuint" 5.39 "border")
                (mkAnimation "easeOutQuint" 4.79 "windows")
                (mkAnimationWithStyle "popin 87%" "easeOutQuint" 4.1 "windowsIn")
                (mkAnimationWithStyle "popin 87%" "linear" 1.49 "windowsOut")
                (mkAnimation "quick" 3.03 "fade")
                (mkAnimation "almostLinear" 1.73 "fadeIn")
                (mkAnimation "almostLinear" 1.46 "fadeOut")
                (mkAnimation "linear" 3.81 "layers")
                (mkAnimationWithStyle "fade" "easeOutQuint" 4.0 "layersIn")
                (mkAnimation "almostLinear" 1.5 "layersOut")
                (mkAnimation "almostLinear" 1.79 "fadeLayersIn")
                (mkAnimation "almostLinear" 1.39 "fadeLayersOut")
                (mkAnimationWithStyle "fade" "almostLinear" 1.94 "workspaces")
                (mkAnimationWithStyle "fade" "almostLinear" 1.21 "workspacesIn")
                (mkAnimationWithStyle "fade" "almostLinear" 1.94 "workspacesOut")
              ];
          }
          # Binds
          {
            # Set default mod variables
            mod = mkDefault (mkVar "SUPER");
            modCtrl = mkDefault (mkVar "SUPER+CTRL");
            modAlt = mkDefault (mkVar "SUPER+ALT");
            modShift = mkDefault (mkVar "SUPER+SHIFT");
            modShiftCtrl = mkDefault (mkVar "SUPER+SHIFT+CTRL");
            bind = [
              (mkBind "mod" "T" "Open terminal" "hl.dsp.exec_cmd(terminal)")
              (mkBind "mod" "Q" "Kill active window" "hl.dsp.window.close()")
              (mkBind "mod" "R" "Reload hyprland" "hl.dsp.exec_cmd(\"hyperctl reload\")")
              (mkBind "mod" "M" "Stop session" "hl.dsp.exec_cmd(\"uwsm stop\")")
              (mkBind "mod" "F" "Fullscreen" "hl.dsp.window.fullscreen()")
              (mkBind "mod" "D" "Open launcher" "hl.dsp.exec_cmd(launcher)")
              (mkBind "mod" "P" "Pseudo-tile" "hl.dsp.window.pseudo()")
              (mkBind "mod" "S" "Toggle split" "hl.dsp.layout(\"togglesplit\")")
              (mkBind "mod" "L" "Lock" "hl.dsp.exec_cmd(lock)")
              (mkBind "mod" "C" "Toggle floating" ''
                function()
                  hl.dsp.window.float()
                  hl.dsp.window.center()
                end
              '')
              (mkBind "mod" "X" "Open terminal" "hl.dsp.exec_cmd(\"xterm\")")
              (mkBind "mod" "space" "Toggle magic workspace" "hl.dsp.workspace.toggle_special(\"magic\")")
              (mkBind "modShift" "space" "Move window to magic workspace"
                "hl.dsp.window.move({ workspace = \"special:magic\" })"
              )
              (mkBindWithFlags [ "mouse" ] "mod" "mouse:272" "Drag window with mouse" "hl.dsp.window.drag()")
              (mkBindWithFlags [ "mouse" ] "mod" "mouse:273" "Resize window with mouse" "hl.dsp.window.resize()")
            ]
            ++ (mkAllDirBinds "mod" (key: "Move focus ${key}") (
              key: "hl.dsp.focus({direction = \"${toDir key}\"})"
            ))
            ++ (mkAllDirBinds "modShift" (key: "Swap focus ${key}") (
              key: "hl.dsp.window.swap({direction = \"${toDir key}\"})"
            ))
            ++ (mkLRBinds "modAlt"
              (
                key:
                {
                  left = "Decrease window width";
                  right = "Increase window width";
                }
                .${key}
              )
              (
                key:
                let
                  amount =
                    {
                      left = -0.1;
                      right = 0.1;
                    }
                    .${key};
                in
                "hl.dsp.window.resize({x = ${toString amount}, y = 0.0 })"
              )
            )
            ++ (mkLRBinds "modShiftCtrl" (key: "Move window ${key}") (
              key: "hl.dsp.window.move({ workspace = \"${toWsDir key}\" })"
            ))
            ++ (mkLRBinds "modCtrl" (key: "Focus workspace to the ${key}") (
              key: "hl.dsp.focus({ workspace = \"${toWsDir key}\" })"
            ))
            ++ (mkNumericBinds "mod" (index: "Focus workspace ${map0To10 index}") (
              index: "hl.dsp.focus({ workspace = ${map0To10 index} })"
            ))
            ++ (mkNumericBinds "modShift" (index: "Move window to workspace ${map0To10 index}") (
              index: "hl.dsp.window.move({ workspace = ${map0To10 index} })"
            ))
            ++ (mkScrollBinds "mod" (
              key:
              let
                description =
                  {
                    mouse_up = "previous workspace";
                    mouse_down = "next workspace";
                  }
                  .${key};
              in
              "Scroll ${description}}"
            ) (key: "hl.dsp.focus({ workspace = \"${toWsDir key}\" })"))
            ++ (mkRepeatingBinds
              (
                key:
                {
                  XF86AudioRaiseVolume = "Volume up";
                  XF86AudioLowerVolume = "Volume down";
                  XF86MonBrightnessUp = "Brightnesss up";
                  XF86MonBrightnessDown = "Brightnesss down";
                }
                .${key}
              )
              (
                key:
                let
                  command =
                    {
                      "XF86AudioRaiseVolume" = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
                      "XF86AudioLowerVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                      "XF86MonBrightnessUp" = "brightnessctl s 10%+";
                      "XF86MonBrightnessDown" = "brightnessctl s 10%-";
                    }
                    .${key};
                in
                "hl.dsp.exec_cmd(\"${command}\")"
              )
            )
            ++ (mkMediaBinds
              (
                key:
                {
                  XF86AudioMute = "Mute audio";
                  XF86AudioMicMute = "Mute microphone";
                  XF86AudioNext = "Next track";
                  XF86AudioPrev = "Previous track";
                  XF86AudioPlay = "Play";
                  XF86AudioPause = "Pause";
                }
                .${key}
              )
              (
                key:
                let
                  command =
                    {
                      XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                      XF86AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                      XF86AudioNext = "playerctl next";
                      XF86AudioPrev = "playerctl previous";
                      XF86AudioPlay = "playerctl play-pause";
                      XF86AudioPause = "playerctl play-pause";
                    }
                    .${key};
                in
                "hl.dsp.exec_cmd(\"${command}\")"
              )
            );
          }
          # Winow rules
          {

            window_rule = [
              {
                name = "pavucontrol";
                float = true;
                pin = true;
                size = [
                  500
                  700
                ];
                move = [
                  "100%-525"
                  "80"
                ];
                match.class = "org.pulseaudio.pavucontrol";
              }
              {
                name = "blueman";
                float = true;
                pin = true;
                size = [
                  500
                  700
                ];
                move = [
                  "100%-525"
                  "80"
                ];
                match.class = ".blueman-manager-wrapped";
              }
              {
                name = "nm-editor";
                float = true;
                pin = true;
                size = [
                  500
                  700
                ];
                move = [
                  "100%-525"
                  "80"
                ];
                match.class = "nm-connection-editor";
              }
              {
                name = "ulauncher-prefs";
                float = true;
                pin = true;
                size = [
                  600
                  800
                ];
                move = [
                  "100%-900"
                  "80"
                ];
                match.class = "ulauncher";
                match.title = "Ulauncher Preferences";
              }
              {
                name = "supress-maximize";
                suppress_event = "maximize";
                match.class = ".*";
              }
              {
                name = "xwayland-nofocus";
                no_focus = true;
                match.class = "^$";
                match.title = "^$";
                match.float = true;
                match.xwayland = true;
                match.fullscreen = false;
                match.pin = false;
              }

            ];
          }
          {
            workspace_rule = [
              {
                workspace = "special:magic";
                on_created_empty = mkLuaInline "terminal";
              }
            ];
          }

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
