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
    lua-language-server
    vim-language-server
    python312Packages.python-lsp-server
    nixd
    gopls
    bash-language-server
    llvmPackages_19.clang-tools
    rust-analyzer
    yt-dlp
    gnumake
    btop
    foot.terminfo
  ];
}
