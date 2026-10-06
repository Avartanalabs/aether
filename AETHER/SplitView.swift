import AppKit
import SwiftUI

/// The page area while Split View is on: the AppKit stage that holds the
/// pages (see PaneStage.swift), and over each page what SwiftUI draws there —
/// its cover, its trouble, the field, the find bar — placed from where the
/// stage says the pages are.
struct SplitStage: View {
    @ObservedObject var browser: Browser
    @ObservedObject private var drag = TabDrag.shared
    /// Where each page on screen is, as the stage last said.
    @State private var frames: [Tab.ID: CGRect] = [:]
    /// The page under the pointer, with two up.
    @State private var hovered: Tab.ID?

    var body: some View {
        let split = browser.activeSplit
        let shown: [Tab] = split.map { pair in pair.tabs.compactMap { id in browser.tabs.first { $0.id == id } } }
            ?? browser.active.map { [$0] } ?? []
        ZStack(alignment: .topLeading) {
            PaneStageView(
                tabs: shown, split: split, focused: browser.activeID,
                commit: { id, sizes in browser.setSplitFraction(id, fraction: sizes[0]) },
                focus: { tab in browser.focusPane(tab) },
                frames: { frames = $0 },
                action: { action in
                    switch action {
                    case .swap: browser.swapSplit()
                    case .even: browser.evenSplit()
                    case .separate: if let tab = browser.active { browser.detachSplit(tab) }
                    case .closeBoth: browser.closeSplit()
                    }
                },
                hover: { hovered = $0 }
            )
            ForEach(shown) { tab in
                if let frame = frames[tab.id] {
                    PaneLayers(browser: browser, tab: tab, paired: shown.count > 1, width: frame.width,
                               hovered: hovered == tab.id)
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                }
            }
            if let preview = drag.preview, preview.browserID == ObjectIdentifier(browser) {
                VisualDockZones(hoveredZone: preview.zone)
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                SplitDropPreview(preview: preview, tabs: browser.tabs)
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            } else if drag.isDragging {
                VisualDockZones(hoveredZone: nil)
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            if browser.syncScrollEnabled, browser.activeSplit != nil {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Synchronized Scrolling Active")
                        .font(.system(size: 11.5, weight: .medium))
                }
                .foregroundStyle(Palette.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Palette.accent.opacity(0.4), lineWidth: 1))
                .shadow(color: Palette.accent.opacity(0.18), radius: 8, x: 0, y: 3)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(Motion.quick, value: drag.preview)
        .animation(Motion.quick, value: drag.isDragging)
        .animation(Motion.quick, value: browser.syncScrollEnabled)
    }
}

/// What is drawn over one page of the stage. Nothing here takes a click
/// meant for the page: where it draws nothing, the page is under the pointer.
private struct PaneLayers: View {
    @ObservedObject var browser: Browser
    @ObservedObject var tab: Tab
    let paired: Bool
    let width: CGFloat
    var hovered = false

    private var focused: Bool { browser.activeID == tab.id }

    /// Whose page the other one is, said on the page itself: under the
    /// pointer, or all the time while the tabs are folded away and nothing
    /// else on screen says so.
    @ViewBuilder
    private var whose: some View {
        if paired, !focused, hovered || browser.folded, let host = tab.address?.host(), !tab.isBlank {
            Text(host.hasPrefix("www.") ? String(host.dropFirst(4)) : host)
                .font(.system(size: 11.5))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .frame(height: 22)
                .background(Palette.ground, in: Capsule())
                .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
                .padding(10)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }

    var body: some View {
        ZStack {
            // The page's own layers — its cover, the floating video's line,
            // its trouble, the history disc — without the page, which is
            // the stage's.
            Page(tab: tab, holdsPage: false)

            if browser.fieldShowing && focused {
                Omnibox(browser: browser, over: !tab.isBlank, fitted: true)
                    .transition(.scale(scale: 0.97).combined(with: .opacity))
            }

            // An empty page of a pair: the field, and the tabs already open,
            // to bring one in. Gone while something is typed, when the field's
            // own list is there.
            if paired, tab.isBlank, browser.typed.isEmpty {
                OpenTabs(browser: browser, blank: tab)
                    .transition(.opacity)
            }

            // What this page asked, over this page alone.
            if let question = browser.paneQuestions.first(where: { $0.tab == tab.id }) {
                PaneQuestionCard(browser: browser, tab: tab, question: question, width: width)
                    .id(question.id)
                    .transition(.opacity)
            }
        }
        // Gone to another page: what the last one asked goes unanswered no
        // longer.
        .onChange(of: tab.committed) { _, _ in browser.dropQuestions(for: tab.id) }
        .animation(Motion.quick, value: browser.paneQuestions.map(\.id))
        .overlay {
            // Over the page the link is on, focused or not.
            if browser.prefs.showsLinks {
                LinkBubble(status: browser.linkStatus, page: paired ? tab.built : nil)
            }
        }
        .overlay(alignment: .topTrailing) {
            if browser.finding, focused {
                FindBar(browser: browser, availableWidth: width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .clipped()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .topLeading) {
            if let asked = browser.suggesting, asked.tab == tab.id {
                AccountList(browser: browser, asked: asked)
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) { whose }
        .animation(Motion.quick, value: hovered)
        .background { SplitDropZone(browser: browser, tab: tab, kind: .stage) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(tab.label.isEmpty ? "New Tab" : tab.label)
        .accessibilityHint(paired && !focused ? "Click to focus this page" : "")
        .accessibilityAction(named: "Focus page") {
            if paired { browser.focusPane(tab) }
        }
        .clipped()
        .animation(Motion.quick, value: browser.suggesting)
    }
}

/// Subtle ethereal dock zones rendered when dragging tabs towards screen corners or edges.
struct VisualDockZones: View {
    var hoveredZone: TabDrag.DockZone? = nil

    var body: some View {
        GeometryReader { proxy in
            let cornerSize: CGFloat = max(110, min(proxy.size.width, proxy.size.height) * 0.22)
            ZStack {
                // Top-Left Corner Dock Pad
                dockPad(icon: "square.grid.2x2", title: "Quad Top-Left", active: hoveredZone == .topLeft)
                    .frame(width: cornerSize, height: cornerSize)
                    .position(x: cornerSize / 2 + 12, y: cornerSize / 2 + 12)

                // Top-Right Corner Dock Pad
                dockPad(icon: "square.grid.2x2", title: "Quad Top-Right", active: hoveredZone == .topRight)
                    .frame(width: cornerSize, height: cornerSize)
                    .position(x: proxy.size.width - cornerSize / 2 - 12, y: cornerSize / 2 + 12)

                // Bottom-Left Corner Dock Pad
                dockPad(icon: "square.grid.2x2", title: "Quad Bottom-Left", active: hoveredZone == .bottomLeft)
                    .frame(width: cornerSize, height: cornerSize)
                    .position(x: cornerSize / 2 + 12, y: proxy.size.height - cornerSize / 2 - 12)

                // Bottom-Right Corner Dock Pad
                dockPad(icon: "square.grid.2x2", title: "Quad Bottom-Right", active: hoveredZone == .bottomRight)
                    .frame(width: cornerSize, height: cornerSize)
                    .position(x: proxy.size.width - cornerSize / 2 - 12, y: proxy.size.height - cornerSize / 2 - 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func dockPad(icon: String, title: String, active: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: active
                            ? [Palette.accent.opacity(0.22), Palette.purple.opacity(0.14)]
                            : [Palette.accent.opacity(0.05), Palette.ground.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    active ? Palette.accent.opacity(0.65) : Palette.hairline.opacity(0.4),
                    lineWidth: active ? 1.5 : 1
                )
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(active ? Palette.accent : Palette.muted)
                Text(title)
                    .font(.system(size: 10, weight: active ? .semibold : .regular))
                    .foregroundStyle(active ? Palette.accent : Palette.muted)
            }
        }
        .shadow(color: active ? Palette.accent.opacity(0.15) : .clear, radius: 8, x: 0, y: 2)
    }
}

private struct SplitDropPreview: View {
    let preview: TabDrag.Preview
    let tabs: [Tab]

    private var target: Tab? { tabs.first { $0.id == preview.targetID } }
    private var carried: String {
        let label = tabs.first { $0.id == preview.sourceID }?.label ?? ""
        return label.isEmpty ? "New Tab" : label
    }

    var body: some View {
        Group {
            if preview.zone.isCorner {
                quadGrid
            } else if preview.zone == .top || preview.zone == .bottom {
                verticalSplit
            } else {
                horizontalSplit
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.ground.opacity(0.12))
    }

    private var horizontalSplit: some View {
        HStack(spacing: 4) {
            pane(title: preview.side == .left ? carried : target?.label ?? "Page",
                 icon: "rectangle.split.2x1",
                 subtitle: preview.side == .left ? "Docked Tab" : "Existing Pane",
                 proposed: preview.side == .left)
            pane(title: preview.side == .right ? carried : target?.label ?? "Page",
                 icon: "rectangle.split.2x1",
                 subtitle: preview.side == .right ? "Docked Tab" : "Existing Pane",
                 proposed: preview.side == .right)
        }
    }

    private var verticalSplit: some View {
        VStack(spacing: 4) {
            pane(title: preview.zone == .top ? carried : target?.label ?? "Page",
                 icon: "rectangle.split.1x2",
                 subtitle: preview.zone == .top ? "Docked Tab" : "Existing Pane",
                 proposed: preview.zone == .top)
            pane(title: preview.zone == .bottom ? carried : target?.label ?? "Page",
                 icon: "rectangle.split.1x2",
                 subtitle: preview.zone == .bottom ? "Docked Tab" : "Existing Pane",
                 proposed: preview.zone == .bottom)
        }
    }

    private var quadGrid: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                quadPane(zone: .topLeft, label: "Top-Left")
                quadPane(zone: .topRight, label: "Top-Right")
            }
            HStack(spacing: 4) {
                quadPane(zone: .bottomLeft, label: "Bottom-Left")
                quadPane(zone: .bottomRight, label: "Bottom-Right")
            }
        }
    }

    private func quadPane(zone: TabDrag.DockZone, label: String) -> some View {
        let proposed = preview.zone == zone
        let title = proposed ? carried : (target?.label ?? label)
        return pane(title: title,
                    icon: "square.grid.2x2",
                    subtitle: proposed ? "Quad Dock Zone" : label,
                    proposed: proposed)
    }

    private func pane(title: String, icon: String, subtitle: String, proposed: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    proposed
                        ? LinearGradient(colors: [Palette.accent.opacity(0.18), Palette.purple.opacity(0.10)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Palette.ground.opacity(0.42), Palette.ground.opacity(0.35)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    proposed ? Palette.accent.opacity(0.65) : Palette.hairline.opacity(0.35),
                    lineWidth: proposed ? 1.5 : 1
                )
                .padding(2)
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: proposed ? .semibold : .regular))
                    .foregroundStyle(proposed ? Palette.accent : Palette.muted)
                Text(title.isEmpty ? "New Tab" : title)
                    .font(.system(size: 13, weight: proposed ? .medium : .regular))
                    .foregroundStyle(Palette.ink.opacity(proposed ? 0.90 : 0.50))
                    .lineLimit(1)
                    .padding(.horizontal, 16)
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(Palette.muted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// The open tabs an empty page of a pair can take, most recently used
/// first. A click brings one in; the empty page goes.
private struct OpenTabs: View {
    @ObservedObject var browser: Browser
    let blank: Tab

    private var candidates: [Tab] {
        let pair = browser.split(for: blank)
        return browser.tabs
            .filter { tab in
                tab.id != blank.id && pair?.contains(tab.id) != true && !tab.bench
                    && !tab.isBlank && tab.shy == blank.shy
            }
            .sorted { $0.touched > $1.touched }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        let list = candidates
        GeometryReader { geo in
            if !list.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Or bring in an open tab")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Palette.muted)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 4)
                    ForEach(list) { tab in
                        OpenTabRow(tab: tab) { browser.fill(blank, with: tab) }
                    }
                }
                // As wide as the field, its rows' text under the field's.
                .padding(.horizontal, 12)
                .frame(width: min(Metrics.fieldWidth, max(0, geo.size.width - 28)), alignment: .leading)
                .frame(maxWidth: .infinity)
                // Under the field, which stands 60 points above the middle.
                .offset(y: geo.size.height / 2 + 10)
            }
        }
    }
}

private struct OpenTabRow: View {
    @ObservedObject var tab: Tab
    let bring: () -> Void
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 8) {
            Mark(icon: tab.icon, letter: tab.monogram, size: 15)
                .frame(width: 15, height: 15)
            Text(tab.label.isEmpty ? "New Tab" : tab.label)
                .font(.system(size: 12.5))
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(hovering ? Palette.ink : Palette.ink.opacity(0.75))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(hovering ? Palette.hover : .clear))
        .contentShape(Rectangle())
        .onTapGesture(perform: bring)
        .onHover { hovering = $0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Bring this tab into the split")
    }
}

/// alert(), confirm() or prompt() from a page of the pair, over that page
/// only: the page dims, the other one goes on working. Named for the site
/// that asks — the asking frame's own — and plain, so nothing on it passes
/// for Search's. It takes no keys by itself: typing meant for the other page
/// stays there, and a prompt's field gets the keys when it is clicked, which
/// also focuses the page. For its first half second it takes no click, so
/// one already on its way can't land on OK.
private struct PaneQuestionCard: View {
    @ObservedObject var browser: Browser
    let tab: Tab
    let question: PaneQuestion
    let width: CGFloat

    @State private var text = ""
    @State private var ready = false

    private var prompting: Bool { if case .prompt = question.kind { return true } else { return false } }

    var body: some View {
        ZStack(alignment: .top) {
            // The page under it, out of reach until it is answered.
            Rectangle()
                .fill(Palette.ground.opacity(0.62))
                .contentShape(Rectangle())
                .onTapGesture { browser.focusPane(tab) }
            VStack(alignment: .leading, spacing: 10) {
                Text(question.host.isEmpty ? "This page says" : question.host)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                ScrollView {
                    Text(question.message)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.ink)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
                .fixedSize(horizontal: false, vertical: true)
                if prompting {
                    TextField("", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))
                        .onSubmit { if ready { answer(true) } }
                }
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    if question.kind != .alert {
                        choice("Cancel", strong: false) { answer(false) }
                    }
                    choice("OK", strong: true) { answer(true) }
                }
                .padding(.top, 2)
            }
            .padding(18)
            .frame(width: min(380, max(0, width - 32)))
            .background(Palette.ground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
            .shadow(color: .black.opacity(0.14), radius: 18, y: 6)
            .simultaneousGesture(TapGesture().onEnded { browser.focusPane(tab) })
            .padding(.top, 56)
        }
        .onAppear {
            if case .prompt(let given) = question.kind { text = given }
            let wait = max(0, 0.5 - Date().timeIntervalSince(question.asked))
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) { ready = true }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(question.host.isEmpty ? "This page" : question.host) asks")
    }

    private func answer(_ ok: Bool) {
        browser.answer(question, ok: ok, text: prompting ? text : nil)
    }

    private func choice(_ title: String, strong: Bool, act: @escaping () -> Void) -> some View {
        Button(action: act) {
            Text(title)
                .font(.system(size: 12.5, weight: strong ? .medium : .regular))
                .foregroundStyle(strong ? Palette.ground : Palette.ink)
                .padding(.horizontal, 14)
                .frame(height: 26)
                .background(strong ? Palette.ink : Palette.ink.opacity(0.07), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!ready)
        .opacity(ready ? 1 : 0.5)
    }
}
