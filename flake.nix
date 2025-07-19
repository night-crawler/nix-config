{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    led-matrix-daemon.url = "github:night-crawler/led_matrix_daemon";
    led-matrix-monitoring.url = "github:night-crawler/led_matrix_monitoring";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      led-matrix-daemon,
      led-matrix-monitoring,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-hardware.nixosModules.framework-16-7040-amd
          {
            boot.kernelParams = [
              "amdgpu.dcdebugmask=0"
            ];
          }
          ./configuration.nix

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
                network_interfaces = [
                  {
                    Name = {
                      Equal = "wlp2s0";
                    };
                  }
                ];

                render = {
                  max_brightness = 100;
                };
              };
            };
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.user = import ./home/default.nix;
          }
        ];
      };
    };
}
