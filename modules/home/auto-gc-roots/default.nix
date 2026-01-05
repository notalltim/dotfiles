{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.auto-gc-roots;
  inherit (lib)
    mkIf
    getExe
    mapAttrsToList
    optionalString
    toList
    concatMapStringsSep
    mkMerge
    literalExpression
    ;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types)
    package
    attrsOf
    str
    singleLineStr
    listOf
    either
    submodule
    bool
    coercedTo
    ;

  flakeInputsExpression = builtins.path {
    path = ./flake-inputs.nix;
    name = "flake-inputs.nix";
  };
  flakeDerivationsExpression = builtins.path {
    path = ./flake-derivations.nix;
    name = "flake-derivations.nix";
  };

  script = pkgs.writeShellApplication {
    name = "refresh-gc-roots";
    runtimeInputs = with pkgs; [
      cfg.nixPackage
      jq
    ];
    text =
      let
        flakes = mapAttrsToList (name: value: value // { inherit name; }) cfg.flakes;
        profile = "${config.xdg.stateHome}/nix/profiles/auto-gc-roots";
      in
      ''
        # create temp file to collect outputs to add to profile
        TMPFILE=$(mktemp)
        trap 'rm -f "$TMPFILE"' EXIT
      ''
      + (
        if flakes == [ ] then
          "echo \"No flakes given ending...\""
        else
          (builtins.concatStringsSep "\n" (
            builtins.map (
              flake:
              (optionalString flake.cacheFlakeInputs ''

                FLAKE_REV=$(nix flake metadata ${flake.url} --json | jq 'if .locked.rev then .locked.rev else .locked.narHash end' --raw-output)
                echo "Caching flake inputs for ${flake.name} from ${flake.url} (rev: $FLAKE_REV)"
                # Recursivley fetch the flake inputs for ${flake.name} from ${flake.url} and build a closure
                # shellcheck disable=SC2129
                nix-build ${flakeInputsExpression} --no-out-link \
                                                   --argstr inputsJSON "$(nix flake archive ${flake.url} --json)" \
                                                   --argstr name "${flake.name}-input-closure" \
                                                   --arg nixpkgs ${pkgs.path} >> "$TMPFILE"

              '')
              + (optionalString (flake.outputs != [ ]) (
                let
                  outputs = builtins.foldl' (
                    acc: output:
                    acc ++ [ output.path ] ++ (builtins.map (add: "${output.path}.${add}") output.additionalOutputs)
                  ) [ ] flake.outputs;
                in

                ''
                  echo "Building outputs ${builtins.concatStringsSep " " outputs} of ${flake.name} from ${flake.url} (rev: $FLAKE_REV)"
                  # Build the set of outputs and link them to the correct location\n# shellcheck disable=SC2129
                  nix-build ${flakeDerivationsExpression} --no-out-link \
                                                            --argstr nixBuildOutput "$(nix build --no-link --json ${
                                                              concatMapStringsSep " " (output: "${flake.url}#${output}") outputs
                                                            })" \
                                                            --argstr name "${flake.name}-output-closure" \
                                                            --arg nixpkgs ${pkgs.path} >> "$TMPFILE"
                ''
                + (
                  let
                    buildOutputs = builtins.filter (output: output.keepBuildDependencies) flake.outputs;
                  in
                  (optionalString (buildOutputs != [ ]) (
                    "echo \"Caching build dependencies of ${
                      concatMapStringsSep " " (output: output.path) buildOutputs
                    } for ${flake.name} from ${flake.url} (rev: $FLAKE_REV) \"\n"
                    + "# Build the set of inputDerivations\n# shellcheck disable=SC2129\nnix build --no-link --print-out-paths \\\n\t\t\t"
                    + (concatMapStringsSep "\\\n\t\t\t" (
                      output: "${flake.url}#${output.path}.inputDerivation "
                    ) buildOutputs)
                    + ">> \"$TMPFILE\"\n"
                  ))
                )
              ))
            ) flakes
          ))
          + ''
            # Clean up the old version of the profile
            echo "Removing old flake inputs and outputs"
            # shellcheck disable=SC2046
            nix profile remove  --profile ${profile} $(jq .elements[].storePaths.[] ${profile}/manifest.json --raw-output) || true
            echo "Installling to profile:"
            cat "$TMPFILE"
            # Add new paths
            nix profile install --stdin --profile ${profile} < "$TMPFILE" 2>&1 || true
            exit 0
          ''
      );
  };

