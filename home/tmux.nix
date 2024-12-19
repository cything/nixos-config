{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "emacs";
    mouse = false;
    plugins = with pkgs.tmuxPlugins; [
      yank
      tokyo-night-tmux
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = "set -g @continnum-restore 'on'";
      }
    ];
    prefix = "C-f";
    sensibleOnTop = true;
    terminal = "tmux-256color";
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind u attach-session -c "#{pane_current_path}"
      bind v split-window -c "#{pane_current_path}" -h
      bind s split-window -c "#{pane_current_path}" -v
    '';
  };
}
