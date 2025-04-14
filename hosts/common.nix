{ inputs, config, pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      flake-registry = "";
      trusted-users = [
        "root"
        "@wheel"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixcache.cy7.sh:DN3d1dt0wnXfTH03oVmTee4KgmdNdB0NY3SuzA8Fwx8="
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://nixcache.cy7.sh"
      ];
      secret-key-files = [
        config.sops.secrets.cache-priv-key.path
      ];
    };
    channel.enable = false;
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 14d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";
  networking = {
    firewall.logRefusedConnections = false;
    nameservers = [
      # quad9 (unfiltered)
      "2620:fe::10"
      "2620:fe::fe:10"
      "9.9.9.10"
      "149.112.112.110"
    ];
    timeServers = [
      # https://github.com/jauderho/nts-servers
      "ntp3.fau.de"
      "ntppool1.time.nl"
      "ntpmon.dcs1.biz"
      "stratum1.time.cifelli.xyz"
      "nts.teambelgium.net"
      "c.st1.ntp.br"
    ];
  };
  services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = true;
    extraConfig = ''
      # Expedited Forwarding
      dscp 46
      # disable command port
      cmdport 0
      # only allow NTS
      authselectmode require
      # update the clock only when at least 3 sources agree on the correct time
      minsources 3
    '';
  };

  # see journald.conf(5)
  services.journald.extraConfig = "MaxRetentionSec=2d";

  services.thermald.enable = true;
  environment.enableAllTerminfo = true;

  sops.secrets.cache-priv-key = {
    format = "binary";
    sopsFile = ../secrets/cache-priv-key.pem;
    mode = "0440";
    group = "users";
  };
}
