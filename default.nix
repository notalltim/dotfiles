_: (builtins.getFlake "path:${builtins.toString ./.}").legacyPackages.${builtins.currentSystem}
