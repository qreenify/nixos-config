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

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.qreenify = import ./modules/home.nix;
        }
      ];
    };

    # Wonderland NixOS Installation ISO
    nixosConfigurations.wonderland-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit zen-browser; };
      modules = [
        # ISO-specific configuration
        ./iso-config.nix

        # Reuse some system modules
        ./modules/locale.nix
        ./modules/networking.nix

        # Home Manager for live environment
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = import ./modules/home.nix;
        }
      ];
    };
  };
}
