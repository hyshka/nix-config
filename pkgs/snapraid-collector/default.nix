{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  snapraid,
  gawk,
  smartmontools,
  coreutils,
  gnugrep,
}:

let
  dependencies = [
    snapraid
    gawk
    smartmontools
    coreutils
    gnugrep
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "snapraid-collector";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ljmerza";
    repo = "snapraid-collector";
    rev = "v${finalAttrs.version}";
    hash = "sha256-caVU8Kz8v/emm5MfpyrflfgIuzpsu8kjlK5XbPeHTL4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 snapraid_metrics_collector.sh $out/bin/snapraid_metrics_collector.sh
    wrapProgram $out/bin/snapraid_metrics_collector.sh \
      --prefix PATH : ${lib.makeBinPath dependencies}
    runHook postInstall
  '';

  meta = {
    description = "Prometheus textfile metrics collector for SnapRAID";
    homepage = "https://github.com/ljmerza/snapraid-collector";
    changelog = "https://github.com/ljmerza/snapraid-collector/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "snapraid_metrics_collector.sh";
    platforms = lib.platforms.unix;
  };
})
