{
  nixBuildOutput ? "{}",
  name ? "test",
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs { },
}:
let
  writeClosure =
    paths:
    pkgs.runCommandLocal "runtime-deps"
      {
        # Get the cleaner exportReferencesGraph interface
        __structuredAttrs = true;
        exportReferencesGraph.graph = paths;
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        jq -r ".graph | map(.path) | sort | .[]" "$NIX_ATTRS_JSON_FILE" > "$out"
      '';
  buildOutput = builtins.fromJSON nixBuildOutput;
  outputs = map (output: builtins.storePath (/. + output)) (
    builtins.foldl' (acc: result: builtins.attrValues result.outputs ++ acc) [ ] buildOutput
  );
  closure = writeClosure outputs;
in
closure.overrideAttrs (_: {
  inherit name;
})
