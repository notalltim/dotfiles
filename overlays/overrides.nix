_final: prev: {
  blueberry = prev.blueberry.overrideAttrs (old: {
    meta = old.meta // {
      mainProgram = "blueberry";
    };
  });

  vimPlugins = prev.vimPlugins // {
    windsurf-nvim = prev.vimPlugins.windsurf-nvim.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../pkgs/json-encode-crash.patch ];
    });
  };
}
