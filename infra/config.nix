{
  ...
}:
{
  imports = [
    ./hello.nix
  ];

  terraform.required_providers = {
    incus = {
      source = "lxc/incus";
      version = "1.2.0";
    };
  };

  provider.incus = { };
}
