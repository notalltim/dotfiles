{
  pkgs,
  userEmail,
  signingKey,
  ...
}: let
  hasKey = signingKey != "";
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

    includes = [
      {
        contents = {
          commit = {gpgSign = hasKey;};
          core = {
            editor = "nvim";
            # fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
            # fsmonitor = ".git/hooks/fsmonitor-watchman.sample";
            autocrlf = "input";
            # fsmonitorHookVersion = "2";
            # core.untrackedcache = true;
          };
          color = {ui = "auto";};
          push = {autoSetupRemote = true;};
        };
      }
    ];
  };
}
