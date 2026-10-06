import SwiftUI

// What's new, once, after an update.
//
// New features start off, so someone who never opens Settings never meets
// them (a reply on X). The first time a newer version opens, a small card
// shows its new switches, each with a line of what it does and the switch
// itself, and — so nothing gets lost — the switches from earlier versions
// that are still off. Nothing else: few words (Drice). Closed, it
// doesn't come back for that version. Not after a fresh install: the welcome
// is for that. Every version's notes are in Settings › About › What's New…
//
// A release edits `toggles` (its new switches, marked with its version),
// `releases` (that it has a card) and `notes` (what it brought).

enum WhatsNew {
    /// A switch the card offers: the same setting as in Settings.
    struct Toggle {
        let title: String
        let detail: String
        /// The version it came in.
        let since: String
        let get: @MainActor (Preferences) -> Bool
        let set: @MainActor (Preferences, Bool) -> Void
    }

    /// A version that has a card.
    struct Release {
        let version: String
    }

    /// Every switch worth meeting, oldest last. The card shows this
    /// version's, and the older ones still off.
    static let toggles: [Toggle] = [
        Toggle(title: "AI on pages", detail: "Summarize a page or ask about it. Choose where it runs in Settings › AI.",
               since: "0.0.1", get: { $0.ai }, set: { $0.ai = $1 }),
        Toggle(title: "Split View", detail: "Two tabs side by side: drag a tab to the edge of a page, or press ⌥⌘N.",
               since: "0.0.1", get: { $0.splitView }, set: { $0.splitView = $1 }),
        Toggle(title: "Search a site from the address field", detail: "The start of a site's name, then Tab: red, Tab, and your words search Reddit.",
               since: "0.0.1", get: { $0.searchesSites }, set: { $0.searchesSites = $1 }),
        Toggle(title: "Start with a fresh window", detail: "Your pinned tabs, and none of last time's others.",
               since: "0.0.1", get: { $0.startsFresh }, set: { $0.startsFresh = $1 }),

        Toggle(title: "Tab groups", detail: "Named sections of tabs. Right-click a tab to start one.",
               since: "0.0.1", get: { $0.usesTabGroups }, set: { $0.usesTabGroups = $1 }),
        Toggle(title: "Sidebar on the right", detail: "The tabs down the right edge of the window.",
               since: "0.0.1", get: { $0.sidebar && $0.sidePosition == .right },
               set: { prefs, on in
                   if on { prefs.sidebar = true }
                   prefs.sidePosition = on ? .right : .left
               }),
        Toggle(title: "Videos wait for a click", detail: "Videos don't start by themselves, even without sound.",
               since: "0.0.1", get: { $0.waitsForPlay }, set: { $0.waitsForPlay = $1 }),
        Toggle(title: "Always show the downloads button", detail: "Your downloads one click away, beside the other buttons.",
               since: "0.0.1", get: { $0.alwaysShowsDownloads }, set: { $0.alwaysShowsDownloads = $1 }),

        Toggle(title: "Spaces", detail: "Separate sets of tabs, each with its own sign-ins. ⌃1–⌃9 to switch.",
               since: "0.0.1", get: { $0.usesSpaces }, set: { $0.usesSpaces = $1 }),
        Toggle(title: "A sidebar that hides", detail: "The page takes the whole window; the tabs come out at the edge.",
               since: "0.0.1", get: { $0.sidebar && $0.sideHides },
               set: { prefs, on in
                   if on { prefs.sidebar = true }
                   prefs.sideHides = on
               }),
        Toggle(title: "Bookmarks bar", detail: "Your bookmarks in a row above the page.",
               since: "0.0.1", get: { $0.bookmarksBar }, set: { $0.bookmarksBar = $1 }),
        Toggle(title: "Float the video when you switch apps", detail: "A playing video follows you out into a small window.",
               since: "0.0.1", get: { $0.floatsAway }, set: { $0.floatsAway = $1 }),
        Toggle(title: "Pages at 120 Hz", detail: "Smoother scrolling and animations on screens that can. Uses more battery.",
               since: "0.0.1", get: { $0.fastPages }, set: { $0.fastPages = $1 }),
        Toggle(title: "Scroll with the middle button", detail: "Click the wheel, then move the mouse to scroll, as on Windows.",
               since: "0.0.1", get: { $0.autoScroll }, set: { $0.autoScroll = $1 }),
    ]

    /// AETHER releases so far added features that are on by default, so no
    /// version has a card yet. The next switch that starts off gets one.
    static let releases: [Release] = []

    /// This version's card, when it has one.
    static var current: Release? { releases.first { $0.version == Updater.version } }

    /// Version strings in order: 1.0.10 after 1.0.9.
    static func older(_ one: String, than other: String) -> Bool {
        let a = one.split(separator: ".").compactMap { Int($0) }
        let b = other.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(a.count, b.count) {
            let x = i < a.count ? a[i] : 0, y = i < b.count ? b[i] : 0
            if x != y { return x < y }
        }
        return false
    }

    private static let seenKey = "whatsnew.seen"

    /// At launch, once: whether the card is due. Not on a fresh install (the
    /// welcome is up, and this version counts as seen), nor in a test world
    /// unless the bench asks; otherwise once per version that has a card.
    @MainActor static func due(prefs: Preferences, welcoming: Bool) -> Bool {
        let store = Store.settings
        guard let current, !Store.testing else { return false }
        if welcoming {
            store.set(current.version, forKey: seenKey)
            return false
        }
        guard store.string(forKey: seenKey) != current.version else { return false }
        store.set(current.version, forKey: seenKey)
        return true
    }

