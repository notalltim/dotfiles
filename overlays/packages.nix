inputs: final: _prev: {
  agenix-secret-nvim = final.callPackage ../pkgs/agenix-secret-nvim.nix {
    src = inputs.age-secret-nvim;
    inherit (final.vimUtils) buildVimPlugin;
  };
  ulauncher-uwsm = final.callPackage ../pkgs/ulauncher-uwsm.nix { };
}
