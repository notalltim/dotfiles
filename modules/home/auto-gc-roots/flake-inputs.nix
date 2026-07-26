{
  inputsJSON,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs { },
  name ? "test",
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
  inputPaths = builtins.fromJSON inputsJSON;
  collectFlakeInputs =
    input:
    [ input.path ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
  inputs =
    pkgs.lib.lists.unique (
      builtins.concatMap collectFlakeInputs (builtins.attrValues inputPaths.inputs)
    )
    ++ [ inputPaths.path ];
in
(writeClosure (map (path: builtins.storePath (/. + path)) inputs)).overrideAttrs (_: {
  inherit name;
})
