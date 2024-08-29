{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.programs.vencord;
in
{
  options.programs.vencord = {
    enable = mkEnableOption "Vencord discord client mod";
    package = mkPackageOption pkgs "Discord package" { default = null; };

    vesktop = {
      enable = mkOption {
        description = ''Use vesktop instead of the official client.'';
        type = types.bool;
        default = true;
      };

      package = mkPackageOption pkgs "vesktop" {};

      state = mkOption {
        # TODO?: Assert for `firstLaunch = false;`, breaks vesktop on first launch.
        description = ''Vesktop app settings.'';
        type = types.attrs;
        default = {};
        example = {
          discordBranch = "stable";
          splashTheming = true;
          splashColor = "rgb(138,148,168)";
          arRPC = "off";
        };
      };
    };

    settings = mkOption {
      description = ''Vencord settings.'';
      default = { };
      type = types.attrs;
      example = {
        autoUpdate = true;
        useQuickCss = false;
        enableReactDevtool = false;
        themeLinks = [
          "https://mytheme.url/path/to/theme.css"
        ];
      };
    };

    plugins = mkOption {
      description = ''Vencord plugins.'';
      default = { };
      type = with types; attrsOf (submodule {
        options = {
          enable = mkEnableOption "Enable specified plugin.";
          settings = mkOption {
            type = types.attrs;
            default = { };
          };
        };
      });

      example = {
        GifPaste.enable = true;
        ImageZoom = {
          enable = true;
          settings = {
            nearestNeighbour = false;
            zoom = 2;
            size = 100.00;
          };
        };
      };
    };

    # Convenient for plugins that don't have settings.
    enabledPlugins = mkOption {
      description = ''List of plugins to enable.'';
      default = [ ];
      type = with types; listOf str;
      example = [
        "AlwaysAnimate"
        "GifPaste"
      ];
    };

    notifications = mkOption {
      description = ''Vencord notification settings.'';
      type = with types; attrsOf (either str int);
      example = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };
    };

    cloud = mkOption {
      description = ''Vencord cloud integration settings.'';
      default = { };
      type = types.attrs;
      example = {
        authenticated = true;
        url = "https://api.vencord.dev";
        settingsSync = true;
      };
    };

    themes = mkOption {
      description = ''Local css themes for vencord.'';
      default = { };
      type = with types; attrsOf (submodule {
        options = {
          enable = mkEnableOption "Enable theme";

          source = mkOption {
            type = with types; (either str path);
            default = "";
          };

          text = mkOption {
            type = with types; (either str lines);
            default = "";
          };
        };
      });

      example = {
        mytheme.text = "custom css";
        mytheme2.source = ./path/to/css;
      };
    };
  };
}
