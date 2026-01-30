{
  description = "Example CLAWDINATOR host flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-openclaw.url = "github:openclaw/nix-openclaw"; # latest upstream
    agenix.url = "github:ryantm/agenix";
    secrets = {
      url = "path:../../../nix/nix-secrets";
      flake = false;
    };
    clawdinators.url = "path:../..";
  };

  outputs = { self, nixpkgs, nix-openclaw, agenix, secrets, clawdinators }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.clawdinator-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit secrets; };
        modules = [
          ({ pkgs, ... }: { nixpkgs.overlays = [ clawdinators.overlays.default ]; })
          agenix.nixosModules.default
          clawdinators.nixosModules.clawdinator
          ./clawdinator-host.nix
        ];
      };
    };
}
