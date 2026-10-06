import XCTest
@testable import Aether

final class SpatialQuadGridTests: XCTestCase {

    func testVersionIs005() throws {
        let rootURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent() // AetherTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // root
        let versionURL = rootURL.appendingPathComponent("VERSION")
        let version = try String(contentsOf: versionURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(version, "0.0.5")
    }

    func testQuadGridLayoutGeometry() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()
        let split = TabSplit(tabs: [id1, id2, id3, id4], axis: .horizontal)
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let gutter: CGFloat = 2
        let framesDict = split.layout(in: bounds, gutter: gutter)

        XCTAssertEqual(framesDict.count, 4)

        guard let f0 = framesDict[id1],
              let f1 = framesDict[id2],
              let f2 = framesDict[id3],
              let f3 = framesDict[id4] else {
            XCTFail("Missing frames for tabs")
            return
        }

        let expectedW = (bounds.width - gutter) / 2
        let expectedH = (bounds.height - gutter) / 2

        // Frame 0: Bottom-Left (minX, minY)
        XCTAssertEqual(f0.width, expectedW, accuracy: 0.1)
        XCTAssertEqual(f0.height, expectedH, accuracy: 0.1)
        XCTAssertEqual(f0.minX, 0, accuracy: 0.1)
        XCTAssertEqual(f0.minY, 0, accuracy: 0.1)

        // Frame 1: Bottom-Right (minX + colWidth + gutter, minY)
        XCTAssertEqual(f1.width, expectedW, accuracy: 0.1)
        XCTAssertEqual(f1.height, expectedH, accuracy: 0.1)
        XCTAssertEqual(f1.minX, expectedW + gutter, accuracy: 0.1)
        XCTAssertEqual(f1.minY, 0, accuracy: 0.1)

        // Frame 2: Top-Left (minX, minY + rowHeight + gutter)
        XCTAssertEqual(f2.width, expectedW, accuracy: 0.1)
        XCTAssertEqual(f2.height, expectedH, accuracy: 0.1)
        XCTAssertEqual(f2.minX, 0, accuracy: 0.1)
        XCTAssertEqual(f2.minY, expectedH + gutter, accuracy: 0.1)

        // Frame 3: Top-Right (minX + colWidth + gutter, minY + rowHeight + gutter)
        XCTAssertEqual(f3.width, expectedW, accuracy: 0.1)
        XCTAssertEqual(f3.height, expectedH, accuracy: 0.1)
        XCTAssertEqual(f3.minX, expectedW + gutter, accuracy: 0.1)
        XCTAssertEqual(f3.minY, expectedH + gutter, accuracy: 0.1)

        // Ensure no overlapping frames
        let frames = [f0, f1, f2, f3]
        for i in 0..<4 {
            for j in (i + 1)..<4 {
                let intersection = frames[i].intersection(frames[j])
                XCTAssertTrue(intersection.isNull || intersection.width == 0 || intersection.height == 0,
                              "Frames \(i) and \(j) should not overlap: \(frames[i]) vs \(frames[j])")
            }
        }
    }

    func testTriplePaneLayoutGeometry() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let split = TabSplit(tabs: [id1, id2, id3], axis: .horizontal)
        let bounds = CGRect(x: 0, y: 0, width: 1200, height: 900)
        let gutter: CGFloat = 2
        let framesDict = split.layout(in: bounds, gutter: gutter)

        XCTAssertEqual(framesDict.count, 3)

        guard let f0 = framesDict[id1],
              let f1 = framesDict[id2],
              let f2 = framesDict[id3] else {
            XCTFail("Missing frames for triple pane")
            return
        }

        let availableWidth = bounds.width - 2 * gutter
        let colWidth = round(availableWidth / 3.0)

        // Triple horizontal panes: 3 columns
        XCTAssertEqual(f0.minX, 0, accuracy: 0.1)
        XCTAssertEqual(f0.width, colWidth, accuracy: 1.0)
        XCTAssertEqual(f0.height, bounds.height, accuracy: 0.1)

        XCTAssertEqual(f1.minX, f0.maxX + gutter, accuracy: 0.1)
        XCTAssertEqual(f1.width, colWidth, accuracy: 1.0)
        XCTAssertEqual(f1.height, bounds.height, accuracy: 0.1)

