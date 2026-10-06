import SwiftUI
import AppKit

// Aether Design System — Crafted by AvartanaLabs
//
// Primary canvas: Pure white ground with deep contrast and maximum visual clarity.
// Secondary accent: Luminous ocean and purple hues that illuminate focus states,
// live tabs, and interactive surfaces.
//
// Every colour is an appearance-aware pair resolving dynamically for light/dark
// modes without polluting caller logic.
enum Palette {
    static let ground = Color(nsColor: NS.ground)
    static let ink = Color(nsColor: NS.ink)             // high-contrast text & glyphs
    static let muted = Color(nsColor: NS.muted)         // secondary captions & icons
    static let faint = Color(nsColor: NS.faint)         // subtle borders & disabled states
    static let hairline = Color(nsColor: NS.hairline)   // precision dividers
    static let wash = Color(nsColor: NS.wash)           // active tab surface
    /// The live pin: stands out with an ocean-purple ethereal glow.
    static let pinLive = Color(nsColor: NS.pinLive)
    static let hover = Color(nsColor: NS.hover)         // hover highlights
    
    // Aether Brand Colors: Secondary Ocean & Purple Hues
    static let accent = Color(nsColor: NS.accent)       // primary brand secondary accent
    static let ocean = Color(nsColor: NS.ocean)         // deep ocean azure
    static let purple = Color(nsColor: NS.purple)       // royal electric purple
    static let accentFaint = Color(nsColor: NS.accentFaint) // soft brand wash

    /// Connection security status indicators
    static let safe = Color(nsColor: NS.safe)           // secure TLS / verified
    static let unsafe = Color(nsColor: NS.unsafe)       // insecure HTTP warning

    /// AppKit representations for window framing, titlebars, and text rendering.
    enum NS {
        // Primary: Pure white ground for light mode, deep obsidian for dark
        static let ground = pair(1.0, 0.08)
        static let ink = pair(0.09, 0.94)
        static let muted = pair(0.52, 0.58)
        static let faint = pair(0.85, 0.28)
        static let hairline = pair(0.92, 0.18)

        // Secondary: Ocean & Purple Hue Tokens
        // Primary brand secondary: Vibrant ocean-purple indigo
        static let accent = tint(light: (0.36, 0.38, 0.94), dark: (0.58, 0.60, 1.00))
        // Ocean hue: Deep radiant azure
        static let ocean = tint(light: (0.05, 0.58, 0.88), dark: (0.22, 0.72, 0.98))
        // Purple hue: Ethereal royal purple
        static let purple = tint(light: (0.52, 0.32, 0.92), dark: (0.68, 0.52, 0.98))
        // Faint wash for selections and focus halos
        static let accentFaint = tint(light: (0.94, 0.95, 1.00), dark: (0.16, 0.17, 0.28))

        // Active tab wash: White with whisper of ethereal ocean tint
        static let wash = tint(light: (0.965, 0.975, 1.00), dark: (0.13, 0.14, 0.22))
        // Live pin: Ethereal ocean-purple highlight
        static let pinLive = tint(light: (0.92, 0.93, 0.99), dark: (0.20, 0.21, 0.32))
        // Hover: Soft oceanic aura
        static let hover = tint(light: (0.975, 0.982, 1.00), dark: (0.15, 0.16, 0.24))

        /// Resting window controls
        static let resting = pair(0.80, 0.30)
        static let safe = tint(light: (0.08, 0.50, 0.24), dark: (0.29, 0.87, 0.50))
        static let unsafe = tint(light: (0.71, 0.33, 0.04), dark: (0.98, 0.75, 0.14))

        private static func tint(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) -> NSColor {
            NSColor(name: nil) { appearance in
                let c = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
                return NSColor(srgbRed: c.0, green: c.1, blue: c.2, alpha: 1)
            }
        }

        private static func pair(_ light: CGFloat, _ dark: CGFloat) -> NSColor {
            NSColor(name: nil) { appearance in
                let dim = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                return NSColor(white: dim ? dark : light, alpha: 1)
            }
        }
    }
}

/// Light, dark, or the Mac's own — the one choice that colours everything.
enum Look: String, CaseIterable, Identifiable {
    case light, dark, system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    /// What the app is told to be. Nothing, for "system": the app then
    /// follows the Mac, and changes with it.
    var appearance: NSAppearance? {
        switch self {
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        case .system: return nil
        }
    }

    /// Set on the app rather than on the window, so every panel, alert and
    /// sheet — and every page, which follows the window it is in — agrees.
    func apply() {
        let wanted = appearance
        DispatchQueue.main.async {
            guard NSApp.appearance !== wanted, NSApp.appearance?.name != wanted?.name else { return }
            NSApp.appearance = wanted
        }
    }
}

