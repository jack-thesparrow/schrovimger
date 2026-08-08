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
            pkgs.runCommand "nvim-${name}-wrapped" { } ''
              mkdir -p $out/bin
              ln -s ${drv}/bin/nvim $out/bin/nvim-${name}
            '';

          wrappedPackages = pkgs.lib.mapAttrs' (
            name: drv: pkgs.lib.nameValuePair "nvim-${name}" (wrapProfile name drv)
          ) (pkgs.lib.filterAttrs (name: _: name != "minimal") neovims);

        in
        {
          _module.args.pkgs = pkgs;

          packages =
            neovims
            // wrappedPackages
            // {
              default = neovims.minimal;
            };

          apps =
            (pkgs.lib.mapAttrs (_name: drv: {
              type = "app";
              program = "${drv}/bin/nvim";
            }) neovims)
            // {
              default = {
                type = "app";
                program = "${neovims.minimal}/bin/nvim";
              };
            };

          checks = {
            ## ✅ 1) Format check
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
                  echo "📏 Running nixfmt check..."

                  mkdir $TMPDIR/orig
                  mkdir $TMPDIR/formatted

                  rsync -a --exclude orig --exclude formatted --exclude .git --exclude result ./ $TMPDIR/orig/
                  rsync -a $TMPDIR/orig/ $TMPDIR/formatted/

                  find $TMPDIR/formatted -name '*.nix' -exec nixfmt {} +

                  diff -ru $TMPDIR/orig $TMPDIR/formatted || (echo '❌ Formatting issues found'; exit 1)

                  touch $out
                '';

            ## ✅ 2) Deadnix check
            deadnix =
              pkgs.runCommand "deadnix-check"
                {
                  nativeBuildInputs = [ pkgs.deadnix ];
                }
                ''
                  echo "🧹 Running deadnix..."
                  deadnix check . || (echo "❌ Dead code found"; exit 1)
                  touch $out
                '';

            ## ✅ 3) Statix check
            statix =
              pkgs.runCommand "statix-check"
                {
                  nativeBuildInputs = [ pkgs.statix ];
                }
                ''
                  echo "🕵️ Running statix..."
                  statix check . || (echo "❌ Style issues found"; exit 1)
                  touch $out
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
              ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.fontpreview ];
          };
        };

      flake = {
        homeModules.default =
          { pkgs, lib, ... }:
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
              pkgs.runCommand "nvim-${name}-wrapped" { } ''
                mkdir -p $out/bin
                ln -s ${drv}/bin/nvim $out/bin/nvim-${name}
              '';

            wrapped = lib.mapAttrsToList (name: drv: wrapProfile name drv) (
              lib.filterAttrs (name: _: name != "minimal") neovims
            );

          in
          {
            home.packages = [
              pkgs.chafa
              pkgs.epub-thumbnailer
              pkgs.fd
              pkgs.fontpreview
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
            ++ wrapped;
          };
      };
    };
}
