{
  description = "Example CLAWDINATOR host flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-moltbot.url = "github:moltbot/nix-moltbot"; # latest upstream
    agenix.url = "github:ryantm/agenix";
    secrets = {
      url = "path:../../../nix/nix-secrets";
      flake = false;
    };
    moltinators.url = "path:../..";
  };

  outputs = { self, nixpkgs, nix-moltbot, agenix, secrets, moltinators }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.clawdinator-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit secrets; };
        modules = [
          ({ pkgs, ... }: { nixpkgs.overlays = [ moltinators.overlays.default ]; })
          agenix.nixosModules.default
          moltinators.nixosModules.clawdinator
          ./clawdinator-host.nix
        ];
      };
    };
}
