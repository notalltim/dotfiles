{
  inputsJSON,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs { },
  name ? "test",
}:
let

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
(pkgs.writeClosure (builtins.map (path: builtins.storePath (/. + path)) inputs)).overrideAttrs (_: {
  inherit name;
})
