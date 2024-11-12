{
  description = "NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Darwin
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # nixGL
    nixGL = {
      url = "github:nix-community/nixgl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma Manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Lanzaboote for secure boot support
    lanzaboote.url = "github:nix-community/lanzaboote";

    # nixvim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-hardware
    hardware.url = "github:nixos/nixos-hardware";

    # catppuccin color themes
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
        specialArgs = {inherit inputs outputs;};
      };
      ashyn = lib.nixosSystem {
        modules = [./hosts/ashyn];
        specialArgs = {inherit inputs outputs;};
      };
    };

    # Nix-Darwin configuration entrypoint
    # TODO: darwin-rebuild is not installed
    # nix run 'nix-darwin#darwin-rebuild' -- switch --flake .
    # nix run nix-darwin -- switch --flake .
    darwinConfigurations = {
      "hyshka-D5920DQ4RN" = nix-darwin.lib.darwinSystem {
        modules = [./hosts/bryan-macbook];
        specialArgs = {inherit inputs outputs;};
      };
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."hyshka-D5920DQ4RN".pkgs;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager switch --flake .#your-username@your-hostname'
    homeConfigurations = {
      "hyshka@starship" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/hyshka/starship.nix
          ./home/hyshka/nixpkgs.nix
        ];
      };
      "hyshka@tiny1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        # TODO
        #modules = [./home/home-cli.nix];
      };
      "hyshka@rpi4" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        # TODO
        #modules = [./home/home-cli.nix];
      };
      "hyshka@ashyn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/hyshka/ashyn.nix
          ./home/hyshka/nixpkgs.nix
        ];
      };
    };
  };
}
