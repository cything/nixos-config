{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    attic-server
  ];
}
