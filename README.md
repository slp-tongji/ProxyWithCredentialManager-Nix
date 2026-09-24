# ProxyWithCredentialManager-Nix

Nix packaging for [ProxyWithCredentialManager](https://github.com/slp-tongji/ProxyWithCredentialManager) — a proxy server with a credential manager API for creating, querying and revoking proxy credentials.

## Adding as a flake input

```nix
{
  inputs = {
    proxy-with-credential-manager.url = "github:slp-tongji/ProxyWithCredentialManager-Nix";
  };
}
```

## Package

The binary is exposed as `ProxyWithCredentialManager`:

```nix
proxy-with-credential-manager.packages.${system}.proxy-with-credential-manager
```

Or try it directly from the CLI:

```console
$ nix shell github:slp-tongji/ProxyWithCredentialManager-Nix
$ ProxyWithCredentialManager run \
    --proxy-port 8080 \
    --credential-manager-port 8081 \
    --credential-database /tmp/credentials.db
```

## NixOS module

A module is exposed as `nixosModules.proxy-with-credential-manager` (also
available as `nixosModules.default`):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    proxy-with-credential-manager.url = "github:slp-tongji/ProxyWithCredentialManager-Nix";
  };

  outputs = { nixpkgs, proxy-with-credential-manager, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        proxy-with-credential-manager.nixosModules.default
        {
          services.proxy-with-credential-manager = {
            enable = true;
            proxyPort = 8080;
            credentialManagerPort = 8081;
          };
        }
      ];
    };
  };
}
```

The module runs the service as a systemd unit with a dynamic system user and a
`StateDirectory` for the credential database.

Options under `services.proxy-with-credential-manager`:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `enable` | bool | `false` | Whether to enable the service |
| `package` | package | this flake's package | The package to install |
| `proxyPort` | port | (required) | Port the proxy server listens on (loopback) |
| `credentialManagerPort` | port | (required) | Port the credential manager API listens on (loopback) |
| `stateDirectory` | str | `"proxy-with-credential-manager"` | systemd `StateDirectory` (under `/var/lib`) holding the credential database |

---

All documentation and `description` fields in this repository are AI-generated.
