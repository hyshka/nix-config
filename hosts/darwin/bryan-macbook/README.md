# Bootstrap

1. Install XCode utils to get git
2. Install Homebrew

- https://brew.sh/

```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Perform official nix multi-user installation

- https://nixos.org/download#nix-install-macos

```
$ sh <(curl -L https://nixos.org/nix/install)
```

4. Clone nix-config repo to `~/nix-config` and install with nix-darwin

- http://daiderd.com/nix-darwin/

```
nix run nix-darwin -- switch --flake ~/nix-config
```

5. After installing, you can run darwin-rebuild to apply changes to your system

```
darwin-rebuild switch --flake ~/nix-config
```
