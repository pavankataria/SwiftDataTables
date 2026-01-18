//
//  DataTableColumnWidthStrategy.swift
//  SwiftDataTables
//
//  Created by Codex on 2026.
//

import UIKit

/// Deterministic sampling options for Auto Layout width measurement.
public enum DataTableAutoLayoutWidthSample: Equatable {
    case all
    case sampledMax(sampleSize: Int)
    case percentile(Double, sampleSize: Int)
}

/// Explicit column width configuration.
public enum DataTableColumnWidthMode: Equatable {
    case fixed(width: CGFloat)
    case fitContentText(strategy: DataTableColumnWidthStrategy)
    case fitContentAutoLayout(sample: DataTableAutoLayoutWidthSample = .all)
}

/// Strategy for deriving column widths.
public enum DataTableColumnWidthStrategy: Equatable {
    /// Measure every cell; most accurate, slowest.
    case maxMeasured
    /// Measure a percentile of widths from a deterministic sample (e.g. 0.95 over 200 rows).
    case percentileMeasured(percentile: Double, sampleSize: Int)
    /// Measure only a deterministic sample and take the max.
    case sampledMax(sampleSize: Int)
    /// Average of estimated widths per column: sum of (string.count * averageCharWidth) across rows, then divide by row count.
    case estimatedAverage(averageCharWidth: CGFloat)
    /// Combine estimated widths (all rows) with a measured sampled max (deterministic).
    case hybrid(sampleSize: Int, averageCharWidth: CGFloat)
    /// Fixed width for all rows in the column (before header/min clamps).
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
