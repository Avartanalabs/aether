# Contributing to AETHER

AETHER is developed and maintained by Avartana Labs Inc. as a proprietary, privacy-first macOS browser.

## Proprietary Licensing & Contributor Terms

By contributing to this repository, you acknowledge and agree that:
1. All contributions, including source code, documentation, assets, and tests, will become the intellectual property of or be licensed exclusively to Avartana Labs Inc. under our proprietary terms.
2. The code in this repository is licensed under the [AETHER Proprietary Software License](LICENSE). No public redistribution, sublicensing, or unauthorized copying is permitted.

## Contribution Workflow

Before writing large feature sets:
1. Open an issue describing the proposed change, rationale, and UX impact.
2. Maintain our core architectural pillars:
   - **Zero bloat**: App bundle must remain ultra-compact (<10 MB).
   - **Zero telemetry**: Never introduce telemetry, cloud tracking, or external analytics endpoints.
   - **Native macOS first**: Utilize AppKit, SwiftUI, and WebKit without third-party frameworks.
   - **Test-backed**: All additions must pass existing unit (`swift test`) and integration (`Tests/split_view.py`) suites with zero warnings.

## Reporting Bugs

Open an issue specifying:
- Action taken, expected behavior, and actual outcome.
- macOS version and hardware configuration.
- Local logs if applicable (located at `~/Library/Application Support/Aether/crash.log`).
