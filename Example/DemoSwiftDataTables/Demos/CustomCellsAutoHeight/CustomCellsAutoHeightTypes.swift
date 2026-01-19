//
//  CustomCellsAutoHeightTypes.swift
//  DemoSwiftDataTables
//
//  Types used by CustomCellsAutoHeightDemoViewController.
//

import SwiftDataTables

enum WidthModeOption: Int, CaseIterable {
    case textEstimated
    case textMax
    case fixed

    var title: String {
        switch self {
        case .textEstimated: return "Text Est"
        case .textMax: return "Text Max"
        case .fixed: return "Fixed 140"
        }
    }

    var mode: DataTableColumnWidthMode {
        switch self {
        case .textEstimated:
            return .fitContentText(strategy: .estimatedAverage(averageCharWidth: 7))
        case .textMax:
            return .fitContentText(strategy: .maxMeasured)
        case .fixed:
            return .fixed(width: 140)
        }
    }
}

enum CustomCellsRowCountOption: Int, CaseIterable {
    case small
    case medium
    case large

    var title: String {
        switch self {
        case .small: return "50"
        case .medium: return "200"
        case .large: return "1k"
        }
    }

    var value: Int {
        switch self {
        case .small: return 50
        case .medium: return 200
        case .large: return 1000
        }
    }
}
