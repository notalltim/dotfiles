{
  lib,
  self,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.gpu;
in {
  options.baseline.gpu = {
    enable = mkEnableOption "Enable GPU overlay";
    enableVulkan = mkEnableOption "Vulkan support";
    enableNvidiaOffload = mkEnableOption "Hybrid graphics support for Nvidia offload";
  };

  config = {
    home = mkIf cfg.enable {
      packages = [pkgs.gpu-wrappers];
      activation = mkIf cfg.enableNvidiaOffload {
        clearNixglCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
          [ -v DRY_RUN ] || rm -f ${config.xdg.cacheHome}/nixgl/result*
        '';
      };
    };
    nixpkgs.overlays = [
      (final: prev: {
        gpu-wrappers = let
          system = final.system;
          nixglPkgs = "${self}#gpuWrappers.${system}";
          wrapIntel = type: lib.getExe self.inputs.nixgl.packages.${system}."nix${type}Intel";
        in
          final.runCommand "gpu-wrappers" {} ''
            bin=$out/bin
            mkdir -p $bin

            cat > $bin/nixgl-intel <<EOF
            #!/bin/sh
            exec ${wrapIntel "GL"} ${
              if cfg.enableVulkan
              then wrapIntel "Vulkan"
              else ""
            } "\$@"
            EOF
            chmod +x $bin/nixgl-intel

            ${
              if cfg.enableNvidiaOffload
              then ''
                cat > $bin/nixgl-nvidia <<EOF
                #!/bin/sh
                glbin=\$(nix eval --quiet --raw --impure "${nixglPkgs}.nixGLNvidia.meta.name")
                vkbin=${
                  if cfg.enableVulkan
                  then "\$(echo \$glbin | sed s/GL/Vulkan/)"
                  else ""
                }
                packages=${
                  if cfg.enableVulkan
                  then "${nixglPkgs}.nixGLNvidia ${nixglPkgs}.nixVulkanNvidia"
                  else "${nixglPkgs}.nixGLNvidia"
                }
                exec nix shell --quiet --impure \$packages -c \$glbin \$vkbin "\$@"
                EOF
                chmod +x $bin/nixgl-nvidia
              ''
              else ""
            }

            ${
              if cfg.enableNvidiaOffload
              then ''
                cat > $bin/nvidia-offload <<EOF
                #!/bin/sh
                export __NV_PRIME_RENDER_OFFLOAD=1
                export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
                export __GLX_VENDOR_LIBRARY_NAME=nvidia
                ${
                  if cfg.enableVulkan
                  then "export __VK_LAYER_NV_optimus=NVIDIA_only"
                  else ""
                }
                exec "\$@"
                EOF
                chmod +x $bin/nvidia-offload
              ''
              else ""
            }

            cat > $bin/nixgl <<EOF
            #!/bin/sh
            ${
              if cfg.enableNvidiaOffload
              then ''
                if [ ! -h "${config.xdg.cacheHome}/nixgl/result" ]
                then
                    mkdir -p "${config.xdg.cacheHome}/nixgl"
                    nix build --quiet --impure \
                      --out-link "${config.xdg.cacheHome}/nixgl/result" \
                      ${nixglPkgs}.nixGLNvidia ${
                  if cfg.enableVulkan
                  then "${nixglPkgs}.nixVulkanNvidia"
                  else ""
                }
                fi

                if [ "\$__NV_PRIME_RENDER_OFFLOAD" = "1" ]
                then
                    nixgl-nvidia "\$@"
                else
                    nixgl-intel "\$@"
                fi
              ''
              else ''nixgl-intel "\$@"''
            }
            EOF
            chmod +x $bin/nixgl
          '';

        lib = prev.lib.extend (_: _: rec {
          gpuWrapPackage = pkg:
            final.runCommand "${pkg.name}-nixgl-pkg-wrapper" {} ''
              # Create a new package that wraps the binaries with nixGL
              mkdir $out
              ln -s ${pkg}/* $out
              rm $out/bin
              mkdir $out/bin
              for bin in ${pkg}/bin/*
              do
                wrapped_bin=$out/bin/$(basename $bin)
                echo "#!/bin/sh" > $wrapped_bin
                echo "exec nixgl $bin \"\$@\"" >> $wrapped_bin
                chmod +x $wrapped_bin
              done

              # If .desktop files refer to the old derivation, replace the references
              if [ -d "${pkg}/share/applications" ] && grep "${pkg}" ${pkg}/share/applications/*.desktop > /dev/null
              then
                  rm $out/share
                  mkdir -p $out/share
                  cd $out/share
                  ln -s ${pkg}/share/* ./
                  rm applications
                  mkdir applications
                  cd applications
                  cp -a ${pkg}/share/applications/* ./
                  for dsk in *.desktop
                  do
                      sed -i "s|${pkg}|$out|g" "$dsk"
                  done
              fi
            '';

          gpuWrapCheck = pkg:
            if config.targets.genericLinux.enable && cfg.enable
            then gpuWrapPackage pkg
            else pkg;
        });
      })
    ];
  };
}
