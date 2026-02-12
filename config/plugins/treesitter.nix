{ ... }:
let
  treesitterLanguages = [
    "bash"
    "clang"
    "css"
    "go"
    "html"
    "java"
    #"js"
    #"json"
    "kotlin"
    "lua"
    "markdown"
    "nix"
    "python"
    "rust"
    "sql"
    #"toml"
    #"tsx"
    #"typescript"
    "yaml"
    "zig"

    # Rarely Used or Niche Today
    # "assembly"
    # "astro"
    # "clojure"
    # "elixir"
    # "elm"
    # "erlang"
    # "fennel"
    # "fish"
    # "haskell"
    # "julia"
    # "latex"
    # "ocaml"
    # "php"
    # "r"
    # "ruby"
    # "scala"
    # "svelte"
    # "swift"
    # "typst"
    # "vue"

  ];

  treeSitterEnables = builtins.listToAttrs (
    builtins.map (lang: {
      name = lang;
      value = {
        treesitter.enable = true;
      };
    }) treesitterLanguages
  );
in
{
  vim = {
    treesitter = {
      enable = true;
      fold = true;

      highlight = {
        enable = true;
      };

      indent.enable = true;

      addDefaultGrammars = true;

      autotagHtml = true;

      context = {
        enable = true;
        setupOpts = {
          line_numbers = true; # show line numbers in the sticky header
          max_lines = 3; # show at most 3 lines for the header
          min_window_height = 0; # no min limit — always on
          mode = "cursor"; # calculate context from the cursor position
          multiline_threshold = 20; # default is fine
          separator = "-"; # shows a line between header and content
          trim_scope = "outer"; # trim outer context if too long
          zindex = 20; # default, fine
        };
      };

    };
    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;
    }
    // treeSitterEnables;
  };
}
