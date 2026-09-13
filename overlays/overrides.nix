final: prev: {

  vimPlugins = prev.vimPlugins // {
    windsurf-nvim = prev.vimPlugins.windsurf-nvim.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../pkgs/json-encode-crash.patch ];
    });
  };
  hello-cpp = prev.hello-cpp.overrideAttrs (_old: {
    separateDebugInfo = true;
  });

  # Needed because 14 actually supports wayland and 26.05 is stuck on 13.3
  flameshot = prev.flameshot.overrideAttrs (
    finalAttrs: _oldAttrs: {
      version = "14.0.0";
      patches = [
        ./load-missing-deps.patch
        ./macos-build.patch
      ];
      src = final.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        tag = "v${finalAttrs.version}";
        hash = "sha256-GnJ3nOJyyqQbCTMrTYhnQfEOXqCy0x3IapX/PsaZ3VI=";
      };
    }
  );
  # TODO(26.11): remove once 26.11 is out
  mpvpaper = prev.mpvpaper.overrideAttrs (
    finalAttrs: _oldAttrs: {
      version = "1.9";
      src = final.fetchFromGitHub {
        owner = "GhostNaN";
        repo = "mpvpaper";
        rev = finalAttrs.version;
        sha256 = "sha256-FpwMhzYmbjwvbpJd6xDRka6h2bvgsqdopqP5deQKXSA=";
      };

    }
  );

}
