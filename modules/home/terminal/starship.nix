{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in
{
  programs.starship = mkIf cfg.enable {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        staged = "[+\($count\)](bold green) ";
        conflicted = "[=\($count\)](bold orange) ";
        untracked = "[?\($count\)](bold magenta) ";
        modified = "[~\($count\)](bold yellow) ";
        renamed = "[>>\($count\)](bold yellow) ";
        deleted = "[✘\($count\)](bold yellow) ";
        stashed = "[ \($count\)](bold blue)";
        format = "([$ahead_behind]($style) $staged$conflicted$modified$renamed$deleted$untracked $stashed )";
      };
      git_state = {
        cherry_pick = "[🍒 PICKING](bold red)";
        rebase = "[📏 REBASING](bold red)";
        bisect = "[🪓 BISECTING](bold red)";
        revert = "[🚑 REVERTING](bold red)";
        merge = "[👪 MERGING](bold red)";
      };
      shell = {
        disabled = false;
        bash_indicator = "🐂";
        fish_indicator = "";
      };
      status.disabled = false;
      sudo.disabled = false;
      battery.display = [
        {
          threshold = 10;
          style = "bold red";
        }
        {
          threshold = 30;
          style = "bold yellow";
        }
      ];
    };
  };
}
