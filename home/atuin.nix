{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      ctrl_n_shortcuts = false;
      keymap_mode = "vim-insert";
      filter_mode_shell_up_key_binding = "directory";
      search_mode = "fuzzy";
      show_help = false;
      show_preview = true;
    };
  };
}
