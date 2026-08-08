{
  description = "SchroVimger: An NVF-based Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      flake-parts,
      nvf,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;

            overlays = [
              (_final: _prev: {
                stable = import nixpkgs-stable {
                  inherit system;
                  config.allowUnfree = true;
                  config.nvidia.acceptLicense = true;
                };
              })
            ];

            config.allowUnfree = true;
          };

          profiles = {
            minimal = ./config/profiles/minimal.nix;
            cpp = ./config/profiles/cpp.nix;
            rust = ./config/profiles/rust.nix;
            python = ./config/profiles/python.nix;
            java = ./config/profiles/java.nix;
            full = ./config/profiles/full.nix;
          };

          neovims = pkgs.lib.mapAttrs (
            _name: profileModule:
            (nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [ profileModule ];
            }).neovim
          ) profiles;

          wrapProfile =
            name: drv:
            pkgs.runCommand "nvim-${name}" { } ''
              mkdir -p $out/bin
              ln -s ${drv}/bin/nvim $out/bin/nvim-${name}
            '';

          cliPackages = pkgs.lib.mapAttrs' (
            name: drv:
            pkgs.lib.nameValuePair "nvim-${name}" (wrapProfile name drv)
          ) (pkgs.lib.filterAttrs (name: _: name != "minimal") neovims);

          profilePackages =
            neovims
            // cliPackages;

        in
        {
          packages =
            profilePackages
            // {
              default = neovims.minimal;
            };

          apps =
            pkgs.lib.mapAttrs (
              name: drv:
              {
                type = "app";
                program = "${drv}/bin/nvim";
                meta.description = "SchroVimger ${name} profile";
              }
            ) neovims
            // {
              default = {
                type = "app";
                program = "${neovims.minimal}/bin/nvim";
                meta.description = "SchroVimger minimal profile";
              };
            };

          checks = {
            format-check =
              pkgs.runCommand "format-check"
                {
                  nativeBuildInputs = [
                    pkgs.nixfmt
                    pkgs.diffutils
                    pkgs.rsync
                  ];
                }
                ''
                  mkdir -p "$TMPDIR/orig"
                  mkdir -p "$TMPDIR/formatted"

                  rsync -a \
                    --exclude orig \
                    --exclude formatted \
                    --exclude .git \
                    ./ "$TMPDIR/orig/"

                  rsync -a \
                    "$TMPDIR/orig/" \
                    "$TMPDIR/formatted/"

                  find "$TMPDIR/formatted" \
                    -name '*.nix' \
                    -exec nixfmt {} +

                  diff -ru \
                    "$TMPDIR/orig" \
                    "$TMPDIR/formatted" \
                    || (
                      echo "Formatting issues found"
                      exit 1
                    )

                  touch "$out"
                '';

            deadnix =
              pkgs.runCommand "deadnix-check"
                {
                  nativeBuildInputs = [ pkgs.deadnix ];
                }
                ''
                  deadnix check . \
                    || (
                      echo "Dead code found"
                      exit 1
                    )

                  touch "$out"
                '';

            statix =
              pkgs.runCommand "statix-check"
                {
                  nativeBuildInputs = [ pkgs.statix ];
                }
                ''
                  statix check . \
                    || (
                      echo "Style issues found"
                      exit 1
                    )

                  touch "$out"
                '';
          };

          formatter = pkgs.nixfmt;

          devShells.default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                chafa
                epub-thumbnailer
                fd
                ffmpegthumbnailer
                git
                imagemagick
                pre-commit
                poppler-utils
                nixfmt
                nixd
                nerd-fonts.jetbrains-mono
                ripgrep
                deadnix
                statix
              ]
              ++ lib.optionals stdenv.isLinux [
                fontpreview
              ];
          };
        };

      flake = {
        homeModules.default =
          {
            pkgs,
            lib,
            ...
          }:
          let
            profiles = {
              minimal = ./config/profiles/minimal.nix;
              cpp = ./config/profiles/cpp.nix;
              rust = ./config/profiles/rust.nix;
              python = ./config/profiles/python.nix;
              java = ./config/profiles/java.nix;
              full = ./config/profiles/full.nix;
            };

            neovims = lib.mapAttrs (
              _name: profileModule:
              (nvf.lib.neovimConfiguration {
                inherit pkgs;
                modules = [ profileModule ];
              }).neovim
            ) profiles;

            wrapProfile =
              name: drv:
              pkgs.runCommand "nvim-${name}" { } ''
                mkdir -p $out/bin
                ln -s ${drv}/bin/nvim $out/bin/nvim-${name}
              '';

            cliPackages = lib.mapAttrsToList (
              name: drv:
              wrapProfile name drv
            ) (lib.filterAttrs (name: _: name != "minimal") neovims);

          in
          {
            home.packages =
              [
                pkgs.chafa
                pkgs.epub-thumbnailer
                pkgs.fd
                pkgs.ffmpegthumbnailer
                pkgs.git
                pkgs.imagemagick
                pkgs.pre-commit
                pkgs.poppler-utils
                pkgs.nixfmt
                pkgs.nixd
                pkgs.nerd-fonts.jetbrains-mono
                pkgs.ripgrep

                neovims.minimal
              ]
              ++ cliPackages;
          };
      };
    };
}
