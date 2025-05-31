{
  description = "NixOS config with Home Manager and Alacritty Theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
  };

  outputs = { self, nixpkgs, home-manager, alacritty-theme, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ alacritty-theme.overlays.default self.overlays.default ];
      };
    in {
      nixosConfigurations.thanos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = [ self.overlays.default ];
          }
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ratul = import ./home.nix;
          }

          {
            nixpkgs.overlays = [ alacritty-theme.overlays.default ];
          }
        ];
      };

      packages.x86_64-linux.zen-browser = pkgs.zen-browser;

      overlays.default = final: prev: {
        zen-browser = let
          deps = with final; [
            stdenv.cc.cc.lib
            zlib
            xorg.libX11
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXfixes
            xorg.libXi
            gtk3
            cairo
            pango
            gdk-pixbuf
            atk
            glib
            alsa-lib
            libdrm
            mesa
            libglvnd
            wayland
            libxkbcommon
            vulkan-loader
            egl-wayland
            pciutils
          ];
        in final.stdenv.mkDerivation {
          pname = "zen-browser";
          version = "1.12.9b";

          src = final.fetchurl {
            url = "https://github.com/zen-browser/desktop/releases/download/1.12.9b/zen.linux-x86_64.tar.xz";
            sha256 = "1a96a4b162e2b851f4e499749acc4c9b3b708164b2494ba45fd4788a3d984c7e";
          };

          nativeBuildInputs = [ final.makeWrapper final.autoPatchelfHook ];
          buildInputs = deps;

          unpackPhase = ''
            mkdir -p source
            tar -xf $src -C source
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp -r source/zen $out/bin/zen
            chmod +x $out/bin/zen/zen-bin

            makeWrapper $out/bin/zen/zen-bin $out/bin/zen-browser \
              --set LD_LIBRARY_PATH ${final.lib.makeLibraryPath deps}
          '';
        };
      };
    };
}

