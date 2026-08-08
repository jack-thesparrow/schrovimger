{ pkgs, ... }:
{
  vim = {
    startPlugins = with pkgs.vimPlugins; [
      barbecue-nvim
      nvim-navic
      #nvim-web-devicons
    ];

    pluginRC.barbecue-nvim = ''
      vim.opt.updatetime = 200

      require("barbecue").setup({
        attach_navic = true,
        theme = "auto",
        show_modified = true,
      })
    '';
  };
}
