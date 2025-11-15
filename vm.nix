# NixOS VM configuration for testing the flake
{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  # VM-specific settings
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;  # 4GB RAM
      cores = 4;
      diskSize = 20000;   # 20GB disk
      graphics = true;
      qemu.options = [
        "-vga virtio"
        "-display gtk,gl=on"
      ];
    };
  };

  # Use systemd-boot instead of lanzaboote for VM
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Basic system settings
  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.qreenify = {
    isNormalUser = true;
    description = "qreenify";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    password = "test";  # Simple password for VM testing
  };

  # Enable sudo without password for testing
  security.sudo.wheelNeedsPassword = false;

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Enable niri/Hyprland without nvidia
  programs.hyprland.enable = true;

  # Basic services
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable X11 and Wayland
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
  };

  system.stateVersion = "25.05";
}
