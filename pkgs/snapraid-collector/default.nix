{
  pkgs,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  scriptContent = writeShellScriptBin "snapraid_metrics_collector.sh" (
    builtins.readFile ./snapraid_metrics_collector.sh
  );
  dependencies = [
    pkgs.snapraid
    pkgs.which
    pkgs.gawk
    pkgs.smartmontools
  ];
in
symlinkJoin {
  name = "snapraid-collector";
  paths = [
    scriptContent
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/snapraid_metrics_collector.sh \
      --prefix PATH : ${pkgs.lib.makeBinPath dependencies}
  '';
}
