{
  lib,
  caddy,
  xcaddy,
  buildGoModule,
  stdenv,
  cacert,
  go,
}: let
  version = "2.8.4";
  rev = "v${version}";
in
  (caddy.overrideAttrs (_: {inherit version;})).override {
    buildGoModule = args:
      buildGoModule (args
        // {
          src = stdenv.mkDerivation rec {
            pname = "caddy-using-xcaddy-${xcaddy.version}";
            inherit version;

            dontUnpack = true;
            dontFixup = true;

            nativeBuildInputs = [
              cacert
              go
            ];

            plugins = [
              # https://github.com/caddy-dns/cloudflare
              "github.com/caddy-dns/cloudflare@89f16b99c18ef49c8bb470a82f895bce01cbaece"
            ];

            configurePhase = ''
              export GOCACHE=$TMPDIR/go-cache
              export GOPATH="$TMPDIR/go"
              export XCADDY_SKIP_BUILD=1
            '';

            buildPhase = ''
              ${xcaddy}/bin/xcaddy build "${rev}" ${lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins}
              cd buildenv*
              go mod vendor
            '';

            installPhase = ''
              cp -r --reflink=auto . $out
            '';

            outputHash = "sha256-43SOmmz/iAvUhbzFZ9THRqsys7/eK6Oo1xVGZcsmZIw=";
            outputHashMode = "recursive";
          };

          subPackages = ["."];
          ldflags = ["-s" "-w"]; ## don't include version info twice
          vendorHash = null;
        });
  }
