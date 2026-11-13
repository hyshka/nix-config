{
  pkgs,
  ...
}:
let
  caddy = pkgs.caddy.overrideAttrs (_oldAttrs: {
    version = "2.11.9";
    src = pkgs.fetchFromGitHub {
      owner = "caddyserver";
      repo = "caddy";
      tag = "v2.11.9";
      hash = "sha256-K7irjePU998bcbKANXpTf0npirSh+tkc8D3x4JmRdbg=";
    };
    vendorHash = "sha256-qjLumZHCyoM+lNZtWOTmMlHN5zgB36fv9CkIq3ncMlM=";
  });
in
caddy.withPlugins {
  plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
  hash = "sha256-QSiwKqKvSxhksWBF4/MlBOpyXba5xOQ2sRwA0R7399E=";
}
