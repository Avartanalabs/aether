# Security Policy

AETHER handles your credentials, session tokens, and web browsing data. Ensuring zero unauthorized leakage and ironclad local security is fundamental to our architecture.

## Reporting a Security Vulnerability

If you identify a security issue or vulnerability, please disclose it to us privately:

- **Direct Email**: Write to **security@avartanalabs.com** with `[SECURITY VULNERABILITY]` in the subject.
- **Details to Include**:
  - Detailed description of the vulnerability.
  - Affected components or source paths in `AETHER/`.
  - Step-by-step reproduction steps or proof-of-concept demonstrating the behavior locally.
  - macOS version and architecture (Apple Silicon / Intel).

Please refrain from submitting public issues or pull requests detailing undisclosed vulnerabilities until a patch has been published and released.

## Scope

The following areas are in critical scope:
- Local Keychain storage and credential retrieval (`Vault.swift`, `Passkeys.swift`).
- WebKit extension privilege isolation and CSP boundaries (`Extensions.swift`, `ExtensionShims.swift`).
- Benchmark and IPC domain socket restrictions (`Bench.swift`).
- Content blocker and ad-blocking filter rule enforcement (`Shield.swift`).
- Anti-tracking and network boundary controls.

For non-security bugs, please submit an issue on the issue tracker.
