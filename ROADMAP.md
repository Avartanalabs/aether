# AETHER Strategic Roadmap (v0.0.1 — v0.0.9)

AETHER is an independent, keyboard-driven, ultra-lightweight web browser developed and maintained by **Avartana Labs Inc.**

All inquiries, issues, and feature planning are managed here:
- **Repository**: Avartana Labs Organization
- **Live Roadmap & Releases**: [aether.avartanalabs.com/roadmap](https://aether.avartanalabs.com/roadmap)
- **Contact**: hello@avartanalabs.com

---

## Strategic Vision & UI Differentiation

Unlike its minimalist monochrome predecessor, AETHER departs into an unmistakable modern aesthetic:
1. **Ethereal Glass Design System**: Pure light grounds and deep midnight obsidian accented by vibrant ocean azure (`#0D94E8`) and electric royal purple (`#8B5CF6`).
2. **Pill-Based Fluid Geometry**: Translucent rounded floating capsules for tabs, omnibox, and split gutters replacing stark rectangular borders.
3. **Active Focus Halos**: Visual depth cues, subtle ambient glow, and micro-interactions that clarify spatial pane focus.
4. **Native Agentic Architecture**: High-speed JSON-RPC Model Context Protocol (MCP) daemon for autonomous AI agent collaboration.
5. **Ultra-Light Footprint**: Maintaining strict <10 MB app bundle size and sub-100 MB cold RAM usage throughout all releases.

```
v0.0.1 (Clean Foundation) ──► v0.0.2 (Pill Tabs & Hibernation) ──► v0.0.3 (Glass Omnibox & Metal)
                          ──► v0.0.4 (Split Halos & Dividers)    ──► v0.0.5 (2x2 Quad & Dock Zones)
                          ──► v0.0.6 (MCP Hub & @agent Mode)    ──► v0.0.7 (Semantic Visual Search)
                          ──► v0.0.8 (Docked Inspector & HUD)    ──► v0.0.9 (CloudKit Sync & Settings)
```

---

## Detailed Milestone Plan

### [v0.0.1] — Clean Root Foundation & Proprietary Migration
*Status: Completed & Verified · Initial Git Root Commit*

- **Architecture & Foundation**:
  - Zero git history prior to this release; fresh repository root under Avartana Labs.
  - Source tree established in canonical `AETHER/` directory.
  - Bundle identifier `com.avartanalabs.aether`, binary name `Aether`, version `0.0.1`.
  - 100% elimination of legacy company links, update endpoints, and telemetry.
  - Ad-hoc signed universal release bundle built at **7.0 MB** (`build/Aether.app`).
- **Core Stability & Upstream Fixes Merged**:
  - Horizontal caret scrolling in Omnibox and TabBar for long URLs.
  - Direct local POSIX file URL resolution (`/` and `~/`).
  - Real-time window title synchronization to active tab name.
  - Context menu download task retention handler in WebKit delegate.
  - Closed-window retain cycle and event monitor cleanup (`WeakWindow`).
  - Configurable clean tab closure behavior (`newTabAfterLast`).
- **Licensing & Documentation**:
  - Strict commercial [AETHER Proprietary Software License](LICENSE) established.
  - Comprehensive `README.md`, `SECURITY.md`, and `CONTRIBUTING.md`.
  - Real hardware UI screenshots and benchmark metrics collected.
- **UI Baseline**:
  - Pure white ground with dynamic dark mode pairing (`Palette.NS.ground`).
  - Ocean azure and electric purple brand tokens in `Design.swift`.

---

### [v0.0.3] — Dynamic Tab Hibernation, Ergonomic Pill Tabs & Floating Glass Omnibox (Completed October 2026)
*Released: October 6, 2026*

- **Core Capabilities**:
  - [x] **Dynamic Tab Hibernation & Memory Compression**: Shed memory from tabs dormant >15 minutes (or under system memory pressure) by discarding background `WKWebView` WebContent processes while retaining snapshot tokens and navigation state tokens. Zero data loss reconstitution on reactivation.
  - [x] **Snapshot Cover Cache**: Smooth visual reconstitution eliminating white flashes when restoring asleep tabs.
  - [x] **Resumable Download Manager**: Dedicated popover panel (`⇧⌘J`) with pause, resume, file verification, and quarantine attribute handling.
- **UI Transformation**:
  - [x] **Ergonomic Rounded Pill Tabs**: Replaced flat rectangular tabs with floating ergonomic pill tabs (8px corner radius, continuous capsule geometry, 1px subtle border sheen).
  - [x] **Radiant Ocean Accent Indicator**: 2px gradient active indicator bar (`Palette.ocean` to `Palette.purple`) and ambient glow behind active tabs.
  - [x] **Floating Glass Omnibox**: Address bar styled as a floating glass pill with native acrylic blur (`.ultraThinMaterial` + `Palette.ground.opacity(0.72)`), oceanic focus ring, and dual elevation drop shadows.
  - [x] **Security & Protocol Badges**: Integrated color-coded security indicator pill (green TLS padlock, insecure HTTP indicator, local file badge, and system sparkles).
  - [x] **Refined Glass Suggestions Overlay**: Dropdown completion list rendered with glassmorphic cards and keyboard shortcut chips.

---

### [v0.0.4] — Spatial Multi-Pane Dividers & Active Focus Halos
*Target: Q1 2027*

- **Core Capabilities**:
  - **Spatial Split View Persistence**: Save and restore arbitrary multi-pane split view states across workspaces and app restarts.
  - **Keyboard Focus Routing**: Seamless split switching (`⌃⌘←` / `⌃⌘→`) with zero focus loss.
- **UI Transformation**:
  - **Interactive Gutter Handle**: Replace 1px hairline divider with a smooth rounded gutter containing a central pill grab handle.
  - **Active Pane Halo**: Glowing 1.5px ocean-purple accent border surrounding the currently active pane, eliminating ambiguity about keyboard target.
  - **Fluid Split Animations**: Spring-based split pane entry and resizing animations.

---

### [v0.0.5] — Spatial Quad-Grid (2x2) & Visual Dock Zones
*Target: Q1 2027*

- **Core Capabilities**:
  - **2x2 Quadrant Grid**: Support for 3-pane and 4-pane quadrant layouts (`⌥⌘2` dual pane, `⌥⌘3` triple pane, `⌥⌘4` quad grid).
  - **Synchronized Scrolling Mode (`⌥⌘S`)**: Lock scroll positions across adjacent panes for documentation review, side-by-side translation, and UI diffing.
- **UI Transformation**:
  - **Visual Drag-to-Dock Zones**: Semi-transparent ethereal blue drop zones overlaying the viewport when dragging tabs toward window edges or corners.
  - **Mini-Map Status Pill**: Miniature visual layout indicator in the status line showing active split arrangement.

---

### [v0.0.6] — Native Model Context Protocol (MCP) Hub & Autonomous `@agent` Mode
*Target: Q2 2027*

- **Core Capabilities**:
  - **Standard MCP Server Daemon**: High-throughput JSON-RPC 2.0 server supporting stdio and SSE transports for plug-and-play connection with Claude Desktop, Cursor, and Windsurf.
  - **Agent Automation Tools**: Programmatic navigation, DOM querying, JS execution, and screenshot capture.
- **UI Transformation**:
  - **Autonomous `@agent` Omnibox Mode**: Typing `@agent <prompt>` transforms the address bar into an AI command console with inline streaming response pill.
  - **Pulsing Agent Activity Orb**: Subtle breathing ethereal orb in the toolbar indicating live background agent actions.
  - **Slide-Out Agent Drawer**: Non-intrusive collapsible side drawer displaying agent execution thoughts and artifacts.

---

### [v0.0.7] — On-Device Semantic History & Visual Timeline
*Target: Q2 2027*

- **Core Capabilities**:
  - **Apple Neural Engine Embeddings**: Local on-device vector embeddings of browsing history and bookmarks for instant semantic search.
  - **100% Private Vector Index**: Zero cloud calls; all vector computations execute locally on Apple Silicon NPU.
- **UI Transformation**:
  - **Visual History Timeline**: Redesigned History panel (`⌘Y`) featuring timeline view with cached page snapshots and domain favicon clusters.
  - **Semantic Match Highlights**: Search results highlight matching text excerpts with visual relevance scores.

---

### [v0.0.8] — Integrated Dockable Inspector & Developer HUD
*Target: Q3 2027*

- **Core Capabilities**:
  - **Embedded Web Inspector**: Dockable WebKit inspector pane operating within split view layout (eliminating disconnected floating windows).
  - **Network Request Profiler**: Real-time asset load waterfall and CSP violation monitor.
- **UI Transformation**:
  - **Themed Developer Dock**: Inspector styled with Aether's dark obsidian theme and legible monospaced typography.
  - **Heads-Up Display (HUD)**: Optional translucent overlay displaying live FPS, DOM node count, and WebContent process RSS.

---

### [v0.0.9] — Zero-Knowledge CloudKit Sync & Enterprise Profiles
*Target: Q3 2027*

- **Core Capabilities**:
  - **Encrypted iCloud Sync**: End-to-end encrypted synchronization of open tabs, spaces, and bookmarks using user's personal CloudKit account.
  - **Enterprise MDM Configuration**: Support for `.mobileconfig` payloads to lock down enterprise extensions, enforce content blocking, and configure custom proxy routing.
  - **Universal CI/CD Pipeline**: GitHub Actions matrix producing signed and notarized universal DMGs (arm64 + x86_64).
- **UI Transformation**:
  - **Unified macOS Sequoia Settings**: Redesigned preferences window with visual Space icon/color palette customizer.
  - **Cloud Sync Status Indicator**: Elegant sync beacon in sidebar footer showing multi-device sync status.
