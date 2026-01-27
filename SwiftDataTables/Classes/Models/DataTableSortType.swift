//
//  DataTableSortType.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// Represents the sorting state of a column in the data table.
///
/// `DataTableSortType` defines both the visual indicator shown in column headers
/// and the actual sort direction applied to data. Each column maintains its own
/// sort type, which updates when users tap the header.
///
/// ## Sort Cycle
///
/// When a sortable column header is tapped, the sort type cycles:
/// 1. `.unspecified` → `.ascending` → `.descending` → `.ascending` → ...
///
/// The `.hidden` state is special and does not participate in cycling.
///
/// ## Usage
///
/// ```swift
/// // Check if a column is currently sorted
/// if headerViewModel.sortType != .unspecified {
///     print("Column is sorted: \(headerViewModel.sortType)")
/// }
///
/// // Configure default ordering
/// config.defaultOrdering = DataTableColumnOrder(index: 0, order: .ascending)
/// ```
public enum DataTableSortType: String {

    /// Column sorting is disabled; no sort indicator is shown.
    ///
    /// This state is set when `isColumnSortable` returns `false` for a column.
    /// Tapping the header has no effect when in this state.
    case hidden

    /// Column is sortable but not currently being used for sorting.
    ///
    /// The sort indicator shows a neutral state (typically both arrows).
    /// This is the default state for sortable columns.
    case unspecified

    /// Column is sorted in ascending order (A→Z, 0→9, oldest→newest).
    ///
    /// The sort indicator shows an upward arrow.
    case ascending

    /// Column is sorted in descending order (Z→A, 9→0, newest→oldest).
    ///
    /// The sort indicator shows a downward arrow.
    case descending
}

// MARK: - State Transitions

extension DataTableSortType {

    /// Toggles to the next sort state in the cycle.
    ///
    /// The cycle is: `.unspecified` → `.ascending` → `.descending` → `.ascending` → ...
    ///
    /// The `.hidden` state cannot be toggled and remains unchanged.
    mutating func toggle() {
        switch self {
        case .hidden:
            break
        case .unspecified:
            self = .ascending
        case .ascending:
            self = .descending
        case .descending:
            self = .ascending
        }
    }

    /// Resets the sort state to unspecified.
    ///
    /// Used when another column becomes the active sort column,
    /// to clear this column's sort indicator.
    ///
    /// The `.hidden` state cannot be reset and remains unchanged.
    mutating func toggleToDefault() {
        switch self {
        case .hidden:
            break
        default:
            self = .unspecified
        }
    }
}
