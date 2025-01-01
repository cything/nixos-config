{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "emacs";
    mouse = false;
    newSession = true;
    # address vim mode switching delay (http://superuser.com/a/252717/65504)
    escapeTime = 0;
    plugins = with pkgs.tmuxPlugins; [
      yank
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
    terminal = "foot";
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind u attach-session -c "#{pane_current_path}"
      bind v split-window -c "#{pane_current_path}" -h
      bind s split-window -c "#{pane_current_path}" -v

      # confirm before killing a window or the server
      bind-key k confirm kill-window
      bind-key K confirm kill-server

      set -g renumber-windows on

      # FILE: iceberg.tmux.conf
      # REPO: https://github.com/gkeep/iceberg-dark
      # MAINTAINER: gkeep <gkeep77@protonmail.com>

      set -g status-justify "centre"
      set -g status "on"
      set -g status-left-style "none"
      set -g message-command-style "fg=#c6c8d1,bg=#2e3244"
      set -g status-right-style "none"
      set -g pane-active-border-style "fg=#454b68"
      set -g status-style "none,bg=#1e2132"
      set -g message-style "fg=#c6c8d1,bg=#2e3244"
      set -g pane-border-style "fg=#2e3244"
      set -g status-right-length "100"
      set -g status-left-length "100"
      setw -g window-status-activity-style "none,fg=#454b68,bg=#1e2132"
      setw -g window-status-separator ""
      setw -g window-status-style "none,fg=#c6c8d1,bg=#1e2132"

      # modules
      module_left_1="#(whoami)"
      module_left_2="%R %a"

      module_right_1="#(ip route get 1 | awk '{print $7}')"
      module_right_2="#H"

      # separators
      separator_left="\ue0bc"
      separator_right="\ue0ba"

      subseparator_left="\ue0bb"
      subseparator_right="\ue0bd"

      set -g status-left "#[fg=#c6c8d1,bg=#454b68,bold] $module_left_1 #[fg=#454b68,bg=#2e3244,nobold,nounderscore,noitalics]$separator_left#[fg=#c6c8d1,bg=#2e3244] $module_left_2 #[fg=#2e3244,bg=#1e2132,nobold,nounderscore,noitalics]$separator_left#[fg=#c6c8d1,bg=#1e2132] #[fg=#1e2132,bg=#1e2132,nobold,nounderscore,noitalics]$separator_left"
      set -g status-right "#[fg=#1e2132,bg=#1e2132,nobold,nounderscore,noitalics]$separator_right#[fg=#c6c8d1,bg=#1e2132] #[fg=#2e3244,bg=#1e2132,nobold,nounderscore,noitalics]$separator_right#[fg=#c6c8d1,bg=#2e3244] $module_right_1 #[fg=#454b68,bg=#2e3244,nobold,nounderscore,noitalics]$separator_right#[fg=#c6c8d1,bg=#454b68,bold] $module_right_2 #{prefix_highlight}"
      setw -g window-status-format "#[fg=#1e2132,bg=#1e2132,nobold,nounderscore,noitalics]$separator_right#[fg=#c6c8d1] #I $subseparator_right #W $subseparator_left#[fg=#1e2132,bg=#1e2132,nobold,nounderscore,noitalics]$separator_right"
      setw -g window-status-current-format "#[fg=#2e3244,bg=#1e2132,nobold,nounderscore,noitalics]$separator_right#[fg=#c6c8d1,bg=#2e3244] #I $subseparator_right #W $subseparator_left #F #[fg=#2e3244,bg=#1e2132,nobold,nounderscore,noitalics]$separator_left"
    '';
  };
}
