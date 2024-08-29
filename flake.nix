{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }:
  {
    nixosModules = {
      vencord = import ./modules/vencord;

      default = self.nixosModules.vencord;
    };
  };
}
