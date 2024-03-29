{
  config,
  lib,
  modulesPath,
  options,
  pkgs,
  specialArgs,
}:

{
  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;

    # See `nixos/modules/services/x11/xserver.nix` and the list of included packages.
    excludePackages = [ pkgs.xterm ];

    # Enable the GNOME display manager (gdm).
    displayManager.gdm.enable = true;
    displayManager.gdm.debug = true;

    # Enable the GNOME Desktop Environment (minimal!)
    displayManager.sessionPackages = with pkgs; [ gnome.gnome-session.sessions ];

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Make both gdm and my user session use the same `monitors.xml` file.
  # This is specific to zebul, and will eventually be split out.
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${dotfiles/gnome/monitors.xml}"
  ];

  systemd.user.tmpfiles.users.philip.rules = [
    "L+ %h/.config/monitors.xml - - - - ${dotfiles/gnome/monitors.xml}"
  ];

  # Make the fonts look better.
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      cantarell-fonts
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Noto Sans Mono" ];
    };
  };

  # Turn on ibus IME.
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];

  # Turn on GNOME systemd packages
  systemd.packages = with pkgs; [
    gnome.gnome-session
    gnome.gnome-shell
  ];

  environment.systemPackages = with pkgs; [
    # The GNOME shell is the core GNOME package
    gnome.gnome-shell

    # The logs for GNOME
    gnome.gnome-logs

    # Small utility to dump info about DRM devices.
    # https://gitlab.freedesktop.org/emersion/drm_info
    drm_info

    # Test utilities for OpenGL
    # https://dri.freedesktop.org/wiki/glxinfo/
    glxinfo

    # Tool for reading and parsing EDID data from monitors
    # http://www.polypux.org/projects/read-edid/
    read-edid

    # EDID decoder and conformance tester
    # https://git.linuxtv.org/edid-decode.git
    edid-decode

    # Provides the `vkcube`, `vkcubepp`, `vkcube-wayland`, and `vulkaninfo` tools.
    # https://github.com/KhronosGroup/Vulkan-Tools
    vulkan-tools
  ];

  # Enable the GNOME keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable discovery of GNOME stuff. We'll try to get a smaller hammer over time.
  # Ideally, each different extension should end up adding its own thing here, I think.
  environment.pathsToLink = [ "/share" ];

  services.udev.packages = with pkgs; [
    # Force enable KMS modifiers for devices that require them.
    # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1443
    gnome.mutter
  ];

  # Various customizations of GNOME.
  users.users.philip.packages = with pkgs; [
    # `dconf-editor` is a GSettings editor for GNOME.
    # https://wiki.gnome.org/Apps/DconfEditor
    gnome.dconf-editor

    # `gnome-calculator` solves mathematical equations
    # https://wiki.gnome.org/Apps/Calculator
    gnome.gnome-calculator

    # `gnome-calendar` is a simple and beautiful calendar application.
    # https://wiki.gnome.org/Apps/Calendar
    gnome.gnome-calendar

    # `gnome-control-center` allows controlling settings in the GNOME desktop
    # https://gitlab.gnome.org/GNOME/gnome-control-center
    gnome.gnome-control-center

    # `gnome-sound-recorder` is a simple and modern sound recorder.
    # https://wiki.gnome.org/Apps/SoundRecorder
    gnome.gnome-sound-recorder

    # Utility used in the GNOME desktop environment for taking screenshots
    # https://gitlab.gnome.org/GNOME/gnome-screenshot
    gnome.gnome-screenshot

    # `nautilus` is the file manager for GNOME. It's also known as "Files".
    # https://apps.gnome.org/Nautilus/
    gnome.nautilus

    # `seahorse` is an application for managing encryption keys and passwords in the GNOME keyring.
    # https://wiki.gnome.org/Apps/Seahorse
    gnome.seahorse

    # A simple app icon taskbar. Show running apps and favorites on the main panel.
    # https://extensions.gnome.org/extension/4944/app-icons-taskbar/
    gnomeExtensions.app-icons-taskbar

    # Adds a clock to the desktop.
    # https://extensions.gnome.org/extension/5156/desktop-clock/
    gnomeExtensions.desktop-clock

    # Move clock to left of status menu button
    # https://extensions.gnome.org/extension/2/move-clock/
    gnomeExtensions.move-clock

    # Allows the customization of the date format on the GNOME panel.
    # https://extensions.gnome.org/extension/3465/panel-date-format/
    gnomeExtensions.panel-date-format-2

    # `gnome-connections` is a remote desktop client for the GNOME desktop environment.
    # https://gitlab.gnome.org/GNOME/connections
    gnome-connections

    # `loupe` is a simple image viewer application written with GTK4 and Rust.
    loupe
  ];

  # Enable XDG portal support
  xdg.portal.enable = true;
  xdg.portal.configPackages = with pkgs; [ gnome.gnome-session ];
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    (xdg-desktop-portal-gtk.override {
      # Do not build portals that we already have.
      buildPortalsInGnome = false;
    })
  ];

  # Start the GNOME settings daemon.
  services.gnome.gnome-settings-daemon.enable = true;

  # Turn on dconf setting. Super minimal.
  programs.dconf.enable = true;

  # Turn on Evince, the GNOME document viewer
  # https://wiki.gnome.org/Apps/Evince
  programs.evince.enable = true;
}
