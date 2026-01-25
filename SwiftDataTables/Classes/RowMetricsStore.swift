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

    /// Returns a copy of the current dirty rows set.
    var currentDirtyRows: IndexSet { dirtyRows }

    // MARK: - Estimated Height Tracking (Phase 5 - Large-Scale Mode)

    /// Tracks which rows have been measured vs using estimated heights.
    /// In large-scale mode, rows start as estimated and are measured lazily.
    private var measuredRows: IndexSet = []

    /// Returns true if the given row has been measured (vs using estimated height).
    func isRowMeasured(_ row: Int) -> Bool {
        measuredRows.contains(row)
    }

    /// Returns the set of rows that are still using estimated heights.
    var estimatedRows: IndexSet {
        IndexSet(0..<rowHeights.count).subtracting(measuredRows)
    }

    /// Returns the number of measured rows.
    var measuredRowCount: Int { measuredRows.count }

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
    /// In large-scale mode, rows start as estimated (unmeasured).
    func setRowCount(_ count: Int, defaultHeight: CGFloat, allMeasured: Bool = true) {
        rowHeights = Array(repeating: defaultHeight, count: count)
        yOffsets = Array(repeating: 0, count: count)
        if allMeasured {
            measuredRows = IndexSet(integersIn: 0..<count)
        } else {
            measuredRows.removeAll()
        }
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
        // Remove measured flags for rows that no longer exist
        measuredRows = measuredRows.filteredIndexSet { $0 < count }
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
        measuredRows.removeAll()
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

    // MARK: - Lazy Measurement API (Phase 5 - Large-Scale Mode)

    /// Marks a row as measured and updates its height.
    /// Used in large-scale mode when a row is measured lazily.
    func markRowMeasured(_ row: Int, height: CGFloat) {
        guard row >= 0 && row < rowHeights.count else { return }
        rowHeights[row] = height
        measuredRows.insert(row)
    }

    /// Returns unmeasured rows within the given range (for prefetch window).
    func unmeasuredRowsInRange(_ range: Range<Int>) -> IndexSet {
        let validRange = max(0, range.lowerBound)..<min(rowHeights.count, range.upperBound)
        return IndexSet(validRange).subtracting(measuredRows)
    }

    /// Measures rows in the given range and updates offsets.
    /// Returns true if any rows were measured, false if all were already measured.
    @discardableResult
    func measureRowsInRange(_ range: Range<Int>, measurer: (Int) -> CGFloat) -> Bool {
        let unmeasured = unmeasuredRowsInRange(range)
        guard !unmeasured.isEmpty else { return false }

        var earliestMeasured: Int?
        for row in unmeasured {
            rowHeights[row] = measurer(row)
            measuredRows.insert(row)
            if earliestMeasured == nil || row < earliestMeasured! {
                earliestMeasured = row
            }
        }

        // Rebuild offsets from the earliest newly measured row
        if let earliest = earliestMeasured {
            rebuildOffsets(fromRow: earliest)
        }

        return true
    }

    /// Resets all rows to estimated (unmeasured) state with the given estimated height.
    /// Used when switching to large-scale mode or when data changes.
    func resetToEstimated(estimatedHeight: CGFloat) {
        for i in 0..<rowHeights.count {
            rowHeights[i] = estimatedHeight
        }
        measuredRows.removeAll()
        rebuildOffsets()
    }

    /// Marks specific rows as unmeasured and resets their height to estimated.
    /// Used in large-scale mode when content changes require re-measurement.
    /// Returns the earliest unmeasured row for offset rebuilding.
    @discardableResult
    func markRowsUnmeasured(_ rows: IndexSet, estimatedHeight: CGFloat) -> Int? {
        guard !rows.isEmpty else { return nil }

        var earliestUnmeasured: Int?
        for row in rows {
            guard row >= 0 && row < rowHeights.count else { continue }
            rowHeights[row] = estimatedHeight
            measuredRows.remove(row)
            if earliestUnmeasured == nil || row < earliestUnmeasured! {
                earliestUnmeasured = row
            }
        }

        // Rebuild offsets from earliest unmeasured row
        if let earliest = earliestUnmeasured {
            rebuildOffsets(fromRow: earliest)
        }

        return earliestUnmeasured
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
