{ pkgs }: rec {
  inherit (pkgs) writeShellApplication stdenvNoCC;

  inherit (pkgs.nixgl) nixVulkanIntel nixGLIntel;
  inherit (pkgs.nixgl.auto) nixVulkanNvidia nixGLNvidia nixGLNvidiaBumblebee nixGLDefault;

  writeNixGLWrapper = runner: package:
    stdenvNoCC.mkDerivation
      rec {
        name = package.name;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp -r ${package}/* $out
          cp -rf $src/* $out
          runHook postInstall
        '';
        src = writeShellApplication {
          name = package.pname;
          runtimeInputs = [ package runner ];
          text = ''
            ${runner.name} ${package.pname};
          '';
        };
      };

  writeIntelGLWrapper = writeNixGLWrapper nixGLDefault;
  writeIntelVulkanWrapper = writeNixGLWrapper nixVulkanIntel;
  writeNvidiaGLWrapper = writeNixGLWrapper nixGLNvidia;
  writeNvidiaVulkanWrapper = writeNixGLWrapper nixVulkanNvidia;
  writeNvidiaBumblebeeWrapper = writeNixGLWrapper nixGLNvidiaBumblebee;

  createLuaPlugin =
    { package
    , dependencies ? [ ]
    , configs ? ""
    , optional ? false
    ,
    }:
    let
      plugin = {
        type = "lua";
        config = configs;
        inherit optional;
        plugin = package;
      };
    in
    [ plugin ] ++ dependencies;
}
