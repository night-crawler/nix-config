{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      ...
    }:
    {

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-hardware.nixosModules.framework-16-7040-amd
          ./configuration.nix
        ];
      };
    };
}
