{
  vim = {
    languages = {
      enableFormat = true;
      enableDAP = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;

      bash = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };

      clang = {
        enable = true;
        cHeader = true;
        dap.enable = true;
        lsp.enable = true;
      };

      html = {
        enable = true;
        treesitter.autotagHtml = true;
      };

      java = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };

      lua = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };

      nix = {
        enable = true;
        format.enable = true;
        format.type = "nixfmt";
        #format.package = pkgs.nixfmt-rfc-style;
        lsp = {
          enable = true;
          server = "nixd";
          options = {
            nixpkgs = {
              expr = "import <nixpkgs> { }";
            };
          };
        };
        extraDiagnostics = {
          enable = true;
          types = [
            "statix"
            "deadnix"
          ];
        };
      };

      markdown = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        extensions = {
          markview-nvim.enable = true;
          render-markdown-nvim.enable = true;
        };
      };

      python = {
        enable = true;
        format.type = "black";

      };

      rust = {
        enable = true;
        crates = {
          enable = true;
          codeActions = true;
        };
        format.enable = true;
        format.type = "rustfmt";
        lsp = {
          enable = true;
          opts = "
            ['rust-analyzer'] = {
              cargo = {allFeature = true},
              checkOnSave = true;
              procMacro = {
                enable =true;
              },
            },
            ";
        };
      };

      yaml = {
        enable = true;
        lsp.enable = true;
      };

    };
  };
}
