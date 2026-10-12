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
    imports =
      lib.optional (kind == "container") ./container.nix
      ++ lib.optional (kind == "virtual-machine") ./virtual-machine.nix;
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
  # TODO: source these from a common build machine or image remote
  defaultSourceFile = {
    container = nixos: {
      data_path = "${nixos.config.system.build.squashfs}/nixos-lxc-image-${system}.squashfs";
      metadata_path = "${nixos.config.system.build.metadata}/tarball/nixos-image-lxc-${nixos.config.system.nixos.version}-${system}.tar.xz";
    };
    virtual-machine = nixos: {
      data_path = "${nixos.config.system.build.repartImage}/nixos.qcow2";
      metadata_path = "${nixos.config.system.build.metadata}/tarball/${nixos.config.image.baseName}.tar.xz";
    };
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
          remote = lib.mkOption {
            type = lib.types.str;
            default = "tiny1";
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
    provider.incus = {
      default_remote = "tiny1";
      generate_client_certificates = true;
      accept_remote_certificate = true;
      remote = [
        {
          name = "starship";
          address = "https://starship:8443";
        }
        {
          name = "tiny1";
          address = "https://tiny1:8443";
          authentication_type = "oidc";
        }
        {
          name = "images";
          address = "https://images.linuxcontainers.org";
          protocol = "simplestreams";
          public = true;
        }
        {
          name = "oci-github";
          address = "https://ghcr.io";
          protocol = "oci";
          public = true;
        }
      ];
    };

    import = [
      {
        to = "incus_profile.nixos-container";
        id = "tiny1:nixos-container";
      }
      {
        to = "incus_storage_pool.default";
        id = "tiny1:default";
      }
      {
        to = "incus_storage_pool.storage";
        id = "tiny1:storage";
      }
    ];

    resource.incus_storage_pool = {
      default = {
        name = "default";
        remote = "tiny1";
        driver = "dir";
        description = "SSD-backed storage for databases and container state";
        config.source = "/var/lib/incus/storage-pools/default";
      };
      storage = {
        name = "storage";
        remote = "tiny1";
        driver = "dir";
        description = "HDD-based bulk data for backups, media, etc";
        config.source = "/mnt/storage/incus";
      };
    };

    resource.incus_profile."nixos-container" = {
      name = "nixos-container";
      remote = "tiny1";
      description = "Standard profile for NixOS LXC containers";
      config = {
        "raw.idmap" = "both 0 0";
        "security.nesting" = "true";
      };
      device = [
        {
          name = "eth0";
          type = "nic";
          properties = {
            network = "incusbr0";
          };
        }
        {
          name = "persist";
          type = "disk";
          properties = {
            path = "/persist";
            shift = "true";
            # TODO: this needs to be overriden per-instance and must be reworked
            # e.g. /persist/microvms/<instance_name>
            source = "/persist/microvms/";
          };
        }
        {
          name = "root";
          type = "disk";
          properties = {
            path = "/";
            pool = "default";
          };
        }
        {
          name = "sops-age-key";
          type = "disk";
          properties = {
            path = "/var/lib/sops-nix/key.txt";
            "raw.mount.options" = "uid=0,gid=0";
            readonly = "true";
            source = "/run/secrets/lxc-core-age-key";
          };
        }
      ];
    };

    resource.incus_image = lib.mapAttrs (name: c: {
      inherit (c) remote;
      source_file =
        if c.sourceFile != null then c.sourceFile else defaultSourceFile.${c.kind} (build name c);
      alias = [ { name = "nixos/custom/${name}"; } ];
    }) config.nixosImages;

    resource.incus_instance = lib.mapAttrs (
      name: c:
      {
        inherit name;
        inherit (c) remote;
        type = lib.mkDefault c.kind;
        image = "\${incus_image.${name}.fingerprint}";
      }
      // lib.optionalAttrs (c.kind == "container" && c.remote == "tiny1") {
        profiles = [ "\${incus_profile.nixos-container.name}" ];
      }
    ) config.nixosImages;
  };
}
