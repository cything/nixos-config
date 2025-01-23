{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../common.nix
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
  ];

  system.stateVersion = "24.05";

  environment.systemPackages = with pkgs; [
    curl
    git
  ];

  # network stuff
  networking.hostName = "pancake";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
    allowedUDPPorts = [
      443
    ];
  };

  networkings.wireless.enable = true;
  networkings.wireless.networks = {
    "36 Halsey" = {
      psk = "Canada2022";
    };
    "cy" = {
      psk = "12345678";
    };
  };

  hardware.enableRedistributableFirmware = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    enable = true;
    autoLogin.user = "yt";
  };
  users.users.yt.extraGroups = [
    "wheel"
  ];
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
