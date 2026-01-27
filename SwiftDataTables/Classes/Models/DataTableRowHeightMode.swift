//
//  DataTableRowHeightMode.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

/// Defines how row heights are calculated in the data table.
///
/// `DataTableRowHeightMode` controls whether all rows have a uniform fixed height
/// or whether heights are calculated automatically based on content.
///
/// ## Usage
///
/// Configure via `DataTableConfiguration`:
/// ```swift
/// var config = DataTableConfiguration()
///
/// // Fixed height for all rows (default)
/// config.rowHeightMode = .fixed(44)
///
/// // Automatic heights based on content
/// config.rowHeightMode = .automatic(estimated: 60, prefetchWindow: 10)
/// ```
///
/// ## Performance Considerations
///
/// - `.fixed`: Best performance. Use when all rows have similar content.
/// - `.automatic`: Measures rows lazily as they become visible. Uses scroll
///   anchoring to maintain accurate scroll position.
public enum DataTableRowHeightMode: Equatable {

    /// All rows have the same fixed height.
    ///
    /// - Parameter height: The height in points for every row.
    ///
    /// This is the most performant option as no measurement is required.
    /// Use when your data has consistent content sizes.
    ///
    /// Example:
    /// ```swift
    /// config.rowHeightMode = .fixed(44)  // Standard row height
    /// config.rowHeightMode = .fixed(88)  // Double height for more content
    /// ```
    case fixed(CGFloat)

    /// Row heights are calculated automatically based on content.
    ///
    /// Rows are measured lazily as they become visible in the viewport.
    /// Unmeasured rows use the estimated height for scroll bar accuracy.
    /// Scroll anchoring keeps the visible content stable as measurements occur.
    ///
    /// - Parameters:
    ///   - estimated: The estimated height used for unmeasured rows.
    ///     Choose a value close to your average row height for best
    ///     scroll bar accuracy. Default: 44 points.
    ///   - prefetchWindow: Number of rows above and below the viewport
    ///     to pre-measure. Higher values reduce visual jumps during
    ///     fast scrolling but increase initial measurement work.
    ///     Default: 10 rows.
    ///
    /// Example:
    /// ```swift
    /// // Standard automatic heights
    /// config.rowHeightMode = .automatic()
    ///
    /// // Taller estimated height for multi-line content
    /// config.rowHeightMode = .automatic(estimated: 80, prefetchWindow: 20)
    /// ```
    ///
    /// - Note: For best results with automatic heights, also configure
    ///   `textLayout = .wrap` to allow content to expand.
    case automatic(estimated: CGFloat = 44, prefetchWindow: Int = 10)

    /// Legacy alias for automatic mode.
    ///
    /// - Parameters:
    ///   - estimatedHeight: The estimated height for unmeasured rows.
    ///   - prefetchWindow: Rows to pre-measure around the viewport.
    /// - Returns: An automatic row height mode with the specified parameters.
    @available(*, deprecated, renamed: "automatic")
    public static func largeScale(estimatedHeight: CGFloat = 44, prefetchWindow: Int = 10) -> DataTableRowHeightMode {
        return .automatic(estimated: estimatedHeight, prefetchWindow: prefetchWindow)
    }
}

// MARK: - Convenience Properties

extension DataTableRowHeightMode {

    /// The height value used for layout calculations.
    ///
    /// For `.fixed` mode, returns the specified height.
    /// For `.automatic` mode, returns the estimated height.
    var estimatedHeight: CGFloat {
        switch self {
        case .fixed(let height):
            return height
        case .automatic(let estimated, _):
            return estimated
        }
    }

    /// The number of rows to pre-measure around the viewport.
    ///
    /// Returns 0 for `.fixed` mode (no measurement needed).
    /// Returns the configured prefetch window for `.automatic` mode.
    var prefetchWindow: Int {
        switch self {
        case .automatic(_, let window):
            return window
        case .fixed:
            return 0
        }
    }

    /// Whether this mode requires lazy row measurement.
    ///
    /// Returns `true` for `.automatic` mode, `false` for `.fixed` mode.
    var usesLazyMeasurement: Bool {
        switch self {
        case .automatic:
            return true
        case .fixed:
            return false
        }
    }
}
