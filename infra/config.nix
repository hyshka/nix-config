{
  inputs,
  lib,
  config,
  ...
}:
let
  system = "x86_64-linux";

  folders = lib.attrNames (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
    ) (builtins.readDir ./.)
  );

  baseModule = name: kind: {
    imports = lib.optional (kind == "container") ./container.nix;
    networking.hostName = name;
  };

  build =
    name: c:
    lib.nixosSystem {
      inherit system;
      modules = [
        (baseModule name c.kind)
        c.configuration
      ];
      specialArgs = { inherit inputs; };
    };

  # Defaults only; any entry can override via `sourceFile`.
  defaultSourceFile = {
    container = nixos: {
      data_path = "${nixos.config.system.build.squashfs}/nixos-lxc-image-${system}.squashfs";
      metadata_path = "${nixos.config.system.build.metadata}/tarball/nixos-image-lxc-${nixos.config.system.nixos.version}-${system}.tar.xz";
    };
    # Placeholder: fill in once we know the VM image outputs.
    virtual-machine = _nixos: { };
  };
in
{
  imports = map (name: ./. + "/${name}") folders;

  options.nixosImages = lib.mkOption {
    default = { };
    description = "NixOS-built images, each with an image resource and a default instance.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          configuration = lib.mkOption {
            type = lib.types.deferredModule;
            description = "NixOS module for this image. Can be a path or an inline module.";
          };
          kind = lib.mkOption {
            type = lib.types.enum [
              "container"
              "virtual-machine"
            ];
            default = "container";
          };
          extraModules = lib.mkOption {
            type = lib.types.listOf lib.types.raw;
            default = [ ];
          };
          sourceFile = lib.mkOption {
            type = lib.types.nullOr lib.types.attrs;
            default = null; # null = derive from `kind`
          };
        };
      }
    );
  };

  config = {
    terraform.required_providers.incus = {
      source = "lxc/incus";
      version = "1.2.0";
    };
    provider.incus = { };

    resource.incus_image = lib.mapAttrs (name: c: {
      source_file =
        if c.sourceFile != null then c.sourceFile else defaultSourceFile.${c.kind} (build name c);
      alias = [ { name = "nixos/custom/${name}"; } ];
    }) config.nixosImages;

    resource.incus_instance = lib.mapAttrs (name: c: {
      inherit name;
      type = lib.mkDefault c.kind;
      image = "\${incus_image.${name}.fingerprint}";
    }) config.nixosImages;
  };
}
