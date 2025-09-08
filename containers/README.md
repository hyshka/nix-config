# Managing Incus Containers

This directory contains the NixOS configurations for various services running inside Incus containers. The `incus-manager.sh` script in the root of the repository helps automate the deployment and setup of these containers.

## `incus-manager.sh` CLI

The `incus-manager.sh` script provides a command-line interface to streamline common tasks.

### Deployment Commands
These commands can operate on a comma-separated list of containers (e.g., `incus-manager.sh deploy immich,samba`).

- `build <containers>`: Builds the container image(s).
- `import <containers>`: Imports the built image(s) into the Incus remote.
- `rebuild <containers>`: Rebuilds the container(s) on the remote using the latest image.
- `restart <containers>`: Restarts the container(s).
- `deploy <containers>`: A meta-command that runs `import`, `rebuild`, and `restart` in sequence.

### Setup Commands
These commands operate on a single container.

- `create <container>`: Creates a new container from its corresponding `nixos/custom/<container>` image.
- `add-persist-disk <container>`: Adds the standard `/persist` disk, which is used to store the container's SSH host key.
- `set-ip <container> [ip_address]`: Sets a static IP address. If no IP is provided, it detects and uses the container's current dynamic IP.
- `get-age-key <container>`: Computes and prints the age public key derived from the container's persistent SSH host key.

---

## Common Container Setup Workflow

Here are the typical steps to create and configure a new container from scratch.

1.  **Create Container Configuration**: Create a new `my-container.nix` file in this directory, using `default.nix` and other examples as a template.

2.  **Initial Deploy**: Build and import the container image to the Incus host.
    ```bash
    ./incus-manager.sh import my-container
    ```

3.  **Create Container**: Create the container instance and add its persistent disk for the SSH host key.
    **Note:** You still need to manually create the persistent directory on the host machine. E.g. mkdir /persist/microvms/my-container. Eventually, we'll be able to script this.
    ```bash
    ./incus-manager.sh create my-container
    ./incus-manager.sh add-persist-disk my-container
    ```

4.  **Start and Set IP**: Start the container and assign a static IP address to it.
    ```bash
    incus start my-container
    ./incus-manager.sh set-ip my-container
    ```

5.  **Get Age Key for Secrets**: With the persistent disk mounted and the container running, the SSH host key is generated. Use this key to derive an age public key for encrypting secrets.
    ```bash
    ./incus-manager.sh get-age-key my-container
    ```
    The output is the age public key for this container.

6.  **Add Secrets**: Create a `secrets/my-container.yaml` file and add the age key from the previous step to the `sops.age` list. You can now add secrets to this file. See the "Adding Secrets" section below.

7.  **Final Deploy**: Re-deploy the container to include the secrets.
    ```bash
    ./incus-manager.sh deploy my-container
    ```

---

## Advanced Configuration

### Adding Secrets

1.  Get the container's age key (`./incus-manager.sh get-age-key my-container`) and add it as a host in the root `.sops.yaml` file.
2.  Create a new file to add your secrets: `sops containers/secrets/my-container.yaml`.
3.  In `my-container.nix`, reference the secret file:
    ```nix
    sops.secrets.my-secret-name = {
      sopsFile = ./secrets/my-container.yaml;
    };
    ```
4.  The decrypted secret will be available inside the container at the path specified by `config.sops.secrets.my-secret-name.path`.

### Adding Data Storage

To mount a directory from the host into the container (e.g., for persistent data), use the `incus config device add` command.

**Example**: Mount `/mnt/storage/data` on the host to `/data` in the container.
```bash
incus config device add my-container data-disk disk source=/mnt/storage/data path=/data
```

If user/group permissions need to be mapped between the host and container, you may also need to set `raw.idmap`.

### Proxying Ports

To expose a container's port on the host, you can use a `proxy` device. This is useful when the container's IP is not directly accessible on the local network.

**Example**: Forward host ports `80` and `443` to a container with the IP `10.0.0.10`.
```bash
# For TCP
incus config device add my-container http-proxy proxy listen=tcp:0.0.0.0:80,443 connect=tcp:10.0.0.10:80,443

# For UDP
incus config device add my-container dns-proxy proxy listen=udp:0.0.0.0:53 connect=udp:10.0.0.10:53
```
