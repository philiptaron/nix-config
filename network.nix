{ config, pkgs, inputs, ... }:

{
  # Enable networking through systemd-networkd; don't use the built-in NixOS modules.
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.useNetworkd = false;
  systemd.network.enable = true;
  systemd.network.netdevs = {
    "wlan1" = {
      netdevConfig.Name = "wlan1";
      netdevConfig.Kind = "wlan";
      wlanConfig.PhysicalDevice = 0;
      wlanConfig.Type = "station";
    };
  };
  systemd.network.networks = {
    "wlan" = {
      matchConfig.Type = "wlan";
      matchConfig.WLANInterfaceType = "station";
      networkConfig.DHCP = "yes";
      dhcpV4Config.Anonymize = "yes";
    };
  };

  # Enable wifi through iwd; turn on developer mode (--developer) and debug logging (--debug)
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.package = pkgs.iwd.overrideAttrs (prevAttrs: {
    preFixup = prevAttrs.preFixup + ''
      sed -i -e "s,ExecStart.*,\0 --developer --debug," $out/lib/systemd/system/iwd.service
    '';
  });
  networking.wireless.iwd.settings = {
    General.UseDefaultInterface = true;
    General.DisableANQP = false;
    General.Country = "US";
    Scan.DisableRoamingScan = true;
    Scan.InitialPeriodicScanInterval = 1;
    Scan.MaximumPeriodicScanInterval = 60;
  };

  environment.systemPackages = with pkgs; [
    # `iw` is a new nl80211 based CLI configuration utility for wireless devices.
    # https://wireless.wiki.kernel.org/en/users/Documentation/iw
    iw

    # Brings `iwpriv`, `iwconfig`, `iwgetid`, `iwspy`, `iwevent`, `ifrename`, and `iwlist` tools.
    # These are old but still work. https://github.com/HewlettPackard/wireless-tools
    wirelesstools
  ];
}
