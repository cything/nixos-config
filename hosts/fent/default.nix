{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../common.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "25.05";

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfubDWr0kRm2o4DqaK6l1s4NCdTkljXZWKWCiF5nX+6 "
  ];
}
