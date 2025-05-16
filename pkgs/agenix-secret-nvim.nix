{ buildVimPlugin, src }:
buildVimPlugin {
  pname = "agenix-secret.nvim";
  version = "develop";
  inherit src;
}
