{
  description = "NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-Darwin
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Lanzaboote for secure boot support
    lanzaboote.url = "github:nix-community/lanzaboote";

    # nixvim, follows unstable
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

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
    forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
    pkgsFor = nixpkgs.legacyPackages;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forEachSystem (pkgs: pkgs.alejandra);
    # Dev shells
    # TODO
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      starship = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;}; # Pass flake inputs to our config
        # > Our main nixos configuration file <
        modules = [./hosts/starship/configuration.nix];
      };
      nixos-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/nixos-vm/configuration.nix];
      };
      rpi4 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/rpi4/configuration.nix];
      };
      tiny1 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/tiny1/configuration.nix];
      };
      ashyn = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/ashyn/configuration.nix];
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
    # TODO: I'm not sure how this is helpful yet.
    darwinPackages = self.darwinConfigurations."hyshka-D5920DQ4RN".pkgs;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager switch --flake .#your-username@your-hostname'
    homeConfigurations = {
      "hyshka@starship" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./home-manager/home-cli.nix
          ./home-manager/desktop
          ./home-manager/zwift.nix
        ];
      };
      "hyshka@nixos-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home-manager/home-cli.nix];
      };
      "hyshka@tiny1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home-manager/home-cli.nix];
      };
      "hyshka@rpi4" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home-manager/home-cli.nix];
      };
      "hyshka@ashyn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/home-cli.nix
          ./home-manager/desktop/font.nix
          ./home-manager/alacritty.nix
          ./home-manager/desktop-ashyn.nix
        ];
      };
    };
  };
}
