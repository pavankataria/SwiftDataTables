//
//  RowHeightAndWrapTypes.swift
//  DemoSwiftDataTables
//
//  Types used by RowHeightAndWrapDemoViewController.
//

import SwiftDataTables

enum WidthStrategyOption: Int, CaseIterable {
    case estimatedAverage
    case maxMeasured
    case fixed

    var title: String {
        switch self {
        case .estimatedAverage: return "Estimated Avg"
        case .maxMeasured: return "Max Measured"
        case .fixed: return "Fixed 140"
        }
    }

    var strategy: DataTableColumnWidthStrategy {
        switch self {
        case .estimatedAverage:
            return .estimatedAverage(averageCharWidth: 7)
        case .maxMeasured:
            return .maxMeasured
        case .fixed:
            return .fixed(width: 140)
        }
    }
}

enum RowCountOption: Int, CaseIterable {
    case small
    case medium
    case large

    var title: String {
        switch self {
        case .small: return "200"
        case .medium: return "2k"
        case .large: return "8k"
        }
    }

    var value: Int {
        switch self {
        case .small: return 200
        case .medium: return 2000
        case .large: return 8000
        }
    }
}
