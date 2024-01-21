{...}: {
  services.ssh-agent = {
    enable = true;
  };
  services.nixseparatedebuginfod.enable = true;
  systemd.user = {
    startServices = true;
    systemctlPath = "/usr/bin/systemctl";
  };
  imports = [./nixseparatedebuginfod_module.nix];
}
