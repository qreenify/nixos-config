{ config, pkgs, lib, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lanzaboote Secure Boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # Bootloader configuration
  boot.loader.systemd-boot.configurationLimit = 1;  # Only show current NixOS generation (press any key during boot to see more)
  boot.loader.timeout = 3;  # 3 second timeout

  # Set NixOS as default boot entry
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System version
  system.stateVersion = "25.05";
}
