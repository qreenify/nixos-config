{ config, pkgs, ... }:

{
  # Graphics
  hardware.graphics.enable = true;

  # NVIDIA
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Force NVIDIA modesetting (critical for display detection)
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Ensure nvidia-drm module loads early
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
}
