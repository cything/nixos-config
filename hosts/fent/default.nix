{
  modulesPath,
  pkgs,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../common.nix
    ./disk-config.nix
    ./rclone.nix
    ./garage.nix
    ./immich.nix
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "rclone/config" = {
      sopsFile = ../../secrets/rclone.yaml;
    };
    "rsyncnet/id_ed25519" = {
      sopsFile = ../../secrets/zh5061/id_ed25519.yaml;
    };
    "caddy/env" = {
      sopsFile = ../../secrets/services/caddy.yaml;
    };
    "garage/env" = {
      sopsFile = ../../secrets/services/garage.yaml;
    };
    "tailscale/auth" = {
      sopsFile = ../../secrets/services/tailscale.yaml;
    };
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "25.05";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfubDWr0kRm2o4DqaK6l1s4NCdTkljXZWKWCiF5nX+6 "
  ];

  networking = {
    hostName = "fent";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [
        "podman1"
        "tailscale0"
      ];
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [ 443 ];
    };
    interfaces.enp1s0 = {
      useDHCP = true;
      ipv6.addresses = [
        {
          address = "2a01:4f8:1c1c:7fc4::1";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
      source = "2a01:4f8:1c1c:7fc4::1";
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    age
    fastfetch
    btop
  ];

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
    extraDaemonFlags = [
      "--no-logs-no-support"
    ];
    useRoutingFeatures = "server";
    openFirewall = true;
  };

  my.caddy.enable = true;
  my.containerization.enable = true;
  my.authelia.enable = true;
}
