{
  description = "NixOS and macOS configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

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

    impermanence.url = "github:nix-community/impermanence";

    hardware.url = "github:nixos/nixos-hardware";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    inherit lib;

    # Reusable modules you might want to export
    # These are usually stuff you would upstream
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in import ./pkgs {inherit pkgs;});

    # Dev shells
    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in import ./shell.nix {inherit pkgs;});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      starship = lib.nixosSystem {
        modules = [./hosts/starship];
        specialArgs = {inherit inputs outputs;};
      };
      rpi4 = lib.nixosSystem {
        modules = [./hosts/rpi4];
        specialArgs = {inherit inputs outputs;};
      };
      tiny1 = lib.nixosSystem {
        modules = [./hosts/tiny1];
        specialArgs = {inherit self inputs outputs;};
      };
      ashyn = lib.nixosSystem {
        modules = [./hosts/ashyn];
        specialArgs = {inherit inputs outputs;};
      };

      # LXC demo container
      paperless = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          inputs.sops-nix.nixosModules.sops
          inputs.impermanence.nixosModules.impermanence
          (
            {config, ...}: {
              # Base
              networking.hostName = "paperless";
              system.stateVersion = "23.11";

              # Persistent host key for secrets
              # incus config device add paperless persist disk source=/persist/microvms/paperless path=/persist shift=true
              services.openssh = {
                hostKeys = [
                  {
                    path = "/etc/ssh/ssh_host_ed25519_key";
                    type = "ed25519";
                  }
                ];
              };
              fileSystems."/persist" = {
                mountPoint = "/persist";
                # Device only exists at runtime, fake it for now to build the rootfs
                device = "none";
                fsType = "none";
                options = ["bind"];
                neededForBoot = lib.mkForce true;
              };
              environment.persistence."/persist" = {
                files = [
                  "/etc/ssh/ssh_host_ed25519_key"
                  "/etc/ssh/ssh_host_ed25519_key.pub"
                ];
              };

              # Application
              networking.firewall.allowedTCPPorts = [28981];
              sops.secrets.paperless-passwordFile = {
                sopsFile = ./hosts/tiny1/services/paperless/secrets.yaml;
              };

              services.paperless = {
                enable = true;
                # map root on host to paperless (315) in the container
                # incus config device add paperless data disk source=/mnt/storage/paperless path=/mnt/paperless/ raw.mount.options=idmap=b:315:0:1
                # incus config set paperless raw.idmap=both 0 315
                mediaDir = "/mnt/paperless/";
                passwordFile = config.sops.secrets.paperless-passwordFile.path;
                address = "0.0.0.0";
                # https://docs.paperless-ngx.com/configuration/
                settings = {
                  PAPERLESS_URL = "https://paperless.home.hyshka.com";
                  PAPERLESS_TRUSTED_PROXIES = "127.0.0.1,10.223.27.210";
                };
              };
            }
          )
        ];
        specialArgs = {inherit inputs outputs;};
      };
    };

    # Nix-Darwin configuration entrypoint
    # nix run 'nix-darwin#darwin-rebuild' -- switch --flake .
    # nix run nix-darwin -- switch --flake .
    # darwin-rebuild switch --flake .
    darwinConfigurations = {
      "hyshka-D5920DQ4RN" = nix-darwin.lib.darwinSystem {
        modules = [./hosts/bryan-macbook];
        specialArgs = {inherit inputs outputs;};
      };
    };
  };
}
