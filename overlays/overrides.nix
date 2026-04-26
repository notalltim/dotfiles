final: prev: {
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
  hello-cpp = prev.hello-cpp.overrideAttrs (old: {
    separateDebugInfo = true;
  });

  obs-studio-plugins = prev.obs-studio-plugins // {
    droidcam-obs =
      (prev.obs-studio-plugins.droidcam-obs.override {
        ffmpeg_7 = final.ffmpeg;
      }).overrideAttrs
        (_prev: {
          version = "2.4.3";

          src = final.fetchFromGitHub {
            owner = "dev47apps";
            repo = "droidcam-obs-plugin";
            rev = "e873e48ec0b92b7da14d7b6d90f343ff41161a32";
            sha256 = "sha256-zOl8G9n6IbxXVMqqRY4Xr5mhDBUWSYBhN87l4lkcqtA=";
          };
        });
  };
  zellij = final.callPackage (
    {
      lib,
      stdenv,
      rustPackages_1_94,
      fetchFromGitHub,
      mandown,
      installShellFiles,
      pkg-config,
      curl,
      openssl,
      writableTmpDirAsHomeHook,
      versionCheckHook,
      nix-update-script,
    }:

    rustPackages_1_94.rustPlatform.buildRustPackage (finalAttrs: {
      pname = "zellij";
      version = "0.44.1";

      src = fetchFromGitHub {
        owner = "zellij-org";
        repo = "zellij";
        tag = "v${finalAttrs.version}";
        hash = "sha256-KHpVUjuOmMtkt8qBaCozD3M44eEtDwFmdDfszKAz0bM=";
      };

      # Remove the `vendored_curl` feature in order to link against the libcurl from nixpkgs instead of
      # the vendored one
      postPatch = ''
        substituteInPlace Cargo.toml \
          --replace-fail ', "vendored_curl"' ""
      '';

      cargoHash = "sha256-D3nZBXoGNf5z85iT7Xhj9Xwwwam/5m3X5hLPVoCzSPM=";

      env.OPENSSL_NO_VENDOR = 1;

      nativeBuildInputs = [
        mandown
        installShellFiles
        pkg-config
        (lib.getDev curl)
      ];

      buildInputs = [
        curl
        openssl
      ];

      nativeCheckInputs = [
        writableTmpDirAsHomeHook
      ];

      nativeInstallCheckInputs = [
        versionCheckHook
      ];
      versionCheckProgramArg = "--version";
      doInstallCheck = true;

      # Ensure that we don't vendor curl, but instead link against the libcurl from nixpkgs
      installCheckPhase = lib.optionalString (stdenv.hostPlatform.libc == "glibc") ''
        runHook preInstallCheck

        ldd "$out/bin/zellij" | grep libcurl.so

        runHook postInstallCheck
      '';

      postInstall = ''
        mandown docs/MANPAGE.md > zellij.1
        installManPage zellij.1
      ''
      + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        installShellCompletion --cmd $pname \
          --bash <($out/bin/zellij setup --generate-completion bash) \
          --fish <($out/bin/zellij setup --generate-completion fish) \
          --zsh <($out/bin/zellij setup --generate-completion zsh)
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        description = "Terminal workspace with batteries included";
        homepage = "https://zellij.dev/";
        changelog = "https://github.com/zellij-org/zellij/blob/v${finalAttrs.version}/CHANGELOG.md";
        license = with lib.licenses; [ mit ];
        maintainers = with lib.maintainers; [
          therealansh
          _0x4A6F
          abbe
          matthiasbeyer
          ryan4yin
        ];
        mainProgram = "zellij";
      };
    })
  ) { };
}