in
{
  options = {
    services.auto-gc-roots = {
      automatic = mkEnableOption "auto-gc-roots: automatic linking of flake inputs and flake outputs";

      runBeforeGC = mkOption {
        type = bool;
        description = "refresh the gc roots before running the nix garbage collector";
        default = true;
      };

      nixPackage = mkOption {
        type = package;
        description = "nix package to use for nix build / profile commands";
        default = config.nix.package;
      };

      flakes = mkOption {
        type = attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                cacheFlakeInputs = mkOption {
                  type = bool;
                  default = true;
                  description = "Create a closure of the recursive flake inputs for ${name} and create a gc root";
                };
                url = mkOption {
                  type = str;
                  default = name;
                  example = "github:NixOS/nixpkgs/releases/25.05";
                  description = ''
                    URL of the flake must be a valid to find on the current system or fetch from the internet
                    validate using `nix flake metadata ''${url}`
                  '';
                };
                outputs = mkOption {
                  type = listOf (
                    coercedTo str (p: if builtins.isAttrs p then p else { path = p; }) (submodule {
                      options = {
                        path = mkOption {
                          type = str;
                          description = "Path to the flake output to create a gc root for";
                          example = "devShells.x86_64-linux.default";
                        };
                        additionalOutputs = mkOption {
                          type = listOf str;
                          default = [ ];
                          example = literalExpression "[ \"dev\"  \"doc\"]";
                          description = "Additonal outputs to build such as `dev` or `doc`";
                        };
                        keepBuildDependencies = mkOption {
                          type = bool;
                          default = false;
                          description = "Add a gc root for the `inputDerivation` which will link the build time dependencies";
                        };
                      };
                    })
                  );
                  default = [ ];
                  description = ''
                    outputs of the ${name} flake add to the output closure that will be linked to a gc root
                  '';

                };
              };
            }
          )
        );
        default = { };
        description = ''
          Flakes to create gc roots for inputs and optionally outputs.
        '';
        example = literalExpression ''
          {
            # will only cache the inputs
            "github:NixOS/nixpkgs/release-25.05" = {};
            # naming does not need to be tied to the URL
            self = { url = "path:" + ./.; };
            # registry also works
            nixpkgs = {
              outputs = [
                "hello"
                {
                  # cache build dependencies
                  path = "hello-cpp";
                  keepBuildDependencies = true;
                }
              ];
            };
          }
        '';
      };

      frequency = mkOption {
        type = either singleLineStr (listOf str);
        default = "daily";
        apply = toList;
        description = ''
          When to refresh the flake inputs and outputs.

          On Linux this is a string as defined by {manpage}`systemd.time(7)`.

          ${lib.hm.darwin.intervalDocumentation}
        '';
      };

      randomizedDelaySec = lib.mkOption {
        default = "0";
        type = singleLineStr;
        example = "45min";
        description = ''
          Add a randomized delay before each garbage collection.
          The delay will be chosen between zero and this value.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';
      };

      persistent = mkOption {
        type = bool;
        default = true;
        example = false;
        description = ''
          If true, the time when the service unit was last triggered is
          stored on disk. When the timer is activated, the service unit is
          triggered immediately if it would have been triggered at least once
          during the time when the timer was inactive.
        '';
      };

      script = mkOption {
        type = package;
        default = script;
        readOnly = true;
      };
    };
  };
  config = (
    mkMerge [
      (mkIf (cfg.flakes != { }) { home.packages = [ cfg.script ]; })
      (mkIf cfg.automatic (mkMerge [
        (mkIf (cfg.automatic -> !config.nix.gc.automatic) {
          warnings = [
            "Enabling auto-gc-roots without garbage collection can cause high disk usage use caution"
          ];
        })
        (mkIf pkgs.stdenv.isLinux {
          systemd.user = {
            timers.auto-gc-roots = {
              Unit = {
                Description = "auto-gc-roots: peroidically refresh flake based gc roots";
              };
              Timer = {
                OnCalendar = cfg.frequency;
                Unit = "auto-gc-roots.service";
                RandomizedDelaySec = cfg.randomizedDelaySec;
                Persistent = cfg.persistent;
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };
            services.auto-gc-roots = {
              Unit = {
                Description = "auto-gc-roots: Keep a set of flakes / flake outputs as gc roots";
                Before = mkIf cfg.runBeforeGC [ "nix-gc.service" ];
              };
              # Force service to run right before gc
              Install = mkIf cfg.runBeforeGC {
                RequiredBy = [ "nix-gc.service" ];
              };
              Service = {
                Type = "oneshot";
                ExecStart = "${getExe cfg.script}";
                ReadWritePaths = [ "${config.xdg.stateHome}/nix/profiles" ];
              };
            };
          };
        })
        (lib.mkIf pkgs.stdenv.isDarwin {
          assertions = [
            (lib.hm.darwin.assertInterval "serivices.auto-gc-roots.frequency" cfg.frequency pkgs)
          ];

          launchd.agents.nix-gc = {
            enable = true;
            config = {
              ProgramArguments = [
                "${getExe cfg.script}"
              ];
              StartCalendarInterval = lib.hm.darwin.mkCalendarInterval cfg.frequency;
            };
          };
        })

      ]))
    ]
  );
}
