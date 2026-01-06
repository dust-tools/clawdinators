{
  description = "CLAWDINATOR infra + Nix modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-clawdbot.url = "github:clawdbot/nix-clawdbot"; # latest upstream
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";
    secrets = {
      url = "path:../nix/nix-secrets";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-clawdbot, agenix, disko, secrets }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in
    {
      nixosModules.clawdinator = import ./nix/modules/clawdinator.nix;
      nixosModules.default = self.nixosModules.clawdinator;

      overlays.default = nix-clawdbot.overlays.default;

      nixosConfigurations.clawdinator-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          ({ ... }: { nixpkgs.overlays = [ nix-clawdbot.overlays.default ]; })
          agenix.nixosModules.default
          disko.nixosModules.disko
          ./nix/hosts/clawdinator-1.nix
        ];
      };
    };
}
