{ pkgs }:
let
  astronvim = import ./astronvim { inherit pkgs; };

in
{
  files = astronvim.files;
  programs = {
    neovim = astronvim.config;
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      signing = {
        key = "5A2DAA31F5457F29";
        signByDefault = true;
      };
      userEmail = "timbama@gmail.com";
      userName = "Timothy Gallion";

      includes = [{
        contents = {
          commit = {
            gpgSign = true;
          };
          core = {
            editor = "nvim";
          };
          color = {
            ui = "auto";
          };
          push = {
            autoSetupRemote = true;
          };
        };
      }];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };

    zellij = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        theme = "nightfox";
        themes = {
          nightfox = {
            bg = "#192330";
            fg = "#cdcecf";
            red = "#c94f6d";
            green = "#81b29a";
            blue = "#719cd6";
            yellow = "#dbc074";
            magenta = "#9d79d6";
            orange = "#f4a261";
            cyan = "#63cdcf";
            black = "#29394f";
            white = "#aeafb0";
          };
        };
      };
    };
    fish = {
      enable = true;
      plugins = [
        {
          name = "bass";
          src = pkgs.fetchFromGitHub {
            owner = "edc";
            repo = "bass";
            rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
            hash = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
          };
        }
        {
          name = "nix.fish";
          src = pkgs.fetchFromGitHub {
            owner = "kidonng";
            repo = "nix.fish";
            rev = "ad57d970841ae4a24521b5b1a68121cf385ba71e";
            hash = "sha256-GMV0GyORJ8Tt2S9wTCo2lkkLtetYv0rc19aA5KJbo48=";
          };
        }
      ];
    };
    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      font = {
        name = "CaskaydiaCove Nerd Font";
        package = pkgs.nerdfonts;
      };
      settings = {
        enable_audio_bell = false;
      };
    };
    oh-my-posh = {
      enable = true;
      enableFishIntegration = true;
      useTheme = "pure";
    };
  };
  gpg = {
    enable = true;
  };
}
