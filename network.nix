{
  config,
  lib,
  modulesPath,
  options,
  pkgs,
  specialArgs,
}:

{
  # Enable networking through systemd-networkd; don't use the built-in NixOS modules.
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.useNetworkd = false;
  systemd.network.enable = true;

  # Turn on verbose logging for systemd-networkd.
  systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";

  # Adjust wlan0 to have the highest MTU that this device offers.
  systemd.network.links = {
    "79-wlan0" = {
      matchConfig.OriginalName = "wlan0";
      matchConfig.Type = "wlan";
      linkConfig.NamePolicy = "keep kernel";
      linkConfig.MTUBytes = "2304";
    };
  };

  # Use DHCP to configure wlan station devices.
  systemd.network.networks = {
    "ether-uses-dhcp" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
      dhcpV4Config.UseMTU = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # `batctl` are the controls for the B.A.T.M.A.N. advanced mesh tool.
    batctl

    # `iw` is a new nl80211 based CLI configuration utility for wireless devices.
    # It doesn't work super well since it doesn't know how to make use of WPA to authenticate.
    # https://wireless.wiki.kernel.org/en/users/Documentation/iw
    iw

    # `wpa_supplicant` is a tool for connecting to WPA and WPA2-protected wireless networks.
    # We're not using it for anything other than being able to connect to WiFi if we need to.
    # https://w1.fi/wpa_supplicant/
    wpa_supplicant

    # `iwd` is a wireless daemon for Linux.
    # We're not using it for anything other than being able to connect to WiFi if we need to.
    # https://git.kernel.org/pub/scm/network/wireless/iwd.git
    iwd
  ];
}
