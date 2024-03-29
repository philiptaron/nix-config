{
  config,
  lib,
  modulesPath,
  options,
  pkgs,
  specialArgs,
}:

{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
  boot.blacklistedKernelModules = [ ];

  # Make the mode 3840x1600, because that's what efifb mode 0 means on this system.
  boot.kernelParams = [ "video=efifb:mode=0" ];

  # Turn on the NVIDIA settings GUI.
  hardware.nvidia.nvidiaSettings = true;

  # Use the latest NVIDIA out-of-tree drives.
  # See https://www.nvidia.com/en-us/drivers/unix/linux-amd64-display-archive/
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production.override {
    disable32Bit = true;
  };
  boot.extraModulePackages = [ config.hardware.nvidia.package ];

  # The zone of "Are we Wayland yet?" with the answer "mostly not".
  hardware.nvidia.modesetting.enable = false;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false;

  # These settings don't do anything right now. They're correct with respect to zebul, though.
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.prime.amdgpuBusId = "PCI:17:0:0";

  # Enable Bluetooth.
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs.gnome; [ gnome-bluetooth ];

  # Enable Bolt, a userspace daemon to enable security levels for Thunderbolt 3.
  services.hardware.bolt.enable = true;
}
