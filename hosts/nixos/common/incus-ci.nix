{
  pkgs,
  ...
}:
let
  # Private key is the sops secret `incus-ci-client-key` on the build runner.
  # Mint a replacement with:
  #   openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
  #     -keyout client.key -out client.crt -days 3650 -subj "/CN=forgejo-ci"
  certificate = ../../../infra/ci-client.crt;
in
{
  # The project the CI certificate is scoped to.
  virtualisation.incus.preseed = {
    projects = [
      {
        name = "lab-default";
        config = {
          restricted = "true";
          "restricted.storage-pools.access" = "default";
          "features.images" = "true"; # own image namespace
          "features.profiles" = "true"; # required
          "features.networks" = "false"; # share the default project's networks

          "restricted.containers.nesting" = "allow"; # profile: security.nesting
          "restricted.idmap.uid" = "0"; # profile: raw.idmap = "both 0 0"
          "restricted.idmap.gid" = "0";
          # profile: the sops age key is a host path
          "restricted.devices.disk" = "allow";
          "restricted.devices.disk.paths" = "/run/incus-secrets";
          "restricted.devices.proxy" = "allow"; # instance: forgejo's ssh proxy
        };
      }
    ];

    # An instance with no `profiles` gets this project's `default`.
    profiles = [
      {
        name = "default";
        project = "lab-default";
        description = "Default profile for lab-default workloads";
        devices = {
          eth0 = {
            type = "nic";
            network = "incusbr0";
          };
          root = {
            type = "disk";
            path = "/";
            pool = "default";
          };
        };
      }
    ];
  };

  # `incus admin init --preseed` creates trust entries unconditionally and
  # aborts when the certificate is already trusted, so registering it there
  # fails the preseed unit on every boot after the first. This is a no-op once
  # the fingerprint is trusted.
  systemd.services.incus-ci-trust = {
    description = "Trust the CI client certificate";
    wantedBy = [ "incus.service" ];
    wants = [ "incus-preseed.service" ];
    after = [
      "incus.service"
      "incus-preseed.service"
    ];
    bindsTo = [ "incus.service" ];
    partOf = [ "incus.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      incus=${pkgs.incus}/bin/incus
      $incus admin waitready

      fingerprint=$(${pkgs.openssl}/bin/openssl x509 -in ${certificate} -noout -fingerprint -sha256 \
        | ${pkgs.gnused}/bin/sed -e 's/^.*=//' -e 's/://g' \
        | ${pkgs.coreutils}/bin/tr 'A-Z' 'a-z')

      if $incus config trust list --format=json \
        | ${pkgs.jq}/bin/jq -e --arg fp "$fingerprint" 'any(.[]; .fingerprint == $fp)' >/dev/null; then
        exit 0
      fi

      stale=$($incus config trust list --format=json \
        | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "forgejo-ci") | .fingerprint')
      if [ -n "$stale" ]; then
        $incus config trust remove "$stale"
      fi

      $incus config trust add-certificate ${certificate} \
        --name forgejo-ci --restricted --projects lab-default
    '';
  };
}
