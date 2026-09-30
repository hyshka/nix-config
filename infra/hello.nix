{
  containers,
  ...
}:
let
  containerName = "hello";
  nixos = containers.${containerName};

  version = nixos.config.system.nixos.version;
  metadata = nixos.config.system.build.metadata;
  squashfs = nixos.config.system.build.squashfs;
in
{
  resource.incus_image.hello_img = {
    source_file = {
      data_path = "${squashfs}/nixos-lxc-image-x86_64-linux.squashfs";
      metadata_path = "${metadata}/tarball/nixos-image-lxc-${version}-x86_64-linux.tar.xz";
    };

    alias = [
      {
        name = "nixos/custom/${containerName}";
      }
    ];
  };

  resource.incus_instance."${containerName}" = {
    name = containerName;
    image = "\${incus_image.hello_img.fingerprint}";
  };
}
