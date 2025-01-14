{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];
  home = {
    username = "codespace";
    homeDirectory = "/home/codespace";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    foot.terminfo
    attic-client
  ];
}
