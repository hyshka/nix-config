{
  description = "NixOS and macOS configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://mic92.cachix.org"
      "https://nix-darwin.cachix.org"
      "https://catppuccin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
      "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
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

    impermanence.url = "github:nix-community/impermanence";
    hardware.url = "github:nixos/nixos-hardware";
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
    in
      import ./pkgs {inherit pkgs;});

    # Dev shells
    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      import ./shell.nix {inherit pkgs;});

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

      # Incus LXC containers
      paperless = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/paperless.nix];
        specialArgs = {inherit inputs outputs;};
      };
      immich = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/immich.nix];
        specialArgs = {inherit inputs outputs;};
      };
      samba = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/samba.nix];
        specialArgs = {inherit inputs outputs;};
      };
      silverbullet = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/silverbullet.nix];
        specialArgs = {inherit inputs outputs;};
      };
      cryptpad = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/cryptpad.nix];
        specialArgs = {inherit inputs outputs;};
      };
      calibre = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/calibre.nix];
        specialArgs = {inherit inputs outputs;};
      };
      ntfy = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./containers/ntfy.nix];
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
