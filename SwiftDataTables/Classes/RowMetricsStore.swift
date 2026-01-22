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

    // MARK: - Dirty Tracking (Phase 3)

    /// Rows that need height recomputation
    private var dirtyRows: IndexSet = []

    /// Returns true if any rows are marked dirty
    var hasDirtyRows: Bool { !dirtyRows.isEmpty }

    /// Returns the earliest (lowest index) dirty row, or nil if none
    var earliestDirtyRow: Int? { dirtyRows.min() }

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

    /// Appends a new row with the given height (used for incremental insertions).
    func appendRow(height: CGFloat) {
        rowHeights.append(height)
        yOffsets.append(0) // Will be recalculated by rebuildOffsets
    }

    /// Truncates the store to the given row count (used for incremental deletions).
    func truncateToCount(_ count: Int) {
        guard count < rowHeights.count else { return }
        rowHeights.removeLast(rowHeights.count - count)
        yOffsets.removeLast(yOffsets.count - count)
        // Remove any dirty flags for rows that no longer exist
        dirtyRows = dirtyRows.filteredIndexSet { $0 < count }
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
        dirtyRows.removeAll()
    }

    // MARK: - Dirty Tracking API (Phase 3)

    /// Marks specific rows as needing height recomputation.
    func invalidateRows(_ rows: IndexSet) {
        dirtyRows.formUnion(rows)
    }

    /// Marks all rows as dirty (used when widths change).
    func invalidateAllRows() {
        dirtyRows = IndexSet(integersIn: 0..<rowHeights.count)
    }

    /// Clears all dirty flags after recomputation.
    func clearDirtyFlags() {
        dirtyRows.removeAll()
    }

    // MARK: - Incremental Recompute (Phase 3)

    /// Recomputes heights only for dirty rows, then rebuilds offsets from earliest dirty row.
    /// Returns true if any rows were recomputed.
    @discardableResult
    func recomputeDirtyHeights(measurer: (Int) -> CGFloat) -> Bool {
        guard !dirtyRows.isEmpty else { return false }

        // Measure only dirty rows
        for row in dirtyRows {
            guard row < rowHeights.count else { continue }
            rowHeights[row] = measurer(row)
        }

        // Rebuild offsets from earliest dirty row
        if let earliest = earliestDirtyRow {
            rebuildOffsets(fromRow: earliest)
        }

        clearDirtyFlags()
        return true
    }

    /// Rebuilds Y offsets from the given row to the end (tail update).
    /// More efficient than full rebuild when only later rows need offset adjustment.
    func rebuildOffsets(fromRow startRow: Int) {
        guard !rowHeights.isEmpty else {
            contentHeight = headerHeight + footerHeight
            return
        }

        let safeStart = max(0, min(startRow, rowHeights.count - 1))

        // Calculate starting Y position
        var runningY: CGFloat
        if safeStart == 0 {
            runningY = headerHeight
        } else {
            runningY = yOffsets[safeStart - 1] + rowHeights[safeStart - 1] + interRowSpacing
        }

        // Update offsets from startRow to end
        for row in safeStart..<rowHeights.count {
            yOffsets[row] = runningY
            runningY += rowHeights[row] + interRowSpacing
        }

        contentHeight = runningY + footerHeight
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
