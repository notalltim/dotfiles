final: prev: {
  shared-mime-info-2-1 = prev.shared-mime-info.overrideAttrs (
    _: (import ../pkgs/shared-mime-info.nix final)
  );
}
