{
  vim.notify = {
    nvim-notify = {
      enable = true;

      setupOpts = {
        render = "wrapped-compact";
        stages = "static";

        open_raw = {
          __raw = ''
            function(win)
              vim.api.nvim_win_set_config(win, {focusable = false})
            end
          '';
        };
      };
    };
  };
}
