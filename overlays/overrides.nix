final: prev: {

  vimPlugins = prev.vimPlugins // {
    windsurf-nvim = prev.vimPlugins.windsurf-nvim.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../pkgs/json-encode-crash.patch ];
    });
  };
  hello-cpp = prev.hello-cpp.overrideAttrs (_old: {
    separateDebugInfo = true;
  });
}
