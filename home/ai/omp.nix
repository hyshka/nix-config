{
  inputs,
  pkgs,
  ...
}:
let
  ompPkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;

in
{
  # No home-manager module for now
  # Imperative via ~/.omp/ to start
  home.packages = [
    ompPkg
  ];

  programs.git.ignores = [
    "**/.omp/wt"
  ];
}
