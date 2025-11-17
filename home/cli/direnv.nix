{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # ref: https://github.com/nix-community/home-manager/issues/8170#issuecomment-3542413378
  programs.direnv.package = pkgs.direnv.overrideAttrs (oldAttrs: {
    nativeCheckInputs = builtins.filter (pkg: pkg != pkgs.fish) (oldAttrs.nativeCheckInputs);

    checkPhase = ''
      runHook preCheck
      make test-go test-bash test-zsh
      runHook postCheck
    '';
  });
}
