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

  # Fix RTX 4080 power management - prevent freezes from GPU clock ramping
  # Issue: GPU idles at 210 MHz, causes 1-second freezes when ramping to ~2500 MHz
  # Solution: Force "Prefer Maximum Performance" mode (keeps clocks at ~2500 MHz)
  systemd.services.nvidia-prefer-max-performance = {
    description = "Set NVIDIA GPU to Prefer Maximum Performance";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    path = [ pkgs.linuxPackages.nvidia_x11.settings pkgs.linuxPackages.nvidia_x11.bin ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "nvidia-perf-mode" ''
        # Enable persistence mode (keeps driver loaded)
        nvidia-smi -pm 1 || true
        # Set PowerMizer to Prefer Maximum Performance
        nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" || true
      ''}";
    };
  };
}
