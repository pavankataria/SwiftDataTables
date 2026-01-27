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

/// An optional delegate for further customisation. Default values will be used retrieved from the SwiftDataTableConfiguration file. This will can be overridden and passed into the SwiftDataTable constructor incase you wish not to use the delegate.
@MainActor @objc public protocol SwiftDataTableDelegate: AnyObject {
    
    /// Fired when a cell is selected.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - indexPath: the index path of the row selected
    @objc optional func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)

    /// Fired when a cell has been deselected
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - indexPath: the index path of the row deselected
    @objc optional func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)
    
    /// Specify custom heights for specific rows. A row height of 0 is valid and will be used.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index of the row to specify a custom height for.
    /// - Returns: the desired height for the given row index
    @objc optional func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat
    
    /// Specify custom widths for columns. This method once implemented overrides the automatic width calculation for remaining columns and therefor widths for all columns must be given. This behaviour may change so that custom widths on a single column basis can be given with the automatic width calculation behaviour applied for the remaining columns.
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index of the column to specify the width for
    /// - Returns: the desired width for the given column index
    @objc optional func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat
    
    /// Column Width scaling. If set to true and the column's total width is smaller than the content size then the width of each column will be scaled proprtionately to fill the frame of the table. Otherwise an automatic calculated width size will be used by processing the data within each column.
    /// Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to scale to fill the frame of the table
    @objc optional func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Header floating. If set to true headers can float and remain in view during scroll. Otherwise if set to false the header will be fixed at the top and scroll off view along with the content.
    /// Defaults to true
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section header views.
    @objc optional func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Footer floating. If set to true footers can float and remain in view during scroll. Otherwise if set to false the footer will be fixed at the top and scroll off view along with the content.
    /// Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section footer views.
    @objc optional func shouldSectionFootersFloat(in dataTable: SwiftDataTable) -> Bool
    
    
    /// Search View floating. If set to true the search view can float and remain in view during scroll. Otherwise if set to false the search view will be fixed at the top and scroll off view along with the content.
    //  Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section footer views.
    @objc optional func shouldSearchHeaderFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Disable search view. Hide search view. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the search should be hidden
    @objc optional func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool
    
    /// The height of the section footer. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the section footer
    @objc optional func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat
    
    /// The height of the section header. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the section header
    @objc optional func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// The height of the search view. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the search view
    @objc optional func heightForSearchView(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// Height of the inter row spacing. Defaults to 1.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the inter row spacing
    @objc optional func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// Control the display of the vertical scroll bar. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the vertical scroll bars should be shown.
    @objc optional func shouldShowVerticalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the display of the horizontal scroll bar. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the horizontal scroll bars should be shown.
    @objc optional func shouldShowHorizontalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the background color for cells in rows intersecting with a column that's highlighted.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - at: the row index to set the background color
    /// - Returns: the background colour to make the highlighted row
    @objc optional func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor
    
    /// Control the background color for an unhighlighted row.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - at: the row index to set the background color
    /// - Returns: the background colour to make the unhighlighted row
    @objc optional func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor
    
    /// Return the number of fixed columns
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the columns and number of them to be fixed
    @objc optional func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType
    
    
    /// Return `true` to support RTL layouts by flipping horizontal scroll on `CollectionViewFlowLayout`, if the current interface direction is RTL.
    ///
    /// Note: This will only effect the horizontal scroll direction if the current `userInterfaceLayoutDirection` is `.rightToLeft`.
    ///
    /// Default value: `true`.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: `true` to flip horizontal scroll in RTL layouts.
    @objc optional func shouldSupportRightToLeftInterfaceDirection(in dataTable: SwiftDataTable) -> Bool
}

extension SwiftDataTableDelegate {
    
    //    func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor? {
    //        return nil
    //    }
    //    func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor? {
    //        return nil
    //    }
}
