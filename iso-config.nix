# Wonderland NixOS Installation ISO Configuration
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    # Use graphical GNOME installer (comment out for minimal ISO)
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"

    # For minimal ISO (smaller, faster build):
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # Include NixOS channel for offline installation
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];

  # ========================================
  # SYSTEM IDENTIFICATION
  # ========================================

  networking.hostName = "wonderland-iso";

  # Enable flakes (required for our configuration)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (needed for nvidia, etc.)
  nixpkgs.config.allowUnfree = true;

  # ========================================
  # BRANDING & CUSTOMIZATION
  # ========================================

  # Custom system label
  system.nixos.label = "Wonderland-NixOS-${config.system.nixos.version}";

  # ISO Image customization
  isoImage = {
    # Volume label (max 32 chars, shows in file managers)
    volumeID = "WONDERLAND-NIXOS";

    # Edition name
    edition = "Wonderland";

    # Enable both BIOS and EFI boot for maximum compatibility
    makeEfiBootable = true;
    makeUsbBootable = true;
    makeBiosBootable = true;

    # Custom splash images (create these in branding/ directory)
    # Uncomment when you have the images:
    # splashImage = ./branding/wonderland-splash-bios.png;  # 640x480 PNG
    # efiSplashImage = ./branding/wonderland-splash-efi.png; # 1920x1080 PNG

    # Boot menu customization
    prependToMenuLabel = "Wonderland ";
    appendToMenuLabel = " Edition";

    # Include your complete flake configuration on the ISO
    contents = [
      {
        source = ./.;  # Copies entire nixos config directory
        target = "/nixos-config/";
      }
      {
        source = ./installer-scripts/wonderland-install.sh;
        target = "/bin/wonderland-install";
      }
    ];

    # Compression (higher = smaller ISO but slower build)
    squashfsCompression = "zstd -Xcompression-level 15";
  };

  # ========================================
  # BOOT & HARDWARE
  # ========================================

  # Use latest kernel for best hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Filesystem support
  boot.supportedFilesystems = lib.mkForce [
    "btrfs" "reiserfs" "vfat" "f2fs" "xfs"
    "ntfs" "cifs" "ext4" "exfat"
  ];

  # ========================================
  # PACKAGES FOR INSTALLATION ENVIRONMENT
  # ========================================

  environment.systemPackages = with pkgs; [
    # Essential tools
    git
    curl
    wget
    vim
    neovim

    # Your preferred tools
    htop
    btop

    # Disk tools
    parted
    gptfdisk
    ntfs3g

    # Network tools
    networkmanager

    # Hardware info
    pciutils
    usbutils
    lshw

    # Secure Boot tools (for post-install)
    sbctl

    # Interactive prompts (for installer script)
    gum
  ];

  # ========================================
  # SERVICES & SETTINGS
  # ========================================

  # Disable power management during installation
  powerManagement.enable = false;
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Auto-login to live user for graphical ISO
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Enable SSH for remote installation (optional but useful)
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Disable passwordless sudo to prevent accidental commands
  security.sudo.wheelNeedsPassword = lib.mkForce true;

  # ========================================
  # SYSTEM STATE
  # ========================================

  system.stateVersion = "25.05";
}
