{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.baseline.spotify;
in
{
  config = mkIf cfg.anyEnabled {
    # Discover with mDNS
    networking.firewall.allowedUDPPorts = [ 5353 ];
    # sync local tracks
    networking.firewall.allowedTCPPorts = [ 57621 ];
  };
}
