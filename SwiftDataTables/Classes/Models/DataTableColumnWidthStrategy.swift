//
//  DataTableColumnWidthStrategy.swift
//  SwiftDataTables
//
//  Created by Codex on 2026.
//

import UIKit

/// Strategy for deriving column widths.
public enum DataTableColumnWidthStrategy: Equatable {
    /// Measure every cell; most accurate, slowest.
    case maxMeasured
    /// Measure a percentile of widths from a deterministic sample (e.g. 0.95 over 200 rows).
    case percentileMeasured(percentile: Double, sampleSize: Int)
    /// Measure only a deterministic sample and take the max.
    case sampledMax(sampleSize: Int)
    /// Estimate using character count * averageCharWidth; fastest.
    case estimated(averageCharWidth: CGFloat)
    /// Combine estimated widths (all rows) with a measured sampled max (deterministic).
    case hybrid(sampleSize: Int, averageCharWidth: CGFloat)
    /// Fixed width for all rows in the column (before header/min clamps).
    case fixed(width: CGFloat)
}
