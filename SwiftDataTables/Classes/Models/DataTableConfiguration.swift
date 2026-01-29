//
//  DataTableConfiguration.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Type Aliases

/// Callback for customising the default DataCell appearance.
///
/// Use this callback to modify font, text colour, background colour, or other properties
/// of the default cell without implementing a full custom cell provider.
///
/// - Parameters:
///   - cell: The `DataCell` instance to configure. Access `cell.dataLabel` to modify
///     font, text color, alignment, and other label properties.
///   - value: The `DataTableValueType` being displayed in this cell.
///   - indexPath: The cell's position where `section` is the column index and `item` is the row index.
///   - isHighlighted: `true` if the cell is in a highlighted (sorted) column, `false` otherwise.
///
/// ## Example
///
/// ```swift
/// config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
///     // Custom font
///     cell.dataLabel.font = UIFont(name: "Avenir-Medium", size: 14)
///
///     // Conditional text colour based on value
///     if let number = value.doubleValue, number < 0 {
///         cell.dataLabel.textColor = .systemRed
///     } else {
///         cell.dataLabel.textColor = .label
///     }
///
///     // Alternating row colors
///     cell.backgroundColor = indexPath.item % 2 == 0 ? .systemGray6 : .systemBackground
/// }
/// ```
public typealias DefaultCellConfiguration = @MainActor (
    _ cell: DataCell,
    _ value: DataTableValueType,
    _ indexPath: IndexPath,
    _ isHighlighted: Bool
) -> Void

/// Central configuration object for customizing SwiftDataTable appearance and behavior.
///
/// `DataTableConfiguration` provides comprehensive control over every aspect of the
/// data table, from visual styling to interaction behavior. Create a configuration,
/// modify the desired properties, and pass it when initializing your data table.
///
/// ## Basic Usage
///
/// ```swift
/// var config = DataTableConfiguration()
/// config.shouldShowSearchSection = true
/// config.heightForSectionHeader = 50
/// config.defaultOrdering = DataTableColumnOrder(index: 0, order: .ascending)
///
/// let table = SwiftDataTable(data: myData, headerTitles: headers, options: config)
/// ```
///
/// ## Configuration Categories
///
/// ### Layout & Sizing
/// - `heightForSectionHeader`, `heightForSectionFooter`, `heightForSearchView`
/// - `heightOfInterRowSpacing`, `rowHeightMode`, `textLayout`
/// - `columnWidthMode`, `minColumnWidth`, `maxColumnWidth`
///
/// ### Visibility
/// - `shouldShowFooter`, `shouldShowSearchSection`
/// - `shouldShowVerticalScrollBars`, `shouldShowHorizontalScrollBars`
/// - `shouldShowHeaderSortingIndicator`, `shouldShowFooterSortingIndicator`
///
/// ### Floating Behavior
/// - `shouldSectionHeadersFloat`, `shouldSectionFootersFloat`
/// - `shouldSearchHeaderFloat`
///
/// ### Sorting
/// - `defaultOrdering`, `isColumnSortable`
/// - `shouldFooterTriggerSorting`, `sortArrowTintColor`
///
/// ### Colors
/// - `highlightedAlternatingRowColors`, `unhighlightedAlternatingRowColors`
///
/// ### Advanced
/// - `fixedColumns`, `cellSizingMode`, `columnWidthModeProvider`
/// - `lockColumnWidthsAfterFirstLayout`, `shouldSupportRightToLeftInterfaceDirection`
public struct DataTableConfiguration {

    // MARK: - Static Defaults

    /// Default average character width used for text-based column width estimation.
    ///
    /// This value (7.0 points) approximates the average width of a character
    /// in the system font, used when calculating column widths based on content.
    public static let defaultAverageCharacterWidth: CGFloat = 7.0

    /// Default column width mode using estimated text width calculation.
    ///
    /// Uses the estimated average strategy with `defaultAverageCharacterWidth`.
    public static let defaultColumnWidthMode: DataTableColumnWidthMode = .fitContentText(
        strategy: .estimatedAverage(averageCharWidth: DataTableConfiguration.defaultAverageCharacterWidth)
    )

    // MARK: - Sorting

    /// Default column and direction for initial sorting.
    ///
    /// When set, the table displays sorted by this column on initial load.
    /// If the specified column is not sortable (per `isColumnSortable`),
    /// this ordering is ignored.
    ///
    /// ```swift
    /// config.defaultOrdering = DataTableColumnOrder(index: 2, order: .descending)
    /// ```
    public var defaultOrdering: DataTableColumnOrder? = nil

    /// Controls whether a column can be sorted by user interaction.
    ///
    /// When a column is not sortable:
    /// - The sort indicator is hidden
    /// - Tapping the header does nothing
    ///
    /// If `nil`, all columns are sortable (default behavior).
    ///
    /// ```swift
    /// // Disable sorting on the "Actions" column (index 5)
    /// config.isColumnSortable = { $0 != 5 }
    ///
    /// // Only allow sorting on specific columns
    /// config.isColumnSortable = { [0, 2, 4].contains($0) }
    /// ```
    public var isColumnSortable: ((Int) -> Bool)? = nil

