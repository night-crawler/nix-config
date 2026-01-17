{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    led-matrix-daemon.url = "github:night-crawler/led_matrix_daemon";
    led-matrix-monitoring.url = "github:night-crawler/led_matrix_monitoring";
    zed-extensions = {
      url = "github:DuskSystems/nix-zed-extensions";
    };
  };
  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , led-matrix-daemon
    , led-matrix-monitoring
    , zed-extensions
    , chaotic
    , ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          chaotic.nixosModules.default
          # Apply zed-extensions overlay
          {
            nixpkgs.overlays = [
              zed-extensions.overlays.default
            ];
          }
          nixos-hardware.nixosModules.framework-16-7040-amd
          {
            boot.kernelParams = [
              "amdgpu.dcdebugmask=0"
            ];
          }
          ./configuration.nix
          ./hosts/emperor.nix
          led-matrix-daemon.nixosModules.default
          {
            services.led-matrix-daemon = {
              enable = true;
              # configFile = ./led_matrix_daemon.toml;
              # package = inputs.led-matrix-daemon.packages.${system}.default;
            };

            systemd.services."led-matrix-daemon".serviceConfig = {
              Environment = "RUST_BACKTRACE=full";
            };
          }

          led-matrix-monitoring.nixosModules.default
          {
            services.led-matrix-monitoring = {
              enable = true;
              settings = {
                collector = {
                  network_interfaces = [
                    {
                      Name = {
                        Equal = "wlp2s0";
                      };
                    }
                  ];
                };
              };
            };

            systemd.services.led-matrix-monitoring = {
              preStart = ''
                mkdir -p /etc/led_matrix
                echo -n "99" > /etc/led_matrix/max_brightness_value
              '';
            };
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Add zed-extensions Home Manager module
            home-manager.sharedModules = [
              zed-extensions.homeManagerModules.default
            ];

            home-manager.users.user = import ./home/default.nix;
          }
        ];
      };
    };
}
