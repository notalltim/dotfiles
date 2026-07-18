final: prev: {

  vimPlugins = prev.vimPlugins // {
    windsurf-nvim = prev.vimPlugins.windsurf-nvim.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../pkgs/json-encode-crash.patch ];
    });
  };
  hello-cpp = prev.hello-cpp.overrideAttrs (_old: {
    separateDebugInfo = true;
  });
  tuigreet = prev.tuigreet.overrideAttrs rec {
    src = prev.fetchFromGitHub {
      owner = "NotAShelf";
      repo = "tuigreet";
      tag = "0.11.0"; # update this with the tag you want to use
      hash = "sha256-4DB4Pl2UwIeab/MJaX3VfVNMsPWE6Q513z1NDdxvG3o="; # update this with the appropriate hash for your tag
    };
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-5Q4E8nnmQ109gcfxxctn/rne5N4Qvz2Pft6o7as2fSc=";
    };
  };

}
