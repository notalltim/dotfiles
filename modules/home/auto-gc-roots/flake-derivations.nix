{
  nixBuildOutput ? "{}",
  name ? "test",
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs { },
}:
let
  buildOutput = builtins.fromJSON nixBuildOutput;
  outputs = builtins.map (output: builtins.storePath (/. + output)) (
    builtins.foldl' (acc: result: builtins.attrValues result.outputs ++ acc) [ ] buildOutput
  );
  closure = pkgs.writeClosure outputs;
in
closure.overrideAttrs (_: {
  inherit name;
})
