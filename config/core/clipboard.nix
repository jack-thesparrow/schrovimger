{ pkgs, ... }:
{
  vim.clipboard = {
    enable = true;
    providers = {
      wl-copy.enable = pkgs.stdenv.isLinux;
    };
    registers = "unnamedplus";
  };
}
