{
  vim.formatter.conform-nvim = {
    enable = true;

    presets = {
      clang-format.enable = true;

    };

    setupOpts = {
      defult_format_opts = {
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        java = [
          "google_java_format"
        ];
      };
    };
  };
}
