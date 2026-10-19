{
  inputs,
  lib,
  config,
  ...
}:
let
  system = "x86_64-linux";

  # Every workload tofu owns lives in this project. Hosts preseed it alongside
  # the restricted CI certificate (see hosts/nixos/*/incus.nix), which keeps the
  # CI credential away from anything in `default`.
  project = "lab-default";

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
  imageArtifact = {
    container = nixos: {
      image = nixos.config.system.build.squashfs;
      metadata = nixos.config.system.build.metadata;
      data_path = "${nixos.config.system.build.squashfs}/nixos-lxc-image-${system}.squashfs";
      metadata_path = "${nixos.config.system.build.metadata}/tarball/nixos-image-lxc-${nixos.config.system.nixos.version}-${system}.tar.xz";
    };
    virtual-machine = nixos: {
      image = nixos.config.system.build.repartImage;
      metadata = nixos.config.system.build.metadata;
      data_path = "${nixos.config.system.build.repartImage}/nixos.qcow2";
      metadata_path = "${nixos.config.system.build.metadata}/tarball/${nixos.config.image.baseName}.tar.xz";
    };
  };

  # Published through `_meta`; the flake renders it into `var.image_files` for
  # tofu and into the store path list the binary cache push uses.
  images = lib.mapAttrs (name: c: imageArtifact.${c.kind} (build name c)) (
    lib.filterAttrs (_name: c: c.sourceFile == null) config.nixosImages
  );
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
    _meta.imageArtifacts = images;

    variable.image_files = {
      type = "map(object({ data_path = string, metadata_path = string }))";
      description = "Store paths of the built NixOS images. Supplied by the flake apps, unset for validate.";
    };

    terraform.required_providers.incus = {
      source = "lxc/incus";
      version = "1.2.0";
    };

    # Credentials come from the environment (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY),
    # never from committed config. Native state/plan encryption is configured
    # separately via TF_ENCRYPTION so the passphrase never reaches the store.
    terraform.backend.s3 = {
      bucket = "nix-config-tofu";
      key = "infra/terraform.tfstate";
      region = "us-east-1";
      endpoints.s3 = "https://s3.home.hyshka.com";
      use_lockfile = true;
      use_path_style = true;
      skip_credentials_validation = true;
      skip_region_validation = true;
      skip_requesting_account_id = true;
      skip_metadata_api_check = true;
      # SeaweedFS does not implement the AWS chunked checksum trailer.
      skip_s3_checksum = true;
    };

    provider.incus = {
      default_remote = "tiny1";
      # The CI client certificate is minted out of band, trusted as a restricted
      # project-scoped cert by each host's preseed, and handed to the provider
      # through $INCUS_CONF.
      generate_client_certificates = false;
      accept_remote_certificate = true;
      remote = [
        {
          name = "starship";
          address = "https://starship:8443";
        }
        {
          name = "tiny1";
          address = "https://tiny1:8443";
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

    resource.incus_image = lib.mapAttrs (name: c: {
      inherit (c) remote;
      project = project;
      source_file =
        if c.sourceFile != null then
          c.sourceFile
        else
          {
            data_path = "\${var.image_files[\"${name}\"].data_path}";
            metadata_path = "\${var.image_files[\"${name}\"].metadata_path}";
          };
      alias = [ { name = "nixos/custom/${name}"; } ];
    }) config.nixosImages;

    resource.incus_instance = lib.mapAttrs (
      name: c:
      {
        inherit name;
        inherit (c) remote;
        project = project;
        type = lib.mkDefault c.kind;
        image = "\${incus_image.${name}.fingerprint}";
      }
      // lib.optionalAttrs (c.kind == "container" && c.remote == "tiny1") {
        profiles = [ "nixos-container" ];
      }
    ) config.nixosImages;
  };
}
