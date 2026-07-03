{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version;
  platformTriple =
    {
      "x86_64-linux" = "x86_64-linux";
      "aarch64-linux" = "aarch64-linux";
      "aarch64-darwin" = "aarch64-macos";
    }
    .${stdenv.hostPlatform.system}
      or (throw "Unsupported platform for tokensave: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "tokensave";
  inherit version;

  src = fetchurl {
    url = "https://github.com/aovestdipaperino/tokensave/releases/download/v${version}/tokensave-v${version}-${platformTriple}.tar.gz";
    hash = versionData.hashes.${stdenv.hostPlatform.system};
  };

  dontUnpack = true;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    tar xzf $src
    install -Dm755 tokensave $out/bin/tokensave
    runHook postInstall
  '';

  passthru.category = "Utilities";

  meta = {
    description = "Comprehensive code intelligence MCP server for AI coding agents";
    homepage = "https://github.com/aovestdipaperino/tokensave";
    changelog = "https://github.com/aovestdipaperino/tokensave/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "tokensave";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
