{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # TODO: enable s6 to manage atuin daemon
      # for compatibility with ceph-filesystem
      # https://forum.atuin.sh/t/weekly-release-2024-19/317
      auto_sync = false;
      ctrl_n_shortcuts = false;
      keymap_mode = "vim-insert";
      filter_mode_shell_up_key_binding = "directory";
      search_mode = "fuzzy";
      show_help = false;
      show_preview = true;
      daemon = {
        enabled = true;
      };
    };
  };
}
