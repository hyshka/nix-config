{
  pkgs ?
  # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  ...
}: {
  default = pkgs.mkShellNoCC {
    packages = with pkgs; [
      aider-chat
      # https://aider.chat/docs/install/optional.html
      git
      (python312.withPackages (ps: [ps.playwright]))
    ];

    # API Keys are stored in .envrc

    # https://aider.chat/docs/config/options.html
    # OpenAPI models: https://aider.chat/docs/llms/openai.html
    AIDER_MODEL = "openrouter/anthropic/claude-3.7-sonnet";
    AIDER_ANALYTICS_DISABLE = "true";
    AIDER_CHECK_UPDATE = "false";
    AIDER_SHOW_RELEASE_NOTES = "false";
    AIDER_VIM = "true";
    AIDER_GITIGNORE = "false";
    AIDER_CODE_THEME = "solarized-dark";
  };
}
