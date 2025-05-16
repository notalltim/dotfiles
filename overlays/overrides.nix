final: prev: {
  # This is to allow systemd tmpfiles not to freak out when home-manager tries to restart it
  sd-switch = prev.sd-switch.overrideAttrs (drv: rec {
    version = "0.5.4";
    name = "sd-switch-${version}";
    src = final.fetchFromSourcehut {
      owner = "~rycee";
      repo = "sd-switch";
      rev = "0.5.4";
      hash = "sha256-lP65PrMFhbNoWyObFsJK06Hgv9w83hyI/YiKcL5rXhY=";
    };
    cargoDeps = drv.cargoDeps.overrideAttrs (
      final.lib.const {
        name = "${name}-vendor.tar.gz";
        inherit src;
        outputHash = "sha256-0Mlil/1JrvUiHGfn1EViOd+mOSVuHG5uLSUWdrdcIKA=";
      }
    );
  });
}
