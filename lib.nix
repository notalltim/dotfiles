{ pkgs
, isHome
,
}: rec {
  inherit (pkgs) writeShellApplication stdenvNoCC;

  inherit (pkgs.nixgl) nixVulkanIntel nixGLIntel;

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

  writeIntelGLWrapper = writeNixGLWrapper (
    if isHome
    then nixGLIntel
    else pkgs.nixgl.auto.nixGLDefault
  );

  writeIntelVulkanWrapper = writeNixGLWrapper nixVulkanIntel;

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
