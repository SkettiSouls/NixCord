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
    appBadge = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable showing mention badge (red dot) on the app icon.
      '';
    };

    arRPC = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables Rich Presence via arRPC.
      '';
    };

    clickTrayToShowHide = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables left clicking the tray icon to show/hide vesktop.
      '';
    };

    customTitleBar = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable using Discord's custom title bar
        instead of the native system titlebar.
      '';
    };

    disableMinSize = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Disable minimum window size.
      '';
    };

    disableSmoothScroll = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Disables smooth scrolling.
      '';
    };

    discordBranch = mkOption {
      type = types.enum [
        "stable"
        "canary"
        "ptb"
      ];
      default = "stable";
    };

    enableMenu = mkEnableOption {
      description = ''
        Enable the application menu bar.
        Press ALT to toggle visibility.
      '';
    };

    hardwareAcceleration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable hardware acceleration.
      '';
    };

    minimizeToTray = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Minimize to tray instead of closing.
      '';
    };

    openLinksWithElection = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables opening links in a new Vesktop
        window instead of in a browser.
      '';
    };

    # TODO?: Make splash colors a list of 3 ints mapped to `rgb(x, y, z)`
    splashBackground = mkOption {
      type = types.str;
      default = "rgb(138, 148, 168)";
      description = ''
        Splash background color as defined by rgb values.
      '';
    };

    splashColor = mkOption {
      type = types.str;
      default = "rgb(22, 24, 29)";
      description = ''
        Splash color as defined by rgb values.
      '';
    };

    splashTheming = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Adapt the splash window colors to your custom theme.
      '';
    };

    staticTitle = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Makes the window title 'Vesktop' instead
        of changing to the current page.
      '';
    };

    tray = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the vesktop tray icon.
      '';
    };
  };
}
