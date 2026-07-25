_: (builtins.getFlake "path:${toString ./.}").legacyPackages.${builtins.currentSystem}
