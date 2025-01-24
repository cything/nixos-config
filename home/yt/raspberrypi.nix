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
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [

  ];
}
