{
  vim.snippets.luasnip = {
    enable = true;
    customSnippets.snipmate = {
      # Snippets for all filetypes
      all = [
        {
          trigger = "currtime";
          description = "Insert current time";
          body = "$CURRENT_HOUR:$CURRENT_TIME";
        }
      ];
      nix = [
        {
          trigger = "mkOpt";
          description = "Create a Nix option";
          body = ''
            mkOption {
              type = $1;
              default = $2;
              description = "$3";
            }
          '';
        }
      ];
    };
  };
}
