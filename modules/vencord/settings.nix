{ lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
in
{
  options = {
    autoUpdate = mkEnableOption "Automatic vencord updates";
    autoUpdateNotification = mkEnableOption "Notify about new versions of vencord";

    enableReactDevtools = mkEnableOption "React Developer Tools";

    frameless = mkEnableOption "Disable the window frame";

    notifyAboutUpdates = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Allow receiving in-app notifications when a new version of vencord is released.
      '';
    };

    transparent = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable window transparency.
        <emphasis>This requires a theme that supports transparency to take effect.</emphasis>.
        <emphasis>This will prevent window resizing</emphasis>.
      '';
    };

    themeLinks = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        List of links to vencord themes. All links WILL be enabled.
        Probably a bad idea to use this if using the `vencord.themes` option.
      '';
    };

    notifications = {
      timeout = mkOption {
        type = types.ints.between 0 20000;
        default = 5000;
        description = ''
          Time to elapse (in milliseconds) before notifications fade.
        '';
      };

      position = mkOption {
        type = types.enum [ "bottom-right" "top-right" ];
        default = "bottom-right";
        description = ''
          Position of native discord notification pop-ups.
        '';
      };

      useNative = mkOption {
        type = types.enum [
          "not-focused" # only when discord is NOT focused
          "always"
          "never"
        ];

        default = "not-focused";
        description = ''
          When to use native desktop notifications (i.e. dunst/mako).
          Setting this to `always` nullifies `notifications.position`.
        '';
      };

      logLimit = mkOption {
        type = types.ints.between 0 200;
        default = 50;
        description = ''
          Number of notifications to save in the log before removing old ones.
          Set to 0 to disable notification logging, and set to 200 to keep
          ALL notifications logged.
        '';
      };
    };
  };
}
