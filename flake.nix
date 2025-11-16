{
  description = "NixOS configuration with Lanzaboote, home-manager and niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, zen-browser, ... }: {
    # Main system configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit zen-browser; };
      modules = [
        # Hardware
        ./hardware-configuration.nix

        # System modules
        ./modules/boot.nix
        ./modules/networking.nix
        ./modules/locale.nix
        ./modules/nvidia.nix
        ./modules/packages.nix
        ./modules/users.nix
        ./modules/desktop.nix
        ./modules/mounts.nix

        # Lanzaboote
        lanzaboote.nixosModules.lanzaboote

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.qreenify = import ./modules/home.nix;
        }
      ];
    };

    # VM configuration for testing
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit zen-browser; };
      modules = [
        # VM base configuration
        ./vm.nix

        # System modules (excluding hardware-specific ones)
        ./modules/networking.nix
        ./modules/locale.nix
        ./modules/packages.nix
        ./modules/desktop.nix

        # Home Manager (simplified for VM)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.qreenify = { config, pkgs, lib, ... }: {
            # Import main home config
            imports = [ ./modules/home.nix ];

            # Disable theme deployment in VM (causes path issues)
            home.file.".config/theme/themes/pulsar-theme".enable = lib.mkForce false;
            home.file.".config/theme/themes/base".enable = lib.mkForce false;
          };
        }
      ];
    };
  };
}
