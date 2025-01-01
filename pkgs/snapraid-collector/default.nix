{
  pkgs,
  symlinkJoin,
  writeShellScriptBin,
  fetchFromGitHub,
}: let
  repo = fetchFromGitHub {
    owner = "ljmerza";
    repo = "snapraid-collector";
    rev = "7411cfd669adbd5e84daa225cb8caf81b5fafea2";
    sha256 = "sha256-/rlB3h14iebyxUssOcsYFuMml0b3F5+7JgAZwogYHmA=";
  };
  scriptContent = writeShellScriptBin "snapraid_metrics_collector.sh" (builtins.readFile "${repo}/snapraid_metrics_collector.sh");
  dependencies = [pkgs.snapraid pkgs.which pkgs.gawk pkgs.smartmontools];
in
  symlinkJoin {
    name = "snapraid-collector";
    paths = [
      scriptContent
    ];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/snapraid_metrics_collector.sh \
        --prefix PATH : ${pkgs.lib.makeBinPath dependencies}
    '';
  }