    // MARK: - every version's notes

    /// What a version brought, for Settings › About › What's New…
    struct Notes {
        let version: String
        let date: String
        /// A sentence or two: what the version is about.
        let headline: String
        let new: [String]
        let better: [String]
        let fixed: [String]
    }

    /// Newest first.
    static let notes: [Notes] = [
        Notes(
            version: "0.0.5", date: "6 October 2026",
            headline: "Four panes, and a scroll that follows.",
            new: [
                "Split View goes past a pair: two, three or four pages tile the window (⌥⌘2, ⌥⌘3, ⌥⌘4), each pane with its own tab item, title and favicon.",
                "Drag a tab to a corner: the dock zones show where it will land, and it takes that quadrant.",
                "⌥⌘S locks adjacent panes to one scroll position, with an indicator while it is on.",
            ],
            better: [],
            fixed: []
        ),
        Notes(
            version: "0.0.4", date: "6 October 2026",
            headline: "Dividers you can hold, and a halo round the page you are on.",
            new: [
                "The split divider is an interactive gutter with a floating grab handle, hover and drag states, and a double-click that evens the halves or walks the ratios.",
                "The focused pane wears an ocean-purple halo, so the keyboard and scroll target is never in doubt.",
            ],
            better: [],
            fixed: []
        ),
        Notes(
            version: "0.0.3", date: "6 October 2026",
            headline: "Tabs that sleep, and a quieter interface.",
            new: [
                "Tabs give their memory back after 15 minutes, or sooner under memory pressure, and come back from a snapshot with no white flash.",
                "Pill tabs with a radiant ocean-purple indicator, in the row and down the side.",
                "A floating glass omnibox with acrylic blur, a focus ring, and a badge for TLS, HTTP and local files.",
            ],
            better: [],
            fixed: []
        ),
        Notes(
            version: "0.0.1", date: "6 October 2026",
            headline: "A browser for the Mac with nothing in the way.",
            new: [
                "Native Swift, AppKit and WebKit: one 7 MB app, about 94 MB of memory at cold start, no telemetry and no account.",
                "Split View, pinned tabs, spaces, tab groups, a sidebar, reader mode, picture-in-picture and element hiding.",
                "Ad and tracker rules compiled into WebKit; passwords and passkeys in the macOS Keychain.",
                "Chrome extensions on macOS 15.4 and later.",
                "A local automation socket: scripts and agents can drive tabs over JSON-RPC.",
            ],
            better: [],
            fixed: []
        ),
    ]
}

/// The card: what's new in this version, its switches right there, and
/// the earlier ones still off.
struct WhatsNewCard: View {
    let release: WhatsNew.Release
    @ObservedObject var prefs: Preferences
    let close: () -> Void
    let notes: () -> Void

    /// Read once, as the card opens: a switch turned on here stays in the
    /// list rather than vanishing under the hand.
    @State private var earlier: [WhatsNew.Toggle]?

    private var fresh: [WhatsNew.Toggle] { WhatsNew.toggles.filter { $0.since == release.version } }

    var body: some View {
        Plate("New in Aether \(release.version)", width: 460, close: close) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    rows(fresh)
                    if let earlier, !earlier.isEmpty {
                        Caption("From earlier versions, in case you missed them")
                            .padding(.top, 6)
                        rows(earlier)
                    }
                }
            }
            .frame(maxHeight: 470)
            .fixedSize(horizontal: false, vertical: true)
        } foot: {
            HStack {
                Button(action: notes) {
                    Text("Everything that's new…")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                }
                .buttonStyle(.plain)
                Spacer()
                Pill("Close", filled: true, action: close)
            }
        }
        .onAppear {
            if earlier == nil {
                earlier = WhatsNew.toggles.filter { WhatsNew.older($0.since, than: release.version) && !$0.get(prefs) }
            }
        }
    }

    private func rows(_ toggles: [WhatsNew.Toggle]) -> some View {
        Card {
            ForEach(Array(toggles.enumerated()), id: \.offset) { index, toggle in
                if index > 0 { Rule() }
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(toggle.title)
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.ink)
                        Text(toggle.detail)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Switch(on: Binding(get: { toggle.get(prefs) }, set: { toggle.set(prefs, $0) }))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
        }
    }
}

/// Every version's notes, newest first: Settings › About › What's New…
struct ReleaseNotesPanel: View {
    let close: () -> Void

    var body: some View {
        Plate("What's New", width: 560, close: close) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(WhatsNew.notes, id: \.version) { note in
                        version(note)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
            .frame(maxHeight: 480)
        }
    }

    private func version(_ note: WhatsNew.Notes) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Aether \(note.version)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                if !note.date.isEmpty {
                    Text(note.date)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.faint)
                }
            }
            Text(note.headline)
                .font(.system(size: 13))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            list("New", note.new)
            list("Better", note.better)
            list("Fixed", note.fixed)
        }
    }

    @ViewBuilder
    private func list(_ title: String, _ lines: [String]) -> some View {
        if !lines.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(Palette.muted)
                ForEach(lines, id: \.self) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").foregroundStyle(Palette.faint)
                        Text(line)
                            .foregroundStyle(Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.system(size: 12.5))
                }
            }
        }
    }
}
