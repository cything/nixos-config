{ config, lib, pkgs, inputs, ... }:

let
  fake-gitea = pkgs.writeShellScriptBin "gitea" ''
ssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" /usr/local/bin/gitea $@"
  '';

in {
  disabledModules = [ "services/web-servers/caddy/default.nix" ];
  imports =
    [
      ./hardware-configuration.nix
      "${inputs.testpkgs}/nixos/modules/services/web-servers/caddy"
      ../common.nix
    ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/crash" = { };
    "ntfy" = { };
    "rclone" = { };
    "vaultwarden" = { };
    "caddy" = { };
    "hedgedoc" = { };
    "wireguard/private" = { };
    "wireguard/psk" = { };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  system.stateVersion = "24.05";

  networking.hostName = "chunk";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 53 853 ];
    allowedUDPPorts = [ 443 51820 53 853 ]; # 51820 is wireguard
    trustedInterfaces = [ "wg0" ];
  };
  networking.interfaces.ens18 = {
    ipv6.addresses = [{
      address = "2a0f:85c1:840:2bfb::1";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway6 = {
    address = "2a0f:85c1:840::1";
    interface = "ens18";
  };
  networking.nameservers = [ "127.0.0.1" "::1" ];

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"];
    openssh.authorizedKeys.keys =
      [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  users.users.root.openssh.authorizedKeys.keys =
      [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux" ];

  users.users.git = {
    isNormalUser = true;
    packages = [ fake-gitea ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tree
    python3Full
    tmux
    borgbackup
    rclone
    file
    sops
    age
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;
  programs.git.enable = true;

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
    environmentFile = "/run/secrets/caddy";
    logFormat = lib.mkForce "level INFO";
  };
  # systemd.services.caddy.serviceConfig = {
  #   EnvironmentFile = "/run/secrets/caddy";
  # };

  services.postgresql = {
    enable = true;
    settings.port = 5432;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    ensureDatabases = [
      "forgejo"
      "freshrss"
      "hedgedoc"
      "linkwarden"
    ];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
      {
        name = "linkwarden";
        ensureDBOwnership = true;
      }
      {
        name = "freshrss";
        ensureDBOwnership = true;
      }
      {
        name = "hedgedoc";
        ensureDBOwnership = true;
      }
    ];
    authentication = lib.mkForce ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
      host  all all 172.18.0.0/16 trust
    '';
  };
  services.postgresqlBackup.enable = true;

  virtualisation.docker.enable = true;

  services.borgbackup.jobs = {
    crashRsync = {
      paths = [ "/root" "/home" "/var/backup" "/var/lib" "/var/log" "/opt" "/etc" "/vw-data" ];
      exclude = [ "**/.cache" "**/node_modules" "**/cache" "**/Cache" "/var/lib/docker/overlay*" ];
      repo = "de3911@de3911.rsync.net:borg/crash";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /run/secrets/borg/crash";
      };
      environment = {
        BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
        BORG_REMOTE_PATH = "borg1";
      };
      compression = "auto,zstd";
      startAt = "daily";
      extraCreateArgs = [ "--stats" ];
      # warnings are often not that serious
      failOnWarnings = false;
      postHook = ''
        ${pkgs.curl}/bin/curl -u $(cat /run/secrets/ntfy) -d "chunk: backup completed with exit code: $exitStatus
        $(journalctl -u borgbackup-job-crashRsync.service|tail -n 5)" \
        https://ntfy.cything.io/chunk
      '';
    };
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = "/run/secrets/vaultwarden";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = "8081";
      DATA_FOLDER = "/vw-data";
      DATABASE_URL = "postgresql://vaultwarden:vaultwarden@127.0.0.1:5432/vaultwarden";
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:8083";
      base-url = "https://ntfy.cything.io";
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
      behind-proxy = true;
    };
  };

  systemd.services.immich-mount = {
    enable = true;
    description = "Mount the immich data remote";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/photos";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --transfers=32 --dir-cache-time 720h --poll-interval 0 --vfs-cache-mode writes photos: /mnt/photos ";
      ExecStop = "/bin/fusermount -u /mnt/photos";
      EnvironmentFile = "/run/secrets/rclone";
    };
  };

  systemd.services.nextcloud-mount = {
    enable = true;
    description = "Mount the nextcloud data remote";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --uid 33 --gid 0 --allow-other --file-perms 0770 --dir-perms 0770 --transfers=32 rsyncnet:nextcloud /mnt/nextcloud";
      ExecStop = "/bin/fusermount -u /mnt/nextcloud";
      EnvironmentFile = "/run/secrets/rclone";
    };
  };

  programs.fuse.userAllowOther = true;

  services.hedgedoc = {
    enable = true;
    environmentFile = "/run/secrets/hedgedoc";
    settings = {
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      port = 8085;
      domain = "pad.cything.io";
      allowEmailRegister = false;
      protocolUseSSL = true;
    };
  };

  services.redlib = {
    enable = true;
    port = 8087;
    address = "127.0.0.1";
    settings = {
      # settings are just env vars
      REDLIB_ENABLE_RSS = "on";
      REDLIB_ROBOTS_DISABLE_INDEXING = "on";
    };
  };

  # wireguard stuff
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
    listenPort = 51820;
    privateKeyFile = "/run/secrets/wireguard/private";
    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
    '';
    peers = [
      {
        publicKey = "qUhWoTPVC7jJdDEJLYY92OeiwPkaf8I5pv5kkMcSW3g=";
        allowedIPs = [ "10.0.0.2/32" "fdc9:281f:04d7:9ee9::2/128" ];
        presharedKeyFile = "/run/secrets/wireguard/psk";
      }
    ];
  };

  # adguard
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 8082;
    settings = {
      http.port = "8083";
      users = [
        {
          name = "cy";
          password = "$2y$10$BZy2zYJj5z4e8LZCq/GwuuhWUafL/MNFO.YcsAMmpDS.2krPxi7KC";
        }
      ];
    };
  };
}

