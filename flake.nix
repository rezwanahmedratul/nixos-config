{
  description = "NixOS configuration for thanos with Home Manager and custom Alacritty theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, alacritty-theme, ... }@inputs: {
    nixosConfigurations.thanos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # optional for custom modules

      modules = [
        # Overlay for Alacritty themes
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ alacritty-theme.overlays.default ];
        })

        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ratul = import ./home.nix;
        }
      ];
    };
  };
}

