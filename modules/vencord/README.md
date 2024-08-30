<h1 align="center">Vencord</h2>

#### Vencord Settings
Configuring Vencord settings (behavior, updating, notifications, etc) is pretty straightforward:

```nix
# Example config
nixcord.vencord = {
  enable = true;
  settings = {
    enableReactDevtools = true;
    frameless = true;
    notifyAboutUpdates = false;

    notifications = {
      timeout = 5000; # milliseconds
      position = "bottom-right";
      useNative = "always";
      logLimit = 0;
    };
  };
};
```

#### Plugins

Plugin config syntax adheres to standard nix convention, with attribute names derived from the vencord JSON.
You can find the names of plugins and their settings via exporting vencord settings from the discord settings page, or by reading through the file at `~/.config/Vencord/settings/settings.json`

```nix
nixcord.vencord.plugins = {
  AlwaysAnimate.enable = true;
  Decor.enable = true;
  EmoteCloner.enable = true;

  BetterFolders = {
    enable = true;
    settings = {
      closeAllFolders = true;
      closeOthers = false;
      showFolderIcon = 1;
    };
  };

  FakeNitro = {
    enable = true;
    settings = {
      enableEmojiBypass = true;
      emojiSize = 48;
      transformEmojis = true;
      enableStreamQualityBypass = true;
    };
  };
};
```

For your convenience, NixCord includes the `enabledPlugins` option, allowing you to provide a list of plugins to enable without configuring. This is nice for the plugins without settings (i.e. AlwaysAnimate, DisableCallIdle, etc.)

```nix
nixcord.vencord.enabledPlugins = [
  "AlwaysAnimate"
  "DisableCallIdle"
  "EmoteCloner"
  "FavriteEmojiFirst"
];
```

#### Themes

NixCord handles themes similarly to [home-manager](https://github.com/nix-community/home-manager)'s `home.file` option:

```nix
nixcord.vencord.themes = {
    myTheme = {
      enable = true;
      source = /relative/path/to/source; # Use `nixcord.vencord.settings.themeLinks` for links.
    };

    anotherTheme = {
      enable = false;
      source = "/path/to/source";
    };

    yetAnotherTheme = {
      enable = false;
      text = ''
        Theme CSS goes here.
      '';
    };
};
```

**It's recommended that you add your theme as a flake input and use the nix-store path as your source, so as to allow for easy updating:**
```nix
# flake.nix
{
  inputs.example-theme = {
    type = "git";
    url = "https://github.com/theme/repo";
    flake = false;
  };
}
```
```nix
# vencord.nix
{ inputs, ... }:

{
  nixcord.vencord.themes = {
    example-theme = {
      enable = true;

      # This will be the nix store path, since non-flake inputs
      # just store the entire repo on the nix store.
      source = "${inputs.example-theme}/theme-name.css"
    };
  };
}
```

<h1 align="center">Vesktop</h1>

#### NixCord handles *most* state for you, with a couple exceptions.

* Window bounds
* Display ID

Both of these values are set dynamically by vesktop, and will cause crashes if non-writable. All other state, such as Discord branch, tray icon settings, and splash theming, are handled in nix.
```nix
nixcord.vesktop = {
  enable = true;
  state = {
    discordBranch = "stable";
    arRPC = false;
    tray = false;
    minimizeToTray = false;
    disableMinSize = true;
  };
};
```

Enabling vesktop overrides the default package of `nixcord.vencord.package`, while using the configuration values of `nixcord.vencord.settings` and `nixcord.vencord.plugins`. This avoids needing to configure vencord when switching from/using non-vesktop clients.

**It's recommended that you add an input and overlay specifically for vesktop, to allow for easy regular updates:**
```nix
# flake.nix
{
  inputs.vesktop.url = "github:nixos/nixpkgs/nixos-unstable";
}
```

```nix
# overlays.nix
{ inputs, pkgs, ... }: with inputs;
let
  inherit (pkgs.stdenv.hostPlatform) system;

  overlay-unstable = final: prev: {
    # unrelated recommendation: nixpkgs-unstable overlay

    # Replaces `pkgs.vesktop` with `pkgs.vesktop` from `inputs.vesktop`
    vesktop = vesktop.legacyPackages.${system}.vesktop;
  };
in
{
  nixpkgs.overlays = [ overlay-unstable ];
}
```

Now to update vesktop (or vencord), you simply run `nix flake lock --update-input vesktop` and rebuild.
