{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.libvirt;
in
{
  options.my.libvirt = {
    enable = lib.mkEnableOption "libvirt";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    programs.virt-manager.enable = true;

    users.users.yt.extraGroups = [ "libvirtd" ];
  };
}
