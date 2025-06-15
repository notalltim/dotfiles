_final: prev: {
  blueberry = prev.blueberry.overrideAttrs (old: {
    meta = old.meta // {
      mainProgram = "blueberry";
    };
  });
}
