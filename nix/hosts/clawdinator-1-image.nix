{ modulesPath, config, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/ec2-data.nix")
    (modulesPath + "/virtualisation/amazon-init.nix")
  ];

  networking.hostName = "clawdinator-1";
  time.timeZone = "UTC";
  system.stateVersion = "26.05";

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ "xen-blkfront" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ena ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.useDHCP = true;
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  environment.etc."agenix/keys/clawdinator.agekey" = {
    source = ../keys/clawdinator.agekey;
    mode = "0400";
  };
  environment.etc."clawdinator/AGENTS.md".source = ../../AGENTS.md;
  environment.etc."clawdinator/BOOTSTRAP.md".source = ../../BOOTSTRAP.md;
  environment.etc."clawdinator/CLAWDINATOR-SOUL.md".source = ../../CLAWDINATOR-SOUL.md;
  environment.etc."clawdinator/HEARTBEAT.md".source = ../../HEARTBEAT.md;
  environment.etc."clawdinator/IDENTITY.md".source = ../../IDENTITY.md;
  environment.etc."clawdinator/SOUL.md".source = ../../SOUL.md;
  environment.etc."clawdinator/TOOLS.md".source = ../../TOOLS.md;
  environment.etc."clawdinator/USER.md".source = ../../USER.md;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLItFT3SVm5r7gELrfRRJxh6V2sf/BIx7HKXt6oVWpB"
  ];
}
