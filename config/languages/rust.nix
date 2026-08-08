{
  vim.languages.rust = {
    enable = true;
    extensions.crates-nvim = {
      enable = true;
      setupOpts.codeActions = true;
    };
    format = {
      enable = true;
      type = [ "rustfmt" ];
    };
    lsp.enable = true;
  };
}
