{
  description = "NixOS and macOS configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
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

    microvm = {
      url = "github:astro/microvm.nix";
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
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    # TODO rework this
    forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
    pkgsFor = nixpkgs.legacyPackages;
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
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    # Dev shells
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forEachSystem (pkgs: pkgs.alejandra);

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

      # MicroVMs
      paperless = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.microvm.nixosModules.microvm
          inputs.sops-nix.nixosModules.sops
          inputs.impermanence.nixosModules.impermanence
          ({config, ...}: {
            networking.hostName = "paperless";
            sops.secrets.root_password = {
              sopsFile = ./hosts/tiny1/services/paperless/secrets.yaml;
              neededForUsers = true;
            };
            #users.users.root.hashedPasswordFile = config.sops.secrets.root_password.path;
            users.users.root.password = "toor";
            systemd.network.enable = true;
            system.stateVersion = "24.11";
            systemd.sockets.sshd = {
              socketConfig = {
                ListenStream = [
                  "vsock:1337:22"
                ];
              };
            };
            microvm = {
              mem = 2000;
              vsock.cid = 1337;
              interfaces = [
                {
                  type = "tap";
                  id = "vm-qemu-1";
                  # TODO: requires manual sudo ip link set vm-qemu-1 address 02:00:00:00:00:02
                  mac = "02:00:00:00:00:02";
                }
              ];
              #volumes = [
              #  {
              #    mountPoint = "/";
              #    image = "root.img";
              #    size = 1 * 1024;
              #  }
              #];
              shares = [
                {
                  tag = "ro-store";
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  proto = "virtiofs";
                }
                {
                  tag = "persist";
                  # TODO: requires sudo mkdir -p /persist/microvms/paperless first
                  source = "/persist/microvms/${config.networking.hostName}";
                  mountPoint = "/persist";
                  proto = "virtiofs";
                }
                {
                  proto = "virtiofs";
                  tag = "paperless-mediadir";
                  source = "/mnt/storage/paperless";
                  mountPoint = "/mnt/paperless";
                }
              ];
            };

            # Persistent host key for secrets
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
              hostKeys = [
                {
                  path = "/etc/ssh/ssh_host_ed25519_key";
                  type = "ed25519";
                }
              ];
            };
            fileSystems."/persist".neededForBoot = lib.mkForce true;
            environment.persistence."/persist" = {
              files = [
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
              ];
            };

            # Service definition
            # TODO: disable ssh when stable
            networking.firewall.allowedTCPPorts = [22 28981];
            sops.secrets.paperless-passwordFile = {
              sopsFile = ./hosts/tiny1/services/paperless/secrets.yaml;
            };

            services.paperless = {
              enable = true;
              mediaDir = "/mnt/paperless/";
              passwordFile = config.sops.secrets.paperless-passwordFile.path;
              address = "0.0.0.0";
              # https://docs.paperless-ngx.com/configuration/
              settings = {
                PAPERLESS_URL = "https://paperless.home.hyshka.com";
                PAPERLESS_TRUSTED_PROXIES = "127.0.0.1,10.1.0.2";
              };
            };
          })
        ];
      };

      # NixOS Containers
      demo = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({pkgs, ...}: {
            boot.isContainer = true;

            networking.firewall.allowedTCPPorts = [80];

            services.httpd = {
              enable = true;
              adminAddr = "morty@example.org";
            };

            system.stateVersion = "24.11";
          })
        ];
      };

      # LXC demo container
      container = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          {system.stateVersion = "23.11";}
          (
            {pkgs, ...}: {
              environment.systemPackages = [pkgs.vim];
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
