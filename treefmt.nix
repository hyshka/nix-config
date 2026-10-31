{
  projectRootFile = "flake.nix";
  programs.deadnix.enable = true;
  programs.mdformat.enable = true;
  # Keep consecutive ordered-list numbering; mdformat defaults to `1.` for all.
  settings.formatter.mdformat.options = [ "--number" ];
  # Without the plugin mdformat mangles YAML frontmatter (agent and skill files).
  programs.mdformat.plugins = ps: [ ps.mdformat-frontmatter ];
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.yamlfmt.enable = true;
}
