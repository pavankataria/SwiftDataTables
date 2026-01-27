//
//  DataTableColumnOrder.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation

/// Specifies the default sorting order for a column in the data table.
///
/// Use `DataTableColumnOrder` to configure which column should be sorted
/// by default when the table first loads, and in which direction.
///
/// ## Usage
///
/// Set on the configuration before creating the table:
/// ```swift
/// var config = DataTableConfiguration()
/// config.defaultOrdering = DataTableColumnOrder(index: 2, order: .ascending)
///
/// let table = SwiftDataTable(data: data, headerTitles: headers, options: config)
/// ```
///
/// ## Parameters
///
/// - `index`: The zero-based column index to sort by.
/// - `order`: The sort direction (`.ascending` or `.descending`).
///
/// ## Notes
///
/// - If `index` is out of bounds, no default sorting is applied.
/// - If `isColumnSortable` returns `false` for the specified column,
///   the default ordering is ignored.
public struct DataTableColumnOrder: Equatable {

    // MARK: - Properties

    /// The zero-based index of the column to sort by.
    public let index: Int

    /// The direction to sort the column.
    public let order: DataTableSortType

    // MARK: - Initialization

    /// Creates a new column order specification.
    ///
    /// - Parameters:
    ///   - index: The zero-based index of the column to sort by.
    ///   - order: The sort direction (`.ascending`, `.descending`, or `.unspecified`).
    ///
    /// Example:
    /// ```swift
    /// // Sort by the first column in ascending order
    /// let order = DataTableColumnOrder(index: 0, order: .ascending)
    ///
    /// // Sort by the third column in descending order
    /// let order = DataTableColumnOrder(index: 2, order: .descending)
    /// ```
    public init(index: Int, order: DataTableSortType) {
        self.index = index
        self.order = order
    }
}
