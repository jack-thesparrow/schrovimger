{
  vim.lsp.servers.nixd.enable = true;

  vim.languages.nix = {
    enable = true;
    format = {
      enable = true;
      type = [ "nixfmt" ];
    };
    extraDiagnostics = {
      enable = true;
      types = [
        "statix"
        "deadnix"
      ];
    };
  };
}