    /// Controls whether sorting indicators are shown in column headers.
    ///
    /// When `false`, the sort indicator is hidden and header text takes
    /// the full width. Sorting functionality still works when tapping headers.
    ///
    /// Default: `true`
    public var shouldShowHeaderSortingIndicator: Bool = true

    /// Controls whether sorting indicators are shown in column footers.
    ///
    /// When `true`, footer cells display the same sort indicator as headers.
    ///
    /// Default: `false`
    public var shouldShowFooterSortingIndicator: Bool = false

    /// Controls whether tapping a footer cell triggers sorting.
    ///
    /// When `true`, tapping a footer cell sorts by that column,
    /// behaving identically to tapping the header.
    ///
    /// Default: `false`
    public var shouldFooterTriggerSorting: Bool = false

    /// Tint color for the sort direction arrow icons.
    ///
    /// Applied to both ascending and descending sort indicators
    /// in headers and footers (when visible).
    ///
    /// Default: `.tintColor` (system default)
    public var sortArrowTintColor: UIColor = .tintColor

    // MARK: - Heights

    /// Height of the column footer section in points.
    ///
    /// The footer mirrors the header, displaying column titles at the
    /// bottom of the table. Set to 0 to minimize (use `shouldShowFooter`
    /// to hide completely).
    ///
    /// Default: 44 points
    public var heightForSectionFooter: CGFloat = 44

    /// Height of the column header section in points.
    ///
    /// Headers display column titles and sort indicators.
    ///
    /// Default: 44 points
    public var heightForSectionHeader: CGFloat = 44

    /// Height of the search bar section in points.
    ///
    /// Only applies when `shouldShowSearchSection` is `true`.
    ///
    /// Default: 60 points
    public var heightForSearchView: CGFloat = 60

    /// Vertical spacing between rows in points.
    ///
    /// Creates visual separation between data rows.
    ///
    /// Default: 1 point
    public var heightOfInterRowSpacing: CGFloat = 1

    // MARK: - Visibility

    /// Whether to display the footer section.
    ///
    /// The footer mirrors the header at the bottom of the table.
    ///
    /// Default: `true`
    public var shouldShowFooter: Bool = true

    /// Whether to display the search section.
    ///
    /// When `true`, shows a search bar for filtering table content.
    ///
    /// Default: `true`
    public var shouldShowSearchSection: Bool = true

    /// Whether to show the vertical scroll indicator.
    ///
    /// Default: `true`
    public var shouldShowVerticalScrollBars: Bool = true

    /// Whether to show the horizontal scroll indicator.
    ///
    /// Default: `false`
    public var shouldShowHorizontalScrollBars: Bool = false

    // MARK: - Floating Behavior

    /// Whether the search header floats above content during scroll.
    ///
    /// When `true`, the search bar remains visible at the top of the
    /// view while scrolling. When `false`, it scrolls with content.
    ///
    /// Default: `false`
    public var shouldSearchHeaderFloat: Bool = false

    /// Whether section footers float during scroll.
    ///
    /// When `true`, the footer remains visible at the bottom of the
    /// view while scrolling.
    ///
    /// Default: `true`
    public var shouldSectionFootersFloat: Bool = true

    /// Whether section headers float during scroll.
    ///
    /// When `true`, the column header remains visible at the top
    /// of the view while scrolling.
    ///
    /// Default: `true`
    public var shouldSectionHeadersFloat: Bool = true

    // MARK: - Column Widths

    /// Whether column widths scale proportionally to fill the frame.
    ///
    /// When `true` and total column width is less than the table width,
    /// columns are scaled proportionally to fill available space.
    /// When `false`, columns maintain their calculated widths.
    ///
    /// Default: `true`
    public var shouldContentWidthScaleToFillFrame: Bool = true

    /// Default width calculation mode for all columns.
    ///
    /// Controls how column widths are determined. Override per-column
    /// using `columnWidthModeProvider`.
    ///
    /// Default: `.fitContentText(strategy: .estimatedAverage(averageCharWidth: 7.0))`
    public var columnWidthMode: DataTableColumnWidthMode = DataTableConfiguration.defaultColumnWidthMode

    /// Minimum width for any column in points.
    ///
    /// Columns will never be narrower than this value regardless
    /// of content or scaling.
    ///
    /// Default: 70 points
    public var minColumnWidth: CGFloat = 70

    /// Maximum width for any column in points.
    ///
    /// When set, columns will never be wider than this value.
    /// When `nil`, there is no maximum constraint.
    ///
    /// Default: `nil`
    public var maxColumnWidth: CGFloat? = nil

    /// Per-column width mode provider.
    ///
    /// Returns a custom width mode for specific columns, or `nil` to
    /// use the default `columnWidthMode`.
    ///
    /// ```swift
    /// config.columnWidthModeProvider = { columnIndex in
    ///     switch columnIndex {
    ///     case 0: return .fixed(width: 80)  // ID column
    ///     case 5: return .fixed(width: 120) // Actions column
    ///     default: return nil  // Use default
    ///     }
    /// }
    /// ```
    public var columnWidthModeProvider: ((Int) -> DataTableColumnWidthMode?)? = nil

