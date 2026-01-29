//
//  SwiftDataTableDataSourceAndDelegate.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/06/2018.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// Data source protocol for providing dynamic content to a SwiftDataTable.
///
/// - Important: This protocol is deprecated in favor of the direct data pattern.
///   Use ``SwiftDataTable/init(data:headerTitles:options:frame:)`` and
///   ``SwiftDataTable/setData(_:animatingDifferences:completion:)`` instead.
///
/// ## Migration Guide
///
/// **Before (DataSource pattern):**
/// ```swift
/// class MyViewController: SwiftDataTableDataSource {
///     var items: [Item] = []
///
///     func numberOfRows(in: SwiftDataTable) -> Int { items.count }
///     func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: Int) -> DataTableRow {
///         [.string(items[index].name), .int(items[index].age)]
///     }
///     // ... more protocol methods
///
///     func refresh() {
///         dataTable.reload()  // No animation, resets scroll
///     }
/// }
/// ```
///
/// **After (Direct data pattern):**
/// ```swift
/// class MyViewController {
///     var items: [Item] = []
///
///     func setupTable() {
///         let data = items.map { [DataTableValueType.string($0.name), .int($0.age)] }
///         dataTable = SwiftDataTable(data: data, headerTitles: ["Name", "Age"])
///     }
///
///     func refresh() {
///         let data = items.map { [DataTableValueType.string($0.name), .int($0.age)] }
///         dataTable.setData(data, animatingDifferences: true)  // Animated diffing!
///     }
/// }
/// ```
///
/// **Or use the type-safe Typed API:**
/// ```swift
/// let columns = [
///     DataTableColumn<Item>("Name", \.name),
///     DataTableColumn<Item>("Age", \.age)
/// ]
/// dataTable = SwiftDataTable(data: items, columns: columns)
///
/// // Update with automatic diffing:
/// dataTable.setData(items, columns: columns, animatingDifferences: true)
/// ```
///
/// ## Benefits of Migration
///
/// - **Animated updates**: Automatic row insertion/deletion animations
/// - **Simpler code**: No protocol conformance required
/// - **Type safety**: Optional typed API with `DataTableColumn`
/// - **Scroll preservation**: Updates preserve scroll position
///
/// - SeeAlso: ``SwiftDataTable/setData(_:animatingDifferences:completion:)``
@available(*, deprecated, message: "Use direct data pattern with init(data:headerTitles:) and setData(_:animatingDifferences:) instead. See documentation for migration guide.")
@MainActor
public protocol SwiftDataTableDataSource: AnyObject {
    
    /// The number of columns to display
    ///
    /// - Parameter in: SwiftDataTable
    /// - Returns: the number of columns
    func numberOfColumns(in: SwiftDataTable) -> Int
    
    /// Return the total number of rows that will be displayed in the table
    ///
    /// - Parameter in: SwiftDataTable
    /// - Returns: retuthe number of rows.
    func numberOfRows(in: SwiftDataTable) -> Int
    
    
    /// Return the data for the given row
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index position of the row wishing to be displayed
    /// - Returns: return an array of the DataTableValueType type so the row can be processed and displayed.
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType]
    
    /// The header title for the column position to be displayed
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - columnIndex: The column index of the header title at a specific column index
    /// - Returns: the title of the column header.
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String
}

/// Delegate protocol for responding to user interactions and customizing SwiftDataTable behavior.
///
/// All methods have default empty implementations via protocol extension, so you only need
/// to implement the methods you care about.
///
/// ## Example
///
/// ```swift
/// class MyViewController: UIViewController, SwiftDataTableDelegate {
///     func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
///         print("Selected row: \(indexPath.item)")
///     }
///
///     func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {
///         print("Tapped header: \(columnIndex)")
///     }
/// }
/// ```
///
/// - Note: Most customization is now done via ``DataTableConfiguration`` at initialization time.
///   The delegate is primarily for responding to user interactions.
@MainActor public protocol SwiftDataTableDelegate: AnyObject {

