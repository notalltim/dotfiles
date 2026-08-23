{ lib, ... }: {
  _module.args.baselineLib = {
    mkPathReproducible = path: builtins.path { inherit path; };
    hypr =
      let
        inherit (lib.generators) mkLuaInline;
        inherit (lib) nameValuePair;
        mkVar = val: { _var = val; };
        mkMultiArgFunction = args: { _args = args; };

        mkModifier = mod: keys: if mod != null then mkLuaInline "${mod} .. \" + ${keys}\"" else keys;

        mkBindWithFlags =
          flags: mod: key: description: dispatcher:
          mkMultiArgFunction [
            (mkModifier mod key)
            (mkLuaInline dispatcher)
            ({ inherit description; } // (builtins.listToAttrs (map (flag: nameValuePair flag true) flags)))
          ];
        mkMultiBindWithFlags =
          flags: keys: mod: descriptionByKey: dispatcherByKey:
          map (
            key:
            let
              evalByKey = byKey: if builtins.isFunction byKey then byKey key else byKey;
            in
            mkBindWithFlags flags mod key (evalByKey descriptionByKey) (evalByKey dispatcherByKey)
          ) keys;
      in
      {
        inherit
          mkVar
          mkModifier
          mkBindWithFlags
          mkMultiBindWithFlags
          mkMultiArgFunction
          ;

        mkBind = mkBindWithFlags [ ];

        mkMultiBind = mkMultiBindWithFlags [ ];
      };
  };
}
