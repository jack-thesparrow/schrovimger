{
  vim.luaConfigRC = {
    disableLspProgress = ''
      -- Disable ALL LSP progress notifications
      vim.lsp.handlers["$/progress"] = function() end
    '';
  };
}
