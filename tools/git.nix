{ pkgs
, userEmail
, signingKey
, ...
}:
let
  hasKey = signingKey != "";
in
{
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
          commit = { gpgSign = hasKey; };
          core = {
            editor = "nvim";
            fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
          };
          color = { ui = "auto"; };
          push = { autoSetupRemote = true; };
        };
      }
    ];
  };
}
