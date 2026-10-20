{
  description = "NixOS and macOS configurations";

  # Private substituters are configured per-host. Consumers must be on homelab network.
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://mic92.cachix.org"
      "https://nix-darwin.cachix.org"
      "https://catppuccin.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
      "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixGL = {
      url = "github:nix-community/nixgl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # Nixvim recommends against using inputs.nixpkgs.follows = "nixpkgs"; as they test Nixvim against their own Nixpkgs revision. When encountering issues, removing follows should be one of the first debugging steps.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-flake = {
      url = "github:noblepayne/opencode-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openchamber-nix = {
      url = "github:x13-me/openchamber-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenChamber v2 package source. x13-me/openchamber-nix (which provides the
    # NixOS module) is still pinned to OpenChamber 1.24.2, which only supports
    # OpenCode 1.x. This flake packages the official @openchamber/web 2.x npm
    # release, which runs on OpenCode 2.
    openchamber-pkg = {
      url = "github:Tarow/openchamber-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zimfw = {
      url = "github:joedevivo/zimfw.nix";
      inputs.home-manager.follows = "home-manager";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    unocss-language-server = {
      url = "github:xna00/unocss-language-server";
      # Do not follow nixpkgs to avoid pnpmDeps hash mis-match in the unocss-language-server nix pkg
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      treefmt-nix,
      terranix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      treefmtEval = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (treefmt-nix.lib.evalModule pkgs ./treefmt.nix)
      );

      # Helper to create standalone home-manager configurations
      mkHome =
        {
          system,
          hostname,
          username ? "hyshka",
          nixpkgsConfig ? {
            allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                # Explicity add unfree packages for home-manager
                "claude-code"
                "steam"
                "steam-unwrapped"
                "discord"
                "discord-unwrapped"
                "slack"
                "spotify"
              ];
          },
        }:
        let
          pkgs = import nixpkgs {
            system = system;
            config = nixpkgsConfig;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/${username}/${hostname}.nix ];
        };

      # Helper to create container configurations
      mkContainer =
        file:
        lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./containers/${file} ];
          specialArgs = { inherit inputs outputs; };
        };

      # Dynamically discover containers from the containers/ directory
      containers =
        let
          containerDir = ./containers;
          files = builtins.readDir containerDir;
          # Filter for .nix files, excluding default.nix
          nixFiles = lib.filterAttrs (
            name: type:
            (type == "regular" || type == "symlink") && lib.hasSuffix ".nix" name && name != "default.nix"
          ) files;

        in
        lib.mapAttrs' (name: _: {
          name = lib.removeSuffix ".nix" name;
          value = mkContainer name;
        }) nixFiles;

      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      tofu = pkgs.opentofu;
      terraformConfiguration = terranix.lib.terranixConfiguration {
        system = "x86_64-linux";
        modules = [ ./infra/config.nix ];
        extraArgs = { inherit inputs lib; };
      };

      imageArtifacts = terraformConfiguration.passthru._meta.imageArtifacts;

      imageVarsFile = pkgs.writeText "image-vars.json" (
        builtins.toJSON {
          image_files = lib.mapAttrs (_name: a: {
            inherit (a) data_path metadata_path;
          }) imageArtifacts;
        }
      );

      imagePathsFile = pkgs.writeText "image-paths.txt" (
        lib.concatStringsSep "\n" (
          lib.unique (
            lib.concatLists (
              lib.mapAttrsToList (_name: a: [
                a.image
                a.metadata
                a.toplevel
              ]) imageArtifacts
            )
          )
        )
        + "\n"
      );

      mkTofuApp =
        {
          pkgs,
          name,
          cmd,
          varFile ? null,
        }:
        let
          extraArgs =
            {
              plan = [ "-lock-timeout=5m" ];
              apply = [
                "-auto-approve"
                "-lock-timeout=5m"
              ];
              destroy = [ "-lock-timeout=5m" ];
              validate = [ ];
            }
            .${cmd} or [ ];
          varArgs = lib.optionalString (varFile != null) "-var-file=${varFile}";
        in
        {
          type = "app";
          program = toString (
            pkgs.writers.writeBash name ''
              set -euo pipefail

              if [ -n "''${CI:-}" ]; then
                # CI: keep checkout clean and never rewrite the lock file.
                workdir="$(mktemp -d)"
                trap 'rm -rf "$workdir"' EXIT
                ln -sf ${terraformConfiguration} "$workdir/config.tf.json"
                cp -f ./.terraform.lock.hcl "$workdir/" 2>/dev/null || true
                cd "$workdir"
                initArgs=(-input=false -lockfile=readonly)
              else
                ln -sf ${terraformConfiguration} config.tf.json
                initArgs=()
              fi

              if [ -n "''${TOFU_INIT_ARGS:-}" ]; then
                # shellcheck disable=SC2206
                initArgs+=(''${TOFU_INIT_ARGS})
              fi

              if [ ${cmd} = validate ]; then
                ${tofu}/bin/tofu init -backend=false "''${initArgs[@]}"
                ${tofu}/bin/tofu validate "$@"
                exit
              fi

              ${tofu}/bin/tofu init "''${initArgs[@]}"
              ${tofu}/bin/tofu ${cmd} ${lib.escapeShellArgs extraArgs} ${varArgs} "$@"
            ''
          );
        };
    in
    {
      inherit lib;

      # Reusable modules you might want to export
      # These are usually stuff you would upstream
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );

      # Dev shells
      devShells = forEachSystem (system: {
        default = import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      });

      formatter = forEachSystem (system: treefmtEval.${system}.config.build.wrapper);
      checks = forEachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      # NixOS configuration entrypoint
      # nh os built/boot/switch
      nixosConfigurations = {
        starship = lib.nixosSystem {
          modules = [ ./hosts/nixos/starship ];
          specialArgs = { inherit inputs outputs; };
        };
        rpi4 = lib.nixosSystem {
          modules = [ ./hosts/nixos/rpi4 ];
          specialArgs = { inherit inputs outputs; };
        };
        tiny1 = lib.nixosSystem {
          modules = [ ./hosts/nixos/tiny1 ];
          specialArgs = { inherit inputs outputs; };
        };
        ashyn = lib.nixosSystem {
          modules = [ ./hosts/nixos/ashyn ];
          specialArgs = { inherit inputs outputs; };
        };
      }
      // containers;

      # Nix-Darwin configuration entrypoint
      # nh darwin built/boot/switch
      darwinConfigurations = {
        "hyshka-D5920DQ4RN" = nix-darwin.lib.darwinSystem {
          modules = [ ./hosts/darwin/bryan-macbook ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      # Standalone home-manager configurations
      # nh home build/switch
      homeConfigurations = {
        "hyshka@tiny1" = mkHome {
          system = "x86_64-linux";
          hostname = "tiny1";
        };
        "hyshka@starship" = mkHome {
          system = "x86_64-linux";
          hostname = "starship";
        };
        "hyshka@ashyn" = mkHome {
          system = "x86_64-linux";
          hostname = "ashyn";
        };
        "hyshka@hyshka-D5920DQ4RN" = mkHome {
          system = "aarch64-darwin";
          hostname = "macbook";
        };
      };

      apps = forEachSystem (system: {
        plan = mkTofuApp {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "plan";
          cmd = "plan";
          varFile = imageVarsFile;
        };
        apply = mkTofuApp {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "apply";
          cmd = "apply";
          varFile = imageVarsFile;
        };
        destroy = mkTofuApp {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "destroy";
          cmd = "destroy";
          varFile = imageVarsFile;
        };
        validate = mkTofuApp {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "validate";
          cmd = "validate";
        };
        default = mkTofuApp {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "plan";
          cmd = "plan";
          varFile = imageVarsFile;
        };
        image-paths = {
          type = "app";
          program = toString (
            nixpkgs.legacyPackages.${system}.writers.writeBash "image-paths" ''
              cat ${imagePathsFile}
            ''
          );
        };
      });
    };
}
