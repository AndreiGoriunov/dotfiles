---
description: Use when encountering problems with uv command.
---
 
# uv Troubleshooting
 
## `uv` Command Not Found
 
Install `uv` with the command for the current OS:
 
- Windows: `winget install --id=astral-sh.uv -e`
- macOS with Homebrew: `brew install uv`
 
After installation, open a new terminal and run `uv --version`. If an integrated terminal still cannot find `uv`, restart the terminal's host application to refresh `PATH`.
 
## SSL or Corporate Certificate Errors
 
For certificate errors during Python or dependency installation, make `uv` trust the corporate CA:
 
- If the corporate CA is in the OS certificate store, pass `--system-certs` or set `UV_SYSTEM_CERTS=true`. Older `uv` versions use `--native-tls` or `UV_NATIVE_TLS=true`.
- Otherwise, set `SSL_CERT_FILE` to a PEM-encoded CA bundle. This bundle replaces the default certificates, so it must include every CA that `uv` needs.
 
See the [uv TLS certificates documentation](https://docs.astral.sh/uv/concepts/authentication/certificates/) for details.
 
Use a certificate verification bypass only when explicitly requested, and scope it to the failing host:
 
```shell
uv sync --allow-insecure-host <host>
```
 
This flag disables certificate verification for `<host>`. Do not make the bypass the default or apply it to unrelated hosts.