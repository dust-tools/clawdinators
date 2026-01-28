{
  description = "CLAWDINATOR infra + Nix modules";

  inputs = {
    nix-moltbot.url = "github:moltbot/nix-moltbot"; # latest upstream
    nixpkgs.follows = "nix-moltbot/nixpkgs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, nix-moltbot, agenix }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      moltbotOverlay = nix-moltbot.overlays.default;
    in
    {
      nixosModules.clawdinator = import ./nix/modules/clawdinator.nix;
      nixosModules.default = self.nixosModules.clawdinator;

      overlays.moltbot = moltbotOverlay;
      overlays.default = moltbotOverlay;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          gateway =
            if pkgs ? moltbot-gateway
            then pkgs.moltbot-gateway
            else pkgs.moltbot;
          systemPackages =
            if system == "x86_64-linux" then {
              clawdinator-system = self.nixosConfigurations.clawdinator-1.config.system.build.toplevel;
              clawdinator-image-system = self.nixosConfigurations.clawdinator-1-image.config.system.build.toplevel;
            } else {};
        in {
          moltbot-gateway = gateway;
          default = gateway;
        } // systemPackages);

      nixosConfigurations.clawdinator-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: { nixpkgs.overlays = [ self.overlays.default ]; })
          agenix.nixosModules.default
          ./nix/hosts/clawdinator-1.nix
        ];
      };

      nixosConfigurations.clawdinator-1-image = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: { nixpkgs.overlays = [ self.overlays.default ]; })
          agenix.nixosModules.default
          ./nix/hosts/clawdinator-1-image.nix
        ];
      };
    };
}
