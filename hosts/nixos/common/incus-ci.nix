{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Private key is the sops secret `incus-ci-client-key` on the Starship host
  # runner.
  # Mint a replacement with:
  #   openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
  #     -keyout client.key -out client.crt -days 3650 -subj "/CN=forgejo-ci"
  certificate = ../../../infra/ci-client.crt;

  # Derived from the projects the importing host preseed, so the certificate
  # scope cannot drift from the host's own services/incus.nix.
  projects = lib.concatStringsSep "," (map (p: p.name) config.virtualisation.incus.preseed.projects);
in
{
  # `incus admin init --preseed` creates trust entries unconditionally and
  # aborts when the certificate is already trusted, so registering it there
  # fails the preseed unit on every boot after the first. This is a no-op once
  # the fingerprint is trusted with the right scope.
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

      # Re-add when the project scope changed too, not only when the
      # fingerprint did: an unchanged certificate already trusted with the old
      # project list would otherwise keep its old scope.
      if $incus config trust list --format=json \
        | ${pkgs.jq}/bin/jq -e \
            --arg fp "$fingerprint" \
            --arg projects "${projects}" \
            'any(.[];
               .fingerprint == $fp
               and .restricted == true
               and ((.projects // []) | sort | join(",")) == ($projects | split(",") | sort | join(","))
             )' >/dev/null; then
        exit 0
      fi

      stale=$($incus config trust list --format=json \
        | ${pkgs.jq}/bin/jq -r --arg fp "$fingerprint" \
            '.[] | select(.fingerprint == $fp or .name == "forgejo-ci") | .fingerprint' \
        | ${pkgs.coreutils}/bin/sort -u)
      for entry in $stale; do
        $incus config trust remove "$entry"
      done

      $incus config trust add-certificate ${certificate} \
        --name forgejo-ci --restricted \
        --projects ${projects}
    '';
  };
}