    /// Version number for `columnWidthModeProvider`.
    ///
    /// Increment this when you change the provider closure to force
    /// width recalculation, even when `lockColumnWidthsAfterFirstLayout`
    /// is enabled.
    ///
    /// Default: 0
    public var columnWidthModeProviderVersion: Int = 0

    /// Whether to lock column widths after initial layout.
    ///
    /// When `true`, column widths are computed once on first layout
    /// and never recalculated. Prevents width drift across data updates.
    ///
    /// Default: `false`
    public var lockColumnWidthsAfterFirstLayout: Bool = false

    // MARK: - Colours

    /// Background colours for rows in highlighted (sorted) columns.
    ///
    /// Colours cycle through the array for alternating row striping.
    /// The sorted column uses these colours while other columns use
    /// `unhighlightedAlternatingRowColors`.
    ///
    /// Default: Two-colour array from `DataStyles.Colors`
    ///
    /// - Note: When ``defaultCellConfiguration`` is set, you are responsible for
    ///   setting the cell's background colour in that callback. These colours are
    ///   only used as fallback when no callback is provided.
    public var highlightedAlternatingRowColors = [
        DataStyles.Colors.highlightedFirstColor,
        DataStyles.Colors.highlightedSecondColor
    ]

    /// Background colours for rows in unhighlighted (non-sorted) columns.
    ///
    /// Colours cycle through the array for alternating row striping.
    ///
    /// Default: Two-colour array from `DataStyles.Colors`
    ///
    /// - Note: When ``defaultCellConfiguration`` is set, you are responsible for
    ///   setting the cell's background colour in that callback. These colours are
    ///   only used as fallback when no callback is provided.
    public var unhighlightedAlternatingRowColors = [
        DataStyles.Colors.unhighlightedFirstColor,
        DataStyles.Colors.unhighlightedSecondColor
    ]

    // MARK: - Fixed Columns

    /// Configuration for fixed (frozen) columns.
    ///
    /// Fixed columns remain visible while scrolling horizontally,
    /// useful for ID or name columns that provide row context.
    ///
    /// ```swift
    /// config.fixedColumns = DataTableFixedColumnType(leftColumns: 2)
    /// ```
    ///
    /// Default: `nil` (no fixed columns)
    public var fixedColumns: DataTableFixedColumnType? = nil

    // MARK: - Layout Modes

    /// How text content is displayed in cells.
    ///
    /// Controls single-line truncation or multi-line wrapping behavior.
    ///
    /// Default: `.singleLine(truncation: .byTruncatingTail)`
    public var textLayout: DataTableTextLayout = .singleLine()

    /// How row heights are determined.
    ///
    /// Choose between fixed heights for all rows or automatic
    /// heights based on content.
    ///
    /// Default: `.fixed(44)`
    public var rowHeightMode: DataTableRowHeightMode = .fixed(44)

    /// How cell sizes are calculated.
    ///
    /// Use `.defaultCell` for standard text cells or `.autoLayout`
    /// for custom cell types.
    ///
    /// Default: `.defaultCell`
    public var cellSizingMode: DataTableCellSizingMode = .defaultCell

    // MARK: - Cell Configuration

    /// Optional callback to customise the default DataCell appearance.
    ///
    /// Use this to modify font, text colour, background colour, or other properties
    /// without implementing a full custom cell provider. This callback is invoked
    /// for each cell when it is about to be displayed.
    ///
    /// ```swift
    /// var config = DataTableConfiguration()
    /// config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
    ///     cell.dataLabel.font = UIFont(name: "Avenir", size: 14)
    ///     cell.dataLabel.textColor = .darkGray
    ///     cell.backgroundColor = indexPath.item % 2 == 0 ? .systemGray6 : .systemBackground
    /// }
    /// ```
    ///
    /// - Note: This callback is only used when `cellSizingMode` is `.defaultCell`.
    ///   For custom cells, use ``DataTableCustomCellProvider``'s `configure` closure instead.
    ///
    /// - Important: When this callback is set, the default `highlightedAlternatingRowColors`
    ///   and `unhighlightedAlternatingRowColors` properties are not applied automatically.
    ///   You are responsible for setting the cell's background colour in the callback.
    public var defaultCellConfiguration: DefaultCellConfiguration? = nil

    // MARK: - Internationalization

    /// Whether to support right-to-left interface layouts.
    ///
    /// When `true` and the system interface direction is RTL,
    /// the table flips its horizontal scroll direction.
    ///
    /// Default: `true`
    public var shouldSupportRightToLeftInterfaceDirection: Bool = true

    // MARK: - Initialization

    /// Creates a new configuration with default values.
    ///
    /// All properties are set to sensible defaults. Modify individual
    /// properties as needed after initialization.
    ///
    /// ```swift
    /// var config = DataTableConfiguration()
    /// config.shouldShowSearchSection = false
    /// config.heightForSectionHeader = 50
    /// ```
    public init() {
    }
}
