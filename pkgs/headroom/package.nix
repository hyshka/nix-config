{
  lib,
  stdenv,
  python3,
  fetchurl,
  autoPatchelfHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version;

  wheelSrc =
    {
      "aarch64-darwin" = fetchurl {
        url = "https://github.com/headroomlabs-ai/headroom/releases/download/v${version}/headroom_ai-${version}-cp310-abi3-macosx_11_0_arm64.whl";
        hash = versionData.hashes.aarch64-darwin;
      };
      "x86_64-linux" = fetchurl {
        url = "https://github.com/headroomlabs-ai/headroom/releases/download/v${version}/headroom_ai-${version}-cp310-abi3-manylinux_2_28_x86_64.whl";
        hash = versionData.hashes.x86_64-linux;
      };
      "aarch64-linux" = fetchurl {
        url = "https://github.com/headroomlabs-ai/headroom/releases/download/v${version}/headroom_ai-${version}-cp310-abi3-manylinux_2_28_aarch64.whl";
        hash = versionData.hashes.aarch64-linux;
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "Unsupported platform for headroom: ${stdenv.hostPlatform.system}");
in
python3.pkgs.buildPythonPackage {
  pname = "headroom-ai";
  inherit version;
  format = "wheel";

  src = wheelSrc;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    rich
    pydantic
    tiktoken
    opentelemetry-api
    litellm
    ast-grep-py
    tomli
    # headroom-ai[proxy]
    fastapi
    uvicorn
    httpx
    h2
    openai
    mcp
    magika
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog
    sqlite-vec
    # headroom-ai[code]
    tree-sitter-language-pack
    tree-sitter
    # headroom-ai[memory]
    #sentence-transformers # BUILD ISSUE
  ];

  # ast-grep-cli is packaged in nixpkgs as ast-grep-py — the runtime dep hook
  # compares PyPI names and fails on that mismatch.
  env.dontCheckRuntimeDeps = "1";

  pythonImportsCheck = [ "headroom" ];

  passthru.category = "Utilities";

  meta = with lib; {
    description = "Context compression middleware for LLM applications — reduces token usage 60–95%";
    homepage = "https://headroomlabs-ai.github.io/headroom/";
    changelog = "https://github.com/headroomlabs-ai/headroom/releases/tag/v${version}";
    license = licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    mainProgram = "headroom";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
