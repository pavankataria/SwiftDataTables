//
//  DataTableColumnWidthStrategy.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Deterministic sampling options for Auto Layout-based column width measurement.
///
/// Used with `.fitContentAutoLayout` mode to control how many cells are measured
/// when determining column widths. Measuring fewer cells improves performance
/// but may result in truncated content for unmeasured rows.
///
/// ## Performance Considerations
///
/// - `.all`: Most accurate but slowest. O(n) measurements.
/// - `.sampledMax`: Good balance. O(sampleSize) measurements.
/// - `.percentile`: Statistical approach for outlier handling.
public enum DataTableAutoLayoutWidthSample: Equatable {

    /// Measure all cells in the column.
    ///
    /// Most accurate but slowest. Use for small datasets (<100 rows)
    /// or when exact sizing is critical.
    case all

    /// Measure a fixed sample of cells and use the maximum width.
    ///
    /// - Parameter sampleSize: Number of cells to measure (evenly distributed).
    ///
    /// Example: `.sampledMax(sampleSize: 50)` measures 50 evenly-spaced rows.
    case sampledMax(sampleSize: Int)

    /// Use a statistical percentile from a sample of measurements.
    ///
    /// - Parameters:
    ///   - percentile: The percentile to use (0.0-1.0). E.g., 0.95 ignores top 5%.
    ///   - sampleSize: Number of cells to measure.
    ///
    /// Useful when a few rows have unusually long content that would
    /// make columns unnecessarily wide.
    case percentile(Double, sampleSize: Int)
}

/// High-level column width calculation mode.
///
/// `DataTableColumnWidthMode` provides different approaches to determining
/// column widths, from fixed values to content-aware calculations.
///
/// ## Usage
///
/// Set on configuration:
/// ```swift
/// var config = DataTableConfiguration()
///
/// // All columns use same mode
/// config.columnWidthMode = .fixed(width: 120)
///
/// // Per-column customization
/// config.columnWidthModeProvider = { column in
///     switch column {
///     case 0: return .fixed(width: 80)    // ID column
///     default: return nil                  // Use default
///     }
/// }
/// ```
public enum DataTableColumnWidthMode: Equatable {

    /// All cells in the column have the same fixed width.
    ///
    /// - Parameter width: Width in points for every cell.
    ///
    /// Most performant option. Use when content length is predictable.
    case fixed(width: CGFloat)

    /// Width calculated from text content using the specified strategy.
    ///
    /// - Parameter strategy: How to measure/estimate text width.
    ///
    /// Uses string length and font metrics to determine width.
    /// More performant than Auto Layout measurement.
    case fitContentText(strategy: DataTableColumnWidthStrategy)

    /// Width calculated using Auto Layout cell measurement.
    ///
    /// - Parameter sample: How many cells to measure.
    ///
    /// Most accurate for custom cells with complex layouts.
    /// Performance depends on cell complexity and sample size.
    case fitContentAutoLayout(sample: DataTableAutoLayoutWidthSample = .all)
}

/// Strategy for calculating column widths from text content.
///
/// `DataTableColumnWidthStrategy` provides various algorithms for determining
/// column widths when using `.fitContentText` mode. Choose based on your
/// performance requirements and content characteristics.
///
/// ## Strategy Comparison
///
/// | Strategy | Accuracy | Performance | Best For |
/// |----------|----------|-------------|----------|
/// | `.maxMeasured` | Highest | Slowest | Small datasets |
/// | `.sampledMax` | Good | Fast | Medium datasets |
/// | `.percentileMeasured` | Good | Fast | Data with outliers |
/// | `.estimatedAverage` | Moderate | Fastest | Large datasets |
/// | `.hybrid` | Good | Fast | General purpose |
/// | `.fixed` | N/A | Fastest | Known content |
public enum DataTableColumnWidthStrategy: Equatable {

    /// Measures every cell's text width and uses the maximum.
    ///
    /// Most accurate but O(n) performance. Suitable for datasets
    /// under ~100 rows or when exact sizing is critical.
    case maxMeasured

    /// Uses a percentile from a sample of measured widths.
    ///
    /// - Parameters:
    ///   - percentile: The percentile to use (e.g., 0.95 for 95th percentile).
    ///   - sampleSize: Number of rows to measure.
    ///
    /// Ignores outliers that would make columns unnecessarily wide.
    case percentileMeasured(percentile: Double, sampleSize: Int)

    /// Measures a sample of cells and uses the maximum.
    ///
    /// - Parameter sampleSize: Number of rows to measure (evenly distributed).
    ///
    /// Good balance of accuracy and performance for most datasets.
    case sampledMax(sampleSize: Int)

    /// Estimates width using character count and average character width.
    ///
    /// - Parameter averageCharWidth: Estimated width per character in points.
    ///
    /// Fastest option. Calculates: `string.count * averageCharWidth`.
    /// Works well when content length varies but character width is consistent.
    case estimatedAverage(averageCharWidth: CGFloat)

    /// Combines estimation with sampled measurement for validation.
    ///
    /// - Parameters:
    ///   - sampleSize: Number of rows to measure.
    ///   - averageCharWidth: Estimated width per character.
    ///
    /// Uses estimation for all rows, validates with measured sample.
    /// Good default choice for large datasets.
    case hybrid(sampleSize: Int, averageCharWidth: CGFloat)

    /// Uses a fixed width regardless of content.
    ///
    /// - Parameter width: Width in points.
    ///
    /// Fastest option when you know your content width requirements.
    case fixed(width: CGFloat)
}

extension DataTableColumnWidthMode {
    var textStrategy: DataTableColumnWidthStrategy? {
        switch self {
        case .fitContentText(let strategy):
            return strategy
        case .fixed, .fitContentAutoLayout:
            return nil
        }
    }

    var prefersEstimatedTextWidths: Bool {
        return textStrategy?.prefersEstimation ?? false
    }
}
