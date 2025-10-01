{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.deadnix.enable = true;
  programs.nixfmt.enable = true;
  settings.formatter.nixfmt.excludes = [ "home/nixvim/plugins/custom/codecompanion.nix" ];
  programs.shellcheck.enable = pkgs.hostPlatform.system != "riscv64-linux";
  programs.shfmt.enable = pkgs.hostPlatform.system != "riscv64-linux";
}