    // MARK: - Selection Events

    /// Called when a cell is selected.
    ///
    /// - Parameters:
    ///   - dataTable: The data table that was interacted with
    ///   - indexPath: The index path of the selected row
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)

    /// Called when a cell has been deselected.
    ///
    /// - Parameters:
    ///   - dataTable: The data table that was interacted with
    ///   - indexPath: The index path of the deselected row
    func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)

    // MARK: - Header/Footer Tap Events

    /// Called when a column header is tapped.
    ///
    /// This is called regardless of whether sorting occurs. Use `isColumnSortable`
    /// on `DataTableConfiguration` to control sorting behavior per column.
    ///
    /// - Parameters:
    ///   - dataTable: The data table that was interacted with
    ///   - columnIndex: The index of the tapped column header
    func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int)

    /// Called when a column footer is tapped.
    ///
    /// - Parameters:
    ///   - dataTable: The data table that was interacted with
    ///   - columnIndex: The index of the tapped column footer
    func dataTable(_ dataTable: SwiftDataTable, didTapFooterAt columnIndex: Int)

    // MARK: - Row Heights

    /// Specify custom heights for specific rows.
    ///
    /// Return `nil` to use the default row height from configuration.
    /// A row height of 0 is valid and will be used if returned.
    ///
    /// - Parameters:
    ///   - dataTable: The data table requesting the height
    ///   - index: The index of the row
    /// - Returns: The desired height for the row, or `nil` to use the default
    func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat?

    // MARK: - Column Widths

    /// Specify custom widths for columns.
    ///
    /// Return `nil` to use automatic width calculation for this column.
    ///
    /// - Note: If you return a non-nil value for any column, you should provide widths
    ///   for all columns. This behavior may change in future versions to support
    ///   per-column customization with automatic calculation for the rest.
    ///
    /// - Parameters:
    ///   - dataTable: The data table requesting the width
    ///   - index: The index of the column
    /// - Returns: The desired width for the column, or `nil` for automatic calculation
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat?

    // MARK: - Layout Behavior

    /// Whether column widths should scale to fill the frame.
    ///
    /// If `true` and the columns' total width is smaller than the frame, each column
    /// width will be scaled proportionately to fill the table. Otherwise, automatic
    /// calculated widths are used.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to scale to fill, `nil` to use configuration default
    func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool?

    /// Whether section headers should float during scroll.
    ///
    /// If `true`, headers remain visible during scroll. If `false`, they scroll
    /// off with the content.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to float headers, `nil` to use configuration default
    func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool?

    /// Whether section footers should float during scroll.
    ///
    /// If `true`, footers remain visible during scroll. If `false`, they scroll
    /// off with the content.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to float footers, `nil` to use configuration default
    func shouldSectionFootersFloat(in dataTable: SwiftDataTable) -> Bool?

    /// Whether the search header should float during scroll.
    ///
    /// If `true`, the search view remains visible during scroll. If `false`, it
    /// scrolls off with the content.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to float search header, `nil` to use configuration default
    func shouldSearchHeaderFloat(in dataTable: SwiftDataTable) -> Bool?

    /// Whether to show the search section.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to show search, `nil` to use configuration default
    func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool?

    // MARK: - Section Heights

    /// The height of the section footer.
    ///
    /// - Parameter dataTable: The data table requesting the height
    /// - Returns: The footer height, or `nil` to use configuration default (44)
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat?

    /// The height of the section header.
    ///
    /// - Parameter dataTable: The data table requesting the height
    /// - Returns: The header height, or `nil` to use configuration default (44)
    func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat?

    /// The height of the search view.
    ///
    /// - Parameter dataTable: The data table requesting the height
    /// - Returns: The search view height, or `nil` to use configuration default (44)
    func heightForSearchView(in dataTable: SwiftDataTable) -> CGFloat?

    /// The height of spacing between rows.
    ///
    /// - Parameter dataTable: The data table requesting the height
    /// - Returns: The inter-row spacing, or `nil` to use configuration default (1)
    func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat?

    // MARK: - Scroll Bars

    /// Whether to show vertical scroll bars.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to show, `nil` to use configuration default (true)
    func shouldShowVerticalScrollBars(in dataTable: SwiftDataTable) -> Bool?

    /// Whether to show horizontal scroll bars.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to show, `nil` to use configuration default (true)
    func shouldShowHorizontalScrollBars(in dataTable: SwiftDataTable) -> Bool?

    // MARK: - Row Colors (Deprecated)

    /// The background color for highlighted rows.
    ///
    /// - Important: Use ``DataTableConfiguration/defaultCellConfiguration`` instead
    ///   to set `cell.backgroundColor` based on the `isHighlighted` parameter.
    ///
    /// - Parameters:
    ///   - dataTable: The data table requesting the color
    ///   - at: The row index
    /// - Returns: The background color, or `nil` to use default
    @available(*, deprecated, message: "Use DataTableConfiguration.defaultCellConfiguration to set cell.backgroundColor instead.")
    func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor?

    /// The background color for unhighlighted rows.
    ///
    /// - Important: Use ``DataTableConfiguration/defaultCellConfiguration`` instead
    ///   to set `cell.backgroundColor` based on the `indexPath` parameter.
    ///
    /// - Parameters:
    ///   - dataTable: The data table requesting the color
    ///   - at: The row index
    /// - Returns: The background color, or `nil` to use default
    @available(*, deprecated, message: "Use DataTableConfiguration.defaultCellConfiguration to set cell.backgroundColor instead.")
    func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor?

    // MARK: - Fixed Columns

    /// The fixed column configuration.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: The fixed column type, or `nil` to use configuration default
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType?

    // MARK: - RTL Support

    /// Whether to support right-to-left interface direction.
    ///
    /// When `true` and the current interface direction is RTL, the horizontal
    /// scroll direction will be flipped on the collection view flow layout.
    ///
    /// - Parameter dataTable: The data table requesting this setting
    /// - Returns: `true` to support RTL, `nil` to use configuration default (true)
    func shouldSupportRightToLeftInterfaceDirection(in dataTable: SwiftDataTable) -> Bool?
}

