//
//  RowMetricsStore.swift
//  SwiftDataTables
//
//  Created as part of Golden Standard Layout System
//

import UIKit

/// Single source of truth for row metrics (heights, Y offsets, content height).
/// Owned by SwiftDataTable; layout reads from it.
final class RowMetricsStore {

    // MARK: - State

    private(set) var rowHeights: [CGFloat] = []
    private(set) var yOffsets: [CGFloat] = []
    private(set) var contentHeight: CGFloat = 0

    // MARK: - Configuration

    var headerHeight: CGFloat = 0
    var interRowSpacing: CGFloat = 0
    var footerHeight: CGFloat = 0

    // MARK: - Queries

    var rowCount: Int { rowHeights.count }

    func heightForRow(_ row: Int) -> CGFloat {
        guard row >= 0 && row < rowHeights.count else { return 0 }
        return rowHeights[row]
    }

    func yOffsetForRow(_ row: Int) -> CGFloat {
        guard row >= 0 && row < yOffsets.count else { return headerHeight }
        return yOffsets[row]
    }

    // MARK: - Mutations

    /// Sets the row count, initializing heights to a default value.
    func setRowCount(_ count: Int, defaultHeight: CGFloat) {
        rowHeights = Array(repeating: defaultHeight, count: count)
        yOffsets = Array(repeating: 0, count: count)
    }

    /// Sets a specific row height directly (used for fixed heights or delegate-provided heights).
    func setHeight(_ height: CGFloat, forRow row: Int) {
        guard row >= 0 && row < rowHeights.count else { return }
        rowHeights[row] = height
    }

    /// Rebuilds all row heights using the provided measurer and recalculates Y offsets.
    /// This is the Phase 1 API - simple full rebuild.
    func rebuildAll(measurer: (Int) -> CGFloat) {
        for row in 0..<rowHeights.count {
            rowHeights[row] = measurer(row)
        }
        rebuildOffsets()
    }

    /// Recalculates Y offsets and content height from current row heights.
    func rebuildOffsets() {
        guard !rowHeights.isEmpty else {
            contentHeight = headerHeight + footerHeight
            return
        }

        var runningY = headerHeight
        for row in 0..<rowHeights.count {
            yOffsets[row] = runningY
            runningY += rowHeights[row] + interRowSpacing
        }
        contentHeight = runningY + footerHeight
    }

    /// Clears all cached data.
    func clear() {
        rowHeights.removeAll()
        yOffsets.removeAll()
        contentHeight = 0
    }

    // MARK: - Binary Search (for visible row lookup)

    /// Finds the row index at or before the given Y position using binary search.
    func rowForYOffset(_ targetY: CGFloat) -> Int {
        guard !yOffsets.isEmpty else { return 0 }

        var low = 0
        var high = yOffsets.count

        while low < high {
            let mid = low + (high - low) / 2
            let rowBottom = yOffsets[mid] + (mid < rowHeights.count ? rowHeights[mid] : 0)
            if rowBottom < targetY {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return max(0, low)
    }
}
