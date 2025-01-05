{ config, ... }: {
  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.sops.secrets."harmonia/key".path ];
    settings = {
      real_nix_store = "/mnt/harmonia";
    };
  };
}
