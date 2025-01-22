{ ... }:
{
  programs.irssi = {
    enable = true;
    networks.liberachat = {
      nick = "cy7";
      server = {
        address = "irc.libera.chat";
        port = 6697;
        autoConnect = true;
      };
      channels = {
        nixos.autoJoin = true;
        linux.autoJoin = true;
        rust.autoJoin = true;
      };
    };
    extraConfig = ''
      ignores = ( { level = "JOINS PARTS QUITS MODES NICKS"; } )
    '';
  };
}