// MARK: - Default Implementations

public extension SwiftDataTableDelegate {

    // Selection events - no-op by default
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {}
    func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {}

    // Header/footer taps - no-op by default
    func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {}
    func dataTable(_ dataTable: SwiftDataTable, didTapFooterAt columnIndex: Int) {}

    // Row/column sizing - nil means use configuration defaults
    func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat? { nil }
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat? { nil }

    // Layout behavior - nil means use configuration defaults
    func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool? { nil }
    func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool? { nil }
    func shouldSectionFootersFloat(in dataTable: SwiftDataTable) -> Bool? { nil }
    func shouldSearchHeaderFloat(in dataTable: SwiftDataTable) -> Bool? { nil }
    func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool? { nil }

    // Heights - nil means use configuration defaults
    func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat? { nil }
    func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat? { nil }
    func heightForSearchView(in dataTable: SwiftDataTable) -> CGFloat? { nil }
    func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat? { nil }

    // Scroll bars - nil means use configuration defaults
    func shouldShowVerticalScrollBars(in dataTable: SwiftDataTable) -> Bool? { nil }
    func shouldShowHorizontalScrollBars(in dataTable: SwiftDataTable) -> Bool? { nil }

    // Deprecated row colors - nil means use configuration defaults
    func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor? { nil }
    func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor? { nil }

    // Fixed columns - nil means use configuration defaults
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType? { nil }

    // RTL support - nil means use configuration defaults
    func shouldSupportRightToLeftInterfaceDirection(in dataTable: SwiftDataTable) -> Bool? { nil }
}
