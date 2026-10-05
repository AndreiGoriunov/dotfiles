---
description: Use when encountering problems with uv command.
---

# UV Troubleshooting

## uv Command Not Found

Check the OS and use the appropriate installation command:

- Windows: `winget install --id=astral-sh.uv -e`
- macOS with Homebrew: `brew install uv`

After installation, open a new terminal and verify `uv --version`. If an
integrated terminal still cannot find uv, restart its host application to
refresh PATH.

## SSL or Corporate Certificate Errors

For certificate errors during Python or dependency installation, configure the
trusted corporate CA using uv's [certificate guidance](https://docs.astral.sh/uv/concepts/authentication/certificates/).

If a temporary bypass is explicitly needed, scope it to the failing host:

```bash
uv sync --allow-insecure-host <host>
```

This disables certificate verification for that host. Do not make it the
default or apply it to unrelated hosts.