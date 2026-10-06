import Foundation

/// Tabs shown side by side, sharing one place in the row. The first tab is
/// the pair's place among the others; the rest follow it, next to it.
///
/// Two in 1.0.5, side by side. The shape is a list with an axis so that one
/// above the other, or a third page, needs no other file format later: the
/// file keeps these as they are (see Session.Split).
struct TabSplit: Identifiable, Equatable {
    enum Axis: String, Codable {
        /// Side by side, the first on the left.
        case horizontal
        /// One above the other, the first on top.
        case vertical
    }

    let id: UUID
    /// In the order they are shown.
    var tabs: [Tab.ID]
    var axis: Axis
    /// Each page's share of the stage, in the same order, adding up to 1.
    var sizes: [Double]
    /// The page last focused, to come back to.
    var focused: Tab.ID?

    init(id: UUID = UUID(), tabs: [Tab.ID], axis: Axis = .horizontal,
         sizes: [Double]? = nil, focused: Tab.ID? = nil) {
        self.id = id
        self.tabs = tabs
        self.axis = axis
        self.sizes = TabSplit.even(tabs.count)
        self.focused = focused.flatMap { tabs.contains($0) ? $0 : nil }
        if let sizes, sizes.count == tabs.count { self.sizes = TabSplit.clamp(sizes) }
    }

    init(left: Tab.ID, right: Tab.ID, fraction: Double = 0.5) {
        self.init(tabs: [left, right], sizes: [fraction, 1 - fraction])
    }

    /// The first page: the pair's place in the row.
    var left: Tab.ID { tabs[0] }
    /// The last page.
    var right: Tab.ID { tabs[tabs.count - 1] }

    /// The first page's share, for two pages.
    var fraction: Double {
        get { sizes.first ?? 0.5 }
        set { sizes = TabSplit.clamp([newValue, 1 - newValue]) }
    }

    func contains(_ tab: Tab.ID) -> Bool { tabs.contains(tab) }

    /// The other page of two.
    func partner(of tab: Tab.ID) -> Tab.ID? {
        guard contains(tab) else { return nil }
        return tabs.first { $0 != tab }
    }

    mutating func replace(_ old: Tab.ID, with new: Tab.ID) {
        tabs = tabs.map { $0 == old ? new : $0 }
        if focused == old { focused = new }
    }

    /// No page narrower than a fifth of the stage; shares that add up to 1.
    static func clamp(_ sizes: [Double]) -> [Double] {
        guard sizes.count == 2 else {
            let finite = sizes.map { $0.isFinite && $0 > 0 ? $0 : 1 }
            let total = finite.reduce(0, +)
            return finite.map { $0 / total }
        }
        let first = min(0.8, max(0.2, sizes[0].isFinite ? sizes[0] : 0.5))
        return [first, 1 - first]
    }

    static func even(_ count: Int) -> [Double] {
        Array(repeating: 1 / Double(max(1, count)), count: count)
    }

    /// Calculate pane bounds for multi-panel grid layout
    func layout(in area: CGRect, gutter: CGFloat) -> [Tab.ID: CGRect] {
        guard !tabs.isEmpty else { return [:] }
        if tabs.count == 1 {
            return [tabs[0]: area]
        }
        var result: [Tab.ID: CGRect] = [:]
        if tabs.count == 4 {
            // 2x2 grid layout
            let colWidth = max(0, (area.width - gutter) / 2)
            let rowHeight = max(0, (area.height - gutter) / 2)
            result[tabs[0]] = CGRect(x: area.minX, y: area.minY, width: colWidth, height: rowHeight)
            result[tabs[1]] = CGRect(x: area.minX + colWidth + gutter, y: area.minY, width: colWidth, height: rowHeight)
            result[tabs[2]] = CGRect(x: area.minX, y: area.minY + rowHeight + gutter, width: colWidth, height: rowHeight)
            result[tabs[3]] = CGRect(x: area.minX + colWidth + gutter, y: area.minY + rowHeight + gutter, width: colWidth, height: rowHeight)
            return result
        }

        let count = CGFloat(tabs.count)
        let totalGutters = gutter * (count - 1)
        if axis == .horizontal {
            let availableWidth = max(0, area.width - totalGutters)
            var currentX = area.minX
            for (idx, id) in tabs.enumerated() {
                let share = idx < sizes.count ? CGFloat(sizes[idx]) : (1.0 / count)
                let w = round(availableWidth * share)
                result[id] = CGRect(x: currentX, y: area.minY, width: w, height: area.height)
                currentX += w + gutter
            }
        } else {
            let availableHeight = max(0, area.height - totalGutters)
            var currentY = area.minY
            for (idx, id) in tabs.enumerated() {
                let share = idx < sizes.count ? CGFloat(sizes[idx]) : (1.0 / count)
                let h = round(availableHeight * share)
                result[id] = CGRect(x: area.minX, y: currentY, width: area.width, height: h)
                currentY += h + gutter
            }
        }
        return result
    }

}

extension TabSplit {
    /// Modern spatial multi-pane interactive gutter parameters.
    /// Default interactive gutter width for multi-pane split view (7 pt to accommodate rounded pill handle).
    static let defaultGutter: CGFloat = 7
    /// Pill grab handle dimensions for interactive gutters.
    static let grabHandleWidth: CGFloat = 4
    static let grabHandleHeight: CGFloat = 36
}