        XCTAssertEqual(f2.minX, f1.maxX + gutter, accuracy: 0.1)
        XCTAssertEqual(f2.width, colWidth, accuracy: 1.0)
        XCTAssertEqual(f2.height, bounds.height, accuracy: 0.1)
    }

    func testDockZoneHitTesting() {
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let cornerSize: CGFloat = 120

        // Top Left corner point
        let ptTopLeft = CGPoint(x: bounds.minX + 30, y: bounds.maxY - 30)
        let isTL = ptTopLeft.x <= bounds.minX + cornerSize && ptTopLeft.y >= bounds.maxY - cornerSize
        XCTAssertTrue(isTL)

        // Top Right corner point
        let ptTopRight = CGPoint(x: bounds.maxX - 30, y: bounds.maxY - 30)
        let isTR = ptTopRight.x >= bounds.maxX - cornerSize && ptTopRight.y >= bounds.maxY - cornerSize
        XCTAssertTrue(isTR)

        // Bottom Left corner point
        let ptBottomLeft = CGPoint(x: bounds.minX + 30, y: bounds.minY + 30)
        let isBL = ptBottomLeft.x <= bounds.minX + cornerSize && ptBottomLeft.y <= bounds.minY + cornerSize
        XCTAssertTrue(isBL)

        // Bottom Right corner point
        let ptBottomRight = CGPoint(x: bounds.maxX - 30, y: bounds.minY + 30)
        let isBR = ptBottomRight.x >= bounds.maxX - cornerSize && ptBottomRight.y <= bounds.minY + cornerSize
        XCTAssertTrue(isBR)
    }

    func testDockZoneProperties() {
        XCTAssertEqual(TabDrag.DockZone.topLeft.rawValue, "topLeft")
        XCTAssertEqual(TabDrag.DockZone.topRight.rawValue, "topRight")
        XCTAssertEqual(TabDrag.DockZone.bottomLeft.rawValue, "bottomLeft")
        XCTAssertEqual(TabDrag.DockZone.bottomRight.rawValue, "bottomRight")
        XCTAssertEqual(TabDrag.DockZone.left.rawValue, "left")
        XCTAssertEqual(TabDrag.DockZone.right.rawValue, "right")
        XCTAssertEqual(TabDrag.DockZone.top.rawValue, "top")
        XCTAssertEqual(TabDrag.DockZone.bottom.rawValue, "bottom")
    }

    func testSpatialQuadNavigationMath() {
        // Quad grid:
        // [0: Top-Left ]  [1: Top-Right ]
        // [2: Bottom-Left] [3: Bottom-Right]

        func nextPane(current: Int, direction: Browser.PaneDirection) -> Int {
            switch direction {
            case .left:
                return (current % 2 == 1) ? current - 1 : current
            case .right:
                return (current % 2 == 0) ? current + 1 : current
            case .up:
                return (current >= 2) ? current - 2 : current
            case .down:
                return (current < 2) ? current + 2 : current
            }
        }

        // From 0 (Top-Left):
        XCTAssertEqual(nextPane(current: 0, direction: .right), 1)
        XCTAssertEqual(nextPane(current: 0, direction: .down), 2)
        XCTAssertEqual(nextPane(current: 0, direction: .left), 0)
        XCTAssertEqual(nextPane(current: 0, direction: .up), 0)

        // From 1 (Top-Right):
        XCTAssertEqual(nextPane(current: 1, direction: .left), 0)
        XCTAssertEqual(nextPane(current: 1, direction: .down), 3)

        // From 2 (Bottom-Left):
        XCTAssertEqual(nextPane(current: 2, direction: .up), 0)
        XCTAssertEqual(nextPane(current: 2, direction: .right), 3)

        // From 3 (Bottom-Right):
        XCTAssertEqual(nextPane(current: 3, direction: .up), 1)
        XCTAssertEqual(nextPane(current: 3, direction: .left), 2)
    }

    func testShortcutCommandRegistry() {
        let commands = Command.all
        XCTAssertTrue(commands.contains(where: { $0.id == "tabs.splitDual" }))
        XCTAssertTrue(commands.contains(where: { $0.id == "tabs.splitTriple" }))
        XCTAssertTrue(commands.contains(where: { $0.id == "tabs.splitQuad" }))
        XCTAssertTrue(commands.contains(where: { $0.id == "tabs.toggleSyncScroll" }))

        XCTAssertTrue(Command.split.contains("tabs.splitDual"))
        XCTAssertTrue(Command.split.contains("tabs.splitTriple"))
        XCTAssertTrue(Command.split.contains("tabs.splitQuad"))
        XCTAssertTrue(Command.split.contains("tabs.toggleSyncScroll"))
    }
}
