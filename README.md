# AETHER

A hyper-lean, keyboard-driven web browser built for macOS. Engineered in pure Swift, AppKit, and WebKit by [Avartana Labs](https://avartanalabs.com).

![AETHER Onboarding & Setup](docs/screenshots/aether_onboarding.png)

<div align="center">
  <b>macOS 14.0+ Sonoma & Sequoia</b> &nbsp;•&nbsp; 
  <b>Universal Apple Silicon & Intel</b> &nbsp;•&nbsp; 
  <b>7.0 MB Binary Footprint</b> &nbsp;•&nbsp; 
  <b>Avartana Labs Proprietary Software</b>
</div>

---

### Why AETHER Exists

Browsers used to be user agents — lightweight tools that retrieved documents and rendered them at 60 frames per second without intruding on the operating system.

Over the last decade, browsers became platforms. They grew multi-gigabyte background processes, embedded ad-attribution telemetry engines, demanded mandatory cloud accounts, and introduced continuous background battery drain on portable Macs.

**AETHER is the antidote.** We stripped away every layer of Chromium bloat, electron wrappers, and cross-platform abstractions. The entire browser compiles into a single 7.0 MB executable that boots in under 180 milliseconds, sips 93 MB of RAM, and respects your hardware.

---

### Architecture & Capabilities (Bento Showcase)

| ⚡ **Sub-100 MB Cold Footprint** | 🛡️ **Zero-Telemetry Core** |
| :--- | :--- |
| **93.6 MB main process RSS at cold boot.** While Chromium browsers spin up dozens of utility, metrics, and GPU processes consuming upwards of 1.2 GB before you type a single URL, AETHER keeps your memory headroom completely untouched for your actual work. | **Not a single tracking ping.** No analytics daemon, no crash-reporting phone-home beacons, no forced account sync. DNS lookups and TLS handshakes happen strictly between your Mac and the servers you intentionally visit. |
| 🪶 **7.0 MB Universal Bundle** | ⌨️ **Keyboard-Centric Velocity** |
| **Pure Swift & AppKit driving system WebKit.** No bundled V8 engine, no Node runtime, no duplicate graphics libraries. Compiled with `-Osize` optimization to maximize L1/L2 instruction cache locality on Apple Silicon. | **Zero mouse dependency required.** Jump across tabs with `⌘K`, split viewports with `⌥⌘N`, navigate splits with `⌃⌘←`/`→`, and trigger distraction-free Reader mode with `⇧⌘R`. |
| 🪟 **Spatial Multi-Split Engine** | 🤖 **Native Model Context Protocol (MCP)** |
| **Side-by-side split browsing without window clutter.** Proportional drag gutters, live focus indicators, and persistent split layout restoration across reboots and spaces. | **Built for agentic workflows.** First-class headless Unix domain socket interface (`./bench`) exposing high-speed JSON-RPC automation for local LLMs, MCP servers, and developer tooling. |

---

### Interface & Visuals

| Horizontal Tab Strip | Vertical Sidebar Mode |
| :---: | :---: |
| ![AETHER Tab Strip](docs/screenshots/aether_tab_strip.png) | ![AETHER Sidebar](docs/screenshots/aether_sidebar_column.png) |
| *Compact, distraction-free top bar* | *Organized spaces, pins, and tab hierarchy* |

| Active Browser Viewport | What's New & System Integrity |
| :---: | :---: |
| ![AETHER Window with Web Page](docs/screenshots/aether_window_with_page.png) | ![AETHER What's New](docs/screenshots/aether_whats_new.png) |
| *Fluid native WebKit rendering engine* | *Transparent release logs and settings control* |

---

## Performance Baselines

Measurements taken directly on host Apple Silicon (macOS 14.x / 15.x):

| Metric | AETHER (Directly Measured) | Google Chrome | Arc Browser | Safari |
| :--- | :--- | :--- | :--- | :--- |
| **App Bundle Size** | **7.0 MB** | ~420 MB | ~510 MB | System Framework |
| **Mach-O Binary Size** | **5.58 MB** (`__TEXT`) | ~180 MB | ~195 MB | Frameworks |
| **Cold Start Main Process RSS** | **93.6 MB** | ~450 MB | ~850 MB | ~140 MB |
| **Total System RSS (with WebKit XPC)** | **119.4 MB** | ~920 MB | ~1.4 GB | ~280 MB |
| **Unit Test Execution (47 tests)**| **16.21s (100% pass)**| N/A | N/A | N/A |
| **Cold DOM Find-on-Page Latency** | **362 ms** | ~450 ms | ~620 ms | ~340 ms |
| **Split-View Model IPC Roundtrip** | **< 1 ms** | N/A | ~45 ms | N/A |
| **Release Build Time (`-Osize`)** | **83.11s** | Hours | N/A | N/A |

---

## Core Capabilities

- **Unified Omnibox**: Intelligent search, URL resolution, and direct POSIX local file navigation (`/path/to/file` or `~/Documents`).
- **Spatial Multi-Split View**: Effortless side-by-side split tiling with proportional gutter resizing, keyboard navigation (`⌃⌘←` / `⌃⌘→`), and persistent session restoration across restarts.
- **Native Model Context Protocol (MCP)**: First-class headless scripting and automation bridge via Unix domain socket (`./bench`), allowing external LLMs and developer tools to drive tabs and inspect DOM nodes with zero UI impact.
- **Zero-Cost Content Blocker**: Third-party trackers and ad networks are blocked at the WebKit network rule level before requests leave your Mac.
- **Permanent Element Hiding (`⇧⌘H`)**: Hide unwanted elements, popups, and banners permanently with zero flicker.
- **Native Keychain Vault & Passkeys**: Secure storage directly integrated into macOS Keychain.
- **Picture-in-Picture Video (`⇧⌘P`)**: Detachable floating video overlay with gesture and corner docking.

---

## Keyboard Shortcuts

| Shortcut | Action | Shortcut | Action |
| :--- | :--- | :--- | :--- |
| `⌘L` | Focus Address Field | `⌘T` | New Tab |
| `⌘W` | Close Tab | `⇧⌘T` | Reopen Closed Tab |
| `⌘K` | Quick Tab Switcher | `⇧⌘S` | Toggle Top Strip / Sidebar |
| `⌥⌘N` | Split Current Tab | `⌃⌘←` / `⌃⌘→` | Switch Active Split Pane |
| `⇧⌘R` | Reader Mode | `⇧⌘P` | Picture-in-Picture Video |
| `⇧⌘H` | Hide Element on Page | `⌥⌘L` | Password Manager |

---

## Building AETHER

### Prerequisites
- macOS 14.0 or later
- Xcode 16+ / Swift 6.0+ toolchain

### Build Commands
```bash
# Build binary straight from SwiftPM
swift build

# Build production ad-hoc signed Aether.app bundle
./build.sh

# Run full test suite
swift test

# Run split view end-to-end integration tests
python3 Tests/split_view.py
```

The resulting application is placed at `build/Aether.app`.

---

## Proprietary License

Copyright © 2026 Avartana Labs Inc. All rights reserved.

This software and associated documentation files are the proprietary and confidential property of Avartana Labs Inc. Unauthorized copying, distribution, modification, public display, reverse engineering, or decompilation of this software, via any medium, is strictly prohibited without prior written permission from Avartana Labs Inc.

For licensing inquiries and commercial access, visit [avartanalabs.com](https://avartanalabs.com) or contact `licensing@avartanalabs.com`.
