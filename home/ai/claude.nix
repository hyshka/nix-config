{
  inputs,
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    agents = {
      technical-writer = ./agents/technical-writer.md;
    };
    settings = {
      includeCoAuthoredBy = false;
      attribution = {
        commit = "";
        pr = "";
      };
      prefersReducedMotion = true;
      spinnerTipsEnabled = false;
      teammateMode = "tmux";
      tui = "fullscreen";
      sandbox = {
        enabled = true;
        filesystem = {
          allowWrite = [
            "~/.cache/prek/*"
          ];
        };
      };
      worktree = {
        symlinkDirectories = [
          ".yarn/cache"
          ".envrc"
        ];
      };
      env = {
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
      statusLine = {
        type = "command";
        command = "~/claudeline/claudeline -cwd -git-branch"; # TODO: move to custom nix pkg
        padding = 0;
        refreshInterval = 10;
      };
      context = ./base.md;
      #skills = ./skills;
      skillOverrides = {
        bmad-agent-bmad-master = "off";
        bmad-agent-bmm-analyst = "off";
        bmad-agent-bmm-architect = "off";
        bmad-agent-bmm-dev = "off";
        bmad-agent-bmm-pm = "off";
        bmad-agent-bmm-qa = "off";
        bmad-agent-bmm-quick-flow-solo-dev = "off";
        bmad-agent-bmm-sm = "off";
        bmad-agent-bmm-tech-writer = "off";
        bmad-agent-bmm-ux-designer = "off";
        bmad-bmm-check-implementation-readiness = "off";
        bmad-bmm-code-review = "off";
        bmad-bmm-correct-course = "off";
        bmad-bmm-create-architecture = "off";
        bmad-bmm-create-epics-and-stories = "off";
        bmad-bmm-create-prd = "off";
        bmad-bmm-create-product-brief = "off";
        bmad-bmm-create-story = "off";
        bmad-bmm-create-ux-design = "off";
        bmad-bmm-dev-story = "off";
        bmad-bmm-document-project = "off";
        bmad-bmm-domain-research = "off";
        bmad-bmm-edit-prd = "off";
        bmad-bmm-generate-project-context = "off";
        bmad-bmm-market-research = "off";
        bmad-bmm-qa-generate-e2e-tests = "off";
        bmad-bmm-quick-dev = "off";
        bmad-bmm-quick-spec = "off";
        bmad-bmm-retrospective = "off";
        bmad-bmm-sprint-planning = "off";
        bmad-bmm-sprint-status = "off";
        bmad-bmm-technical-research = "off";
        bmad-bmm-validate-prd = "off";
        bmad-brainstorming = "off";
        bmad-editorial-review-prose = "off";
        bmad-editorial-review-structure = "off";
        bmad-help = "off";
        bmad-index-docs = "off";
        bmad-party-mode = "off";
        bmad-review-adversarial-general = "off";
        bmad-review-edge-case-hunter = "off";
        bmad-shard-doc = "off";
      };
      hooksDir = ./hooks;
      commandsDir = ./commands;
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        # Manage the rest in project settings to keep user settings declarative
        #"code-review@claude-plugins-official" = true;
        #"ralph-wiggum@claude-plugins-official" = false;
        #"plugin-dev@claude-plugins-official" = false;
      };
      # vue-lsp or nil isn't supported by a claude plugin yet
      lspServers = {
        vue = {
          command = "vue-language-server";
          extensionToLanguage = {
            ".vue" = "vue";
          };
        };
        nix = {
          command = "nil";
          extensionToLanguage = {
            ".nix" = "nix";
          };
        };
      };
      permissions = {
        defaultMode = "plan";
        allow = [
          # Read-only git commands
          "Bash(git status:*)"
          "Bash(git log:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git remote:*)"
          "Bash(git rev-parse:*)"
          "Bash(git fetch:*)"
          "Bash(git tag:*)"
          "Bash(git blame:*)"

          # Git write (local-only, low-risk)
          "Bash(git add:*)"
          "Bash(git commit:*)"
          "Bash(git stash:*)"
          "Bash(git worktree:*)"

          # Nix commands (specific safe subcommands)
          "Bash(nix build:*)"
          "Bash(nix eval:*)"
          "Bash(nix flake check:*)"
          "Bash(nix flake show:*)"
          "Bash(nix flake metadata:*)"
          "Bash(nix fmt:*)"
          "Bash(nix search:*)"
          "Bash(nix-instantiate:*)"
          "Bash(nix-build:*)"
          "Bash(nix derivation:*)"
          "Bash(nix path-info:*)"
          "Bash(nix log:*)"
          "Bash(nix store:*)"

          # nh commands (build-only, no activation)
          "Bash(nh search:*)"
          "Bash(nh os build:*)"
          "Bash(nh home build:*)"

          # File system operations
          "Bash(ls:*)"
          "Bash(find:*)"
          "Bash(grep:*)"
          "Bash(ag:*)"
          "Bash(rg:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(mkdir:*)"
          "Bash(chmod:*)"

          # Shell utilities (read-only / stdout-only)
          "Bash(jq:*)"
          "Bash(wc:*)"
          "Bash(sort:*)"
          "Bash(uniq:*)"
          "Bash(diff:*)"
          "Bash(which:*)"
          "Bash(tree:*)"
          "Bash(realpath:*)"
          "Bash(dirname:*)"
          "Bash(basename:*)"
          "Bash(stat:*)"
          "Bash(file:*)"
          "Bash(echo:*)"
          "Bash(test:*)"

          # Docker commands (includes exec)
          "Bash(docker ps:*)"
          "Bash(docker logs:*)"
          "Bash(docker exec:*)"
          "Bash(docker container ls:*)"
          "Bash(docker container exec:*)"
          "Bash(docker compose ps:*)"
          "Bash(docker compose ls:*)"
          "Bash(docker compose logs:*)"
          "Bash(docker compose exec:*)"

          # gh CLI (read-only)
          "Bash(gh pr list:*)"
          "Bash(gh pr status:*)"
          "Bash(gh pr checks:*)"
          "Bash(gh pr diff:*)"
          "Bash(gh pr view:*)"
          "Bash(gh repo list:*)"
          "Bash(gh repo view:*)"
          "Bash(gh run list:*)"
          "Bash(gh run view:*)"
          "Bash(gh run watch:*)"
          "Bash(gh workflow list:*)"
          "Bash(gh workflow view:*)"
          "Bash(gh issue list:*)"
          "Bash(gh issue view:*)"

          # Web fetch from trusted domains
          "WebFetch(domain:github.com)"
          "WebFetch(domain:raw.githubusercontent.com)"
          "WebFetch(domain:www.npmjs.com)"
          "WebFetch(domain:registry.yarnpkg.com)"
          "WebFetch(domain:registry.npmjs.org)"
          "WebFetch(domain:vite.dev)"
          "WebFetch(domain:vite.dev)"

          # Trusted Skills
          "Skill(commit-commands:commit)"
          "Skill(commit-commands:commit-push-pr)"
          "Skill(pr-review-toolkit:review-pr:*)"

          # Container management (build-only)
          "Bash(./incus-manager.sh build:*)"
          "Bash(./incus-manager.sh get-age-key:*)"

          # MCP permissions (read-only)
          "Plugin:claude-code-home-manager:context7"
          "Plugin:claude-code-home-manager:gh_grep"
          "mcp__context7"
          "mcp__gh_grep"
          "mcp__nixos"
          "mcp__github__search_repositories"
          "mcp__github__get_file_contents"
          "mcp__shortcut__get-epics-by-id"
          "mcp__shortcut__teams-get-by-id"
        ];
        ask = [
          # Git (external side effects)
          "Bash(git push:*)"

          # nh activation (modifies running system)
          "Bash(nh os test:*)"
          "Bash(nh os switch:*)"
          "Bash(nh darwin switch:*)"
          "Bash(nh home switch:*)"

          # Nix commands that modify state
          "Bash(nix flake update:*)"
          "Bash(nix profile:*)"

          # gh CLI (external side effects)
          "Bash(gh api:*)"
          "Bash(gh pr create:*)"
          "Bash(gh pr merge:*)"
          "Bash(gh pr comment:*)"

          # Container management (modifies infrastructure)
          "Bash(./incus-manager.sh deploy:*)"
          "Bash(./incus-manager.sh rebuild:*)"
          "Bash(./incus-manager.sh restart:*)"
          "Bash(./incus-manager.sh bootstrap:*)"
        ];
        deny = [
          # Sensitive file protection
          "Read(**/.env*)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
          "Read(**/.aws/**)"
          "Read(**/.ssh/**)"
          "Read(**/*.age)"
          "Read(**/secrets.yaml)"

          # Destructive commands
          "Bash(rm -rf:*)"
          "Bash(dd:*)"
          "Bash(shutdown:*)"
          "Bash(reboot:*)"
          "Bash(nix-collect-garbage:*)"
          "Bash(nix-env:*)"
        ];
      };
    };
    mcpServers = {
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
        headers = {
          "CONTEXT7_API_KEY" = "\${CONTEXT7_API_KEY}";
        };
      };
      gh_grep = {
        type = "http";
        url = "https://mcp.grep.app";
      };
    };
  };

  programs.git.ignores = [
    "**/.claude/settings.local.json"
    "**/.claude/launch.json"
    "**/.claude/worktrees/"
  ];

  # -----
  # Dependencies
  # -----
  home.packages = [
    # Status line dependencies
    pkgs.jq
    # LSP dependencies
    pkgs.typescript-language-server
    pkgs.pyright
    pkgs.vue-language-server
    pkgs.nil
    # MCP dependencies
    pkgs.nodejs_24
    pkgs.yarn
    pkgs.uv
    # Hook dependencies
    pkgs.ruff
    pkgs.prettier
    # Claude Code Usage
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccusage
    # Claude Plugins and Skills
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-plugins
    # TUI code review with Claude
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.tuicr
    # GH CLI is cheaper than Github MCP for some operations
    pkgs.gh
    # Serena MCP
    inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena
  ];

  xdg.configFile = {
    "tuicr" = {
      text = ''
        theme = "catppuccin-frappe"
        diff_view = "side-by-side"   # or "unified"
        appearance = "dark"
        leader = " "
        no_update_check = true
      '';
      target = "tuicr/config.toml";
    };
  };
}
