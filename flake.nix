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

    # Lanzaboote for secure boot support
    lanzaboote.url = "github:nix-community/lanzaboote";

    # nixvim, follows unstable
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Add any other flake you might need
    hardware.url = "github:nixos/nixos-hardware";
    zimfw.url = "github:joedevivo/zimfw.nix";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    sops-nix,
    nixvim,
    catppuccin,
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
        modules = [./hosts/starship/configuration.nix];
        specialArgs = {inherit inputs outputs;};
      };
      rpi4 = lib.nixosSystem {
        modules = [./hosts/rpi4/configuration.nix];
        specialArgs = {inherit inputs outputs;};
      };
      tiny1 = lib.nixosSystem {
        modules = [./hosts/tiny1/configuration.nix];
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
      # TODO: update weird company hostname?
      "hyshka-D5920DQ4RN" = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/bryan-macbook/configuration.nix
          home-manager.darwinModules.home-manager
          {
            # If you want to use home-manager modules from other flakes:
            home-manager.sharedModules =
              [
                #zimfw.homeManagerModules.zimfw
                sops-nix.homeManagerModule
                catppuccin.homeManagerModules.catppuccin
                nixvim.homeManagerModules.nixvim
              ]
              ++ (builtins.attrValues outputs.homeManagerModules);
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.hyshka = import ./hosts/bryan-macbook/home.nix;
          }
        ];
        specialArgs = {inherit inputs outputs;};
      };
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."hyshka-D5920DQ4RN".pkgs;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager switch --flake .#your-username@your-hostname'
    homeConfigurations = {
      "hyshka@starship" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./home/home-cli.nix
          ./home/desktop
          ./home/zwift.nix
        ];
      };
      "hyshka@tiny1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/home-cli.nix];
      };
      "hyshka@rpi4" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/home-cli.nix];
      };
      "hyshka@ashyn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/home-cli.nix
          ./home/desktop/font.nix
          ./home/alacritty.nix
          ./home/desktop-ashyn.nix
        ];
      };
    };
  };
}
