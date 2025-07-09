{
  vim = {
    autocomplete.blink-cmp = {
      enable = true;

      mappings = {
        close = "<C-e>";
        complete = "<C-Space>";
        confirm = "<CR>";
        next = "<Tab>";
        previous = "<S-Tab>";
        scrollDocsDown = "<C-f>";
        scrollDocsUp = "<C-d>";
      };

      sourcePlugins = {
        emoji.enable = true;
        ripgrep.enable = true;
        spell.enable = true;
      };

      setupOpts = {

        signature = {
          enabled = true;
          trigger = {
            enabled = true;
          };
        };

        sources = {
          default = [
            "lsp"
            "snippets"
            "spell"
            "path"
            "buffer"
          ];

          providers = {
            lsp = {
              min_keyword_length = 3;
              score_offset = 5;
            };
            snippets = {
              min_keyword_length = 2;
              score_offset = 4;
            };
            spell = {
              min_keyword_length = 3;
              score_offset = 3;
            };
            path = {
              min_keyword_length = 3;
              score_offset = 2;
            };
            buffer = {
              min_keyword_length = 5;
              score_offset = 1;
            };
          };
        };

        cmdline.keymap.preset = "none";

        completion = {
          documentation.auto_show = true;
          menu.auto_show = true;
        };

      };

    };
  };
}
