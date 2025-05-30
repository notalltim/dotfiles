{
  pkgs,
  config,
  ...
}:
let
  inherit (config.baseline) userspec;
  gpuWrapCheck = config.lib.nixGL.wrap;
in
{
  imports = [
    ./userspec.nix
  ];
  home = {
    stateVersion = "24.11";
    homeDirectory = "/home/${userspec.username}";
    username = userspec.username;
    enableDebugInfo = true;

    packages = with pkgs; [
      (gpuWrapCheck kicad)
      (gpuWrapCheck freecad)
      jellyfin-media-player
      discord
      radeontop
      bitwarden
      audacity
      mprime
      nvtopPackages.amd
      openrgb-with-all-plugins
      (python3.withPackages (
        pkgs: with pkgs; [
          numpy
          scipy
          matplotlib
        ]
      ))
    ];
  };
  programs.fish.functions = {
    sudos = {
      body = ''command sudo env "PATH=\$PATH" $argv'';
      wraps = "sudo";
    };
  };

  # For gdb debugging
  services.nixseparatedebuginfod.enable = true;

  # Common config expressed as basic modules
  baseline = {
    nixvim = {
      enableAll = true;
      completion.codeium.apikey = ./secrets/codeium-apikey.age;
    };
    kitty.enableKeybind = true;
    packages.enable = true;
    home-manager.enable = true;
    nix = {
      enable = true;
      accessTokensPath = ./secrets/access-tokens.age;
    }; # TODO: this does not cover the case I want it does not control the nix version
    tools.enable = true;
    terminal.enable = true;
    non-nixos = {
      enable = config.baseline.hostspec.platform != "nixos";
      gpu.enableVulkan = true;
    };
    ssh = {
      enable = true;
      pubkey = ./id_ed25519.pub;
      privkey = ./secrets/ssh-key-home.age;
    };
    firefox = {
      enable = true;
    };
    stylix.enable = true;
  };

  services.gpg-agent.enable = true;
  programs.gpg.enable = true;
  programs.git = {
    signing = {
      key = "5A2DAA31F5457F29";
    };
    userEmail = "timbama@gmail.com";
    userName = userspec.fullName;
  };
}