enum Metrics {
    /// The tab strip. The window's title bar is grown to match it so the
    /// traffic lights come down with the tabs — otherwise giving the row room
    /// to breathe just leaves it sitting below three buttons it used to line
    /// up with.
    static let strip: CGFloat = 52
    /// Where the first tab starts. The traffic lights run from 19 to 79 —
    /// measured, not guessed — so this leaves them the same air on their right
    /// that the window gives them on their left.
    static let lights: CGFloat = 100
    /// Back, forward and reload, at the far end of the row beside the
    /// bookmarks: three doors and the air before the next one.
    static let helm: CGFloat = 3 * 26 + 2 * 2 + 8
    /// The same three doors again, in the sidebar, where they sit right of
    /// the lights instead. The column already has 10 of horizontal padding
    /// of its own before this even starts, so this is the lights' own edge
    /// (79) less that padding, plus a sliver of air — not the full breathing
    /// room a tab row gets, because the sidebar's minimum width doesn't have
    /// it to give.
    static let sideLights: CGFloat = 72
    /// The band left at the top when there is no strip: just enough for the
    /// traffic lights to sit in, and nothing else.
    static let bare: CGFloat = 34
    /// Tabs are a fixed width rather than the width of their titles, so the
    /// cross always lands in the same place and the row never rearranges
    /// itself while you read it. They give way when there are too many:
    /// narrower than tabTitled they show their site's mark alone, and they
    /// stop at tabMinWidth, the mark and its air. Past that the row scrolls,
    /// inside its own edges.
    static let tabWidth: CGFloat = 186
    static let tabTitled: CGFloat = 80
    static let tabMinWidth: CGFloat = 36
    static let tabGap: CGFloat = 2
    /// A pinned tab is a square the height of the row, holding one letter.
    static let pinWidth: CGFloat = 30
    /// The square at the end of the row that opens a new page.
    static let plusWidth: CGFloat = 30
    /// The address field, in both the places it shows up.
    static let fieldWidth: CGFloat = 560
    /// The column of titles down the left, in the way that has one.
    static let side: CGFloat = 232
    static let sideMin: CGFloat = 176
    static let sideMax: CGFloat = 440
}

enum Motion {
    /// Whether interface transitions should be immediate, following the
    /// Mac's own accessibility setting.
    static var reduced: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    static var glide: Animation? {
        reduced ? nil : .spring(response: 0.34, dampingFraction: 0.82)
    }

    static var settle: Animation? {
        reduced ? nil : .spring(response: 0.30, dampingFraction: 0.86)
    }

    static var quick: Animation? {
        reduced ? nil : .easeOut(duration: 0.14)
    }
}

/// Aether Logomark — An aerodynamic continuous infinity/aether glyph
/// rendered as a pure vector across all device resolutions.
struct Logomark: Shape {
    /// Vector canvas: 608 × 276
    static let canvas = CGSize(width: 608, height: 276)

    /// Aether continuous flow glyph: Smooth outer loop with dual optical cutouts
    private static let data = "M138 30 C78 30 30 78 30 138 C30 198 78 246 138 246 C210 246 260 190 304 138 C348 86 398 30 470 30 C530 30 578 78 578 138 C578 198 530 246 470 246 C398 246 348 190 304 138 C260 86 210 30 138 30 Z M138 72 C190 72 230 110 268 138 C230 166 190 204 138 204 C100 204 72 176 72 138 C72 100 100 72 138 72 Z M470 72 C508 72 536 100 536 138 C536 176 508 204 470 204 C418 204 378 166 340 138 C378 110 418 72 470 72 Z"

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width / Logomark.canvas.width, rect.height / Logomark.canvas.height)
        let ox = rect.midX - Logomark.canvas.width * scale / 2
        let oy = rect.midY - Logomark.canvas.height * scale / 2
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x * scale, y: oy + y * scale) }
        var path = Path()
        var last = CGPoint.zero
        var start = CGPoint.zero
        for (c, n) in Logomark.commands {
            switch c {
            case "M": last = CGPoint(x: n[0], y: n[1]); start = last; path.move(to: pt(n[0], n[1]))
            case "L": last = CGPoint(x: n[0], y: n[1]); path.addLine(to: pt(n[0], n[1]))
            case "H": last.x = n[0]; path.addLine(to: pt(last.x, last.y))
            case "V": last.y = n[0]; path.addLine(to: pt(last.x, last.y))
            case "C":
                var k = 0
                while k + 5 < n.count {
                    path.addCurve(to: pt(n[k + 4], n[k + 5]), control1: pt(n[k], n[k + 1]), control2: pt(n[k + 2], n[k + 3]))
                    last = CGPoint(x: n[k + 4], y: n[k + 5])
                    k += 6
                }
            case "Z": path.closeSubpath(); last = start
            default: break
            }
        }
        return path
    }

    private static let commands: [(Character, [CGFloat])] = {
        var out: [(Character, [CGFloat])] = []
        var current: Character?
        var numbers: [CGFloat] = []
        var token = ""
        func flush() {
            if !token.isEmpty, let v = Double(token) { numbers.append(CGFloat(v)) }
            token = ""
        }
        for ch in data {
            if "MLHVCZ".contains(ch) {
                flush()
                if let current { out.append((current, numbers)) }
                current = ch
                numbers = []
            } else if ch == " " || ch == "," {
                flush()
            } else if ch == "-" && !token.isEmpty {
                flush()
                token = "-"
            } else {
                token.append(ch)
            }
        }
        flush()
        if let current { out.append((current, numbers)) }
        return out
    }()
}

/// Wrong address, said without a dialog: the field shivers and stops.
struct Shake: GeometryEffect {
    var travel: CGFloat

    var animatableData: CGFloat {
        get { travel }
        set { travel = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard !Motion.reduced else { return ProjectionTransform(.identity) }
        let decay = 1 - travel
        return ProjectionTransform(
            CGAffineTransform(translationX: sin(travel * .pi * 6) * 7 * decay, y: 0)
        )
    }
}
