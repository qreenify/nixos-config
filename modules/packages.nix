{ config, pkgs, zen-browser, ... }:

{
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable gamemode for better gaming performance
  programs.gamemode.enable = true;

  # Sunshine game streaming server
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

services.hardware.openrgb = { 
  enable = true; 
  package = pkgs.openrgb-with-all-plugins; 
  motherboard = "intel"; 
  server = { 
    port = 6742;  
  }; 
};

  environment.systemPackages = with pkgs; [
    # System utilities
    git
    wget
    curl
    gh
    sbctl
    rclone
    htop
    btop
    wev
    jq

    # Development
    claude-code
    neovim
    vscodium

    # Browsers
    brave
    chromium
    zen-browser.packages."${pkgs.system}".default
    firefox
    # Communication
    vesktop

    # Discord PWA in browser - native Wayland screen sharing via xdg-desktop-portal-hyprland
    # No xwaylandvideobridge needed for browser-based Discord

    # Desktop utilities
    alacritty
    kitty  # GPU-accelerated terminal with pixel-perfect image support
    ghostty  # Modern GPU-accelerated terminal (supports Kitty graphics protocol)
    fuzzel
    swayidle
    swaylock
    mako
    wiremix
    wireplumber
    libnotify
    walker
    playerctl  # Media player control for waybar mpris module
    chafa  # Terminal image viewer for wallpaper preview

    # Theme system dependencies
    xdg-terminal-exec

    # Gaming
    obs-studio
    lutris
    prismlauncher
    mangohud
    gamemode
    gamescope
    protontricks
    winetricks
    wine-staging

    # Virtualization
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    qemu
  ];

  # Enable virtualization support
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  # Enable USB redirection for VMs
  virtualisation.spiceUSBRedirection.enable = true;

  # Add default network for libvirt
  programs.dconf.enable = true;
}
