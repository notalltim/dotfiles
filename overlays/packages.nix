inputs: final: _prev: {
  agenix-secret-nvim = final.callPackage ../pkgs/agenix-secret-nvim.nix {
    src = inputs.age-secret-nvim;
    inherit (final.vimUtils) buildVimPlugin;
  };
  ulauncher-uwsm = final.callPackage ../pkgs/ulauncher-uwsm.nix { };
  # This was removed upstream and replaced with a less capable version...
  nixseparatedebuginfod = final.callPackage ../pkgs/nixseparatedebuginfod.nix { };
  inherit (inputs.calibre-plugins.packages.${final.stdenv.hostPlatform.system})
    acsm-calibre-plugin
    dedrm-plugin
    ;
}
