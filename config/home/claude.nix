{
  pkgs,
  lib,
  config,
  ...
}:
# TODO(26.11): this is upstream in
let
  cfg = config.programs.claude-code;
  jsonFormat = pkgs.formats.json { };

  isMcpServerEnabled =
    server:
    let
      enabled = server.enabled or null;
      disabled = (server.disabled or false) == true;
    in
    enabled != false && !disabled;

  # Shared MCP servers participate only when both integrations are enabled.
  sharedMcpServers = lib.optionalAttrs (
    cfg.enableMcpIntegration && config.programs.mcp.enable
  ) config.programs.mcp.servers;

  disabledMcpServerNames = lib.attrNames (
    lib.filterAttrs (_: server: !(isMcpServerEnabled server)) (sharedMcpServers // cfg.mcpServers)
  );
  mkMarketplaceEntry = _name: content: {
    source = {
      source = "directory";
      path = content;
    };
  };
in
{
  home.file = lib.mkMerge [
    (lib.mkIf (cfg.settings != { } || cfg.marketplaces != { } || disabledMcpServerNames != [ ]) {
      "${cfg.configDir}/settings.json".source = lib.mkForce (
        let
          settingsFile = jsonFormat.generate "claude-code-settings.json" (
            cfg.settings
            // {
              "$schema" = "https://json.schemastore.org/claude-code-settings.json";
            }
            // lib.optionalAttrs (cfg.marketplaces != { }) {
              extraKnownMarketplaces = lib.mapAttrs mkMarketplaceEntry cfg.marketplaces;
            }
            // lib.optionalAttrs (disabledMcpServerNames != [ ]) {
              disabledMcpjsonServers = lib.unique (
                (cfg.settings.disabledMcpjsonServers or [ ]) ++ disabledMcpServerNames
              );
            }
          );

          settingsDirectory = pkgs.runCommand "claude-code-settings-directory" { } ''
            install -Dm444 ${settingsFile} "$out/settings.json"
          '';
        in
        "${settingsDirectory}/settings.json"
      );
    })
  ];

}
