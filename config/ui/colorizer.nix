{
  vim.ui.colorizer = {
    enable = true;
    setupOpts = {
      user_default_options = {
        RGB = true;
        RRGGBB = true;
        RRGGBBAA = true;
        rgb_fn = true;
        css_fn = true;
        css = true;
        # saas = true;
        mode = "background";
      };

      filetypes = {
        "*" = { };
        cpp = {
          rgb_fn = true;
          css_fn = true;
        };
      };
    };
  };
}
