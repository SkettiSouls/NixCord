{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mapAttrs'
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    nameValuePair
    recursiveUpdate
    types
    ;

  inherit (builtins)
    listToAttrs
    toJSON
    ;

  inherit (config.nixcord) vesktop;

  pluginSubmodule = types.submodule {
    options = {
      enable = mkEnableOption "Enable specified plugin";
      settings = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };

  cfg = config.nixcord.vencord;
  configDir = {
    vencord = ".config/Vencord";
    vesktop = ".config/vesktop";
  };
in
{
  options.nixcord = {
    vencord = {
      enable = mkOption {
        type = types.bool;
        default = if vesktop.enable then true else false;
      };

      # Convenient for plugins that don't have settings (i.e. AlwaysAnimate)
      enabledPlugins = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          List of plugins to be enabled.
          Functionally identical to <literal>plugins.<plugin-name>.enable = true</literal>.
        '';
      };

      package = mkPackageOption pkgs "Discord package" { default = null; };

      plugins = mkOption {
        type = with types; attrsOf pluginSubmodule;
        description = ''
          Vencord plugin configuration.
          Plugin names are USUALLY in pascal case ('PluginNameExample'), while
          plugin settings are USUALLY in lower camel case ('pluginSettingExample').
          If unsure, you can export vencord settings and check the JSON.
        '';
      };

      settings = mkOption {
        type = types.submodule ./settings.nix;
        description = ''
          Declares the JSON options in `~/.config/Vencord/settings/settings.json`.
          These can be found in the 'VENCORD' section of discord settings,
          under the 'Vencord' and 'Updater' sections.
        '';
      };

      themes = mkOption {
        type = with types; attrsOf (submodule {
          options = {
            enable = mkEnableOption "Enable theme";

            source = mkOption {
              type = with types; either str path;
              default = "";
            };

            text = mkOption {
              type = with types; either str lines;
              default = "";
            };
          };
        });
      };
    };

    vesktop = {
      enable = mkEnableOption "Vesktop client";
      package = mkPackageOption pkgs "vesktop" {};

      # Semi-cursed
      state = mkOption {
        type = types.submodule ./state.nix;
        description = ''
          Options for managing vesktop state, with a caveat:
          While `~/${configDir.vesktop}/settings.json` can be declared,
          Vesktop requires that `~/${configDir.vesktop}/state.json` be writeable,
          opting to crash if the file is read-only.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    nixcord.vencord.package = if vesktop.enable
      then mkDefault vesktop.package
      else mkDefault (pkgs.discord.override { withVencord = true; });

    home.packages = [ cfg.package ];

    home.file = mkMerge [
      (mapAttrs'
        (name: attrs: nameValuePair
          ".config/Vencord/themes/${name}.css"
          {
            # TODO: Prevent both text and source being set
            text = mkIf (attrs.text != "") attrs.text;
            source = mkIf (attrs.source != "") attrs.source;
          }
        )
      cfg.themes)

      {
        ".config/Vencord/settings/settings.json".text = toJSON (recursiveUpdate
          cfg.settings
          {
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
      (if vesktop.enable
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

      (if vesktop.enable
        then {
          # Vesktop can't work without write access to `state.json`, and will error on first launch if settings.json is read-only.
          # For now, when running for the first time you must hit the 'submit' button, and then close and reopen vesktop.

          # TODO: Find a way around 'Welcome to Vesktop' menu.
          # ALTERNATIVE: Find a way to disable vesktop writing window bounds to state.json.

          ".config/vesktop/settings.json".text = toJSON vesktop.state;
          ".config/vesktop/settings/settings.json".text = config.home.file.".config/Vencord/settings/settings.json".text;
        }
      else {})
    ];
  };
}
