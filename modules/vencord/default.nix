{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mapAttrs'
    mkDefault
    mkIf
    mkMerge
    nameValuePair
    recursiveUpdate
    ;

  inherit (builtins)
    listToAttrs
    ;

  cfg = config.programs.vencord;
  mkConfig = builtins.toJSON;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    programs.vencord.package = if cfg.vesktop.enable
      then mkDefault cfg.vesktop.package
      else mkDefault (pkgs.discord.override { withVencord = true; });

    home.packages = [ cfg.package ];

    home.file = mkMerge [
      (mapAttrs'
        (name: attrs: nameValuePair
          ".config/Vencord/themes/${name}.css"
          {
            text = mkIf (attrs.text != "") attrs.text;
            source = mkIf (attrs.source != "") attrs.source;
          }
        )
      cfg.themes)

      {
        ".config/Vencord/settings/settings.json".text = mkConfig (recursiveUpdate
          cfg.settings
          {
            inherit (cfg) notifications cloud;
            enabledThemes = lib.mapAttrsToList (name: attrs: (if attrs.enable then name + ".css" else "")) cfg.themes;
            plugins =
              # Convert enabled plugins list to "plugin":{ "enabled" = true }
              (listToAttrs (map
                (plugins: nameValuePair
                  plugins
                  { enabled = true; }
                )
              cfg.enabledPlugins)) //
              # Make cfg.plugins map to JSON correctly.
              (mapAttrs'
                (name: plugin: nameValuePair
                  name
                  ({ enabled = plugin.enable; } // plugin.settings)
                )
              cfg.plugins);
          }
        );
      }

      # Vesktop settings are taken from vencord settings to allow using vesktop and 
      # other clients simultaneously. (i.e. using `nix run nixpkgs#discord` for testing)
      (if cfg.vesktop.enable
        then (mapAttrs'
          (name: attrs: nameValuePair
            ".config/vesktop/themes/${name}.css"
            {
              text = mkIf (attrs.text != "") attrs.text;
              source = mkIf (attrs.source != "") attrs.source;
            }
          )
        cfg.themes)
      else {})

      (if cfg.vesktop.enable
        then {
          # Vesktop can't work without write access to `state.json`, and will error on first launch if settings.json is read-only.
          # For now, when running for the first time you must hit the 'submit' button, and then close and reopen vesktop.

          # TODO: Find a way around 'Welcome to Vesktop' menu.
          # ALTERNATIVE: Find a way to disable vesktop writing window bounds to state.json.

          ".config/vesktop/settings.json".text = mkConfig cfg.vesktop.state;
          ".config/vesktop/settings/settings.json".text = config.home.file.".config/Vencord/settings/settings.json".text;
        }
      else {})
    ];
  };
}
