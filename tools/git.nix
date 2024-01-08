{ pkgs, userEmail, signingKey, ... }:
let hasKey = signingKey != "";
in {
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      key = signingKey;
      signByDefault = hasKey;
    };
    userEmail = userEmail;
    userName = "Timothy Gallion";

    includes = [{
      contents = {
        commit = { gpgSign = hasKey; };
        core = { editor = "nvim"; };
        color = { ui = "auto"; };
        push = { autoSetupRemote = true; };
      };
    }];
  };
}
