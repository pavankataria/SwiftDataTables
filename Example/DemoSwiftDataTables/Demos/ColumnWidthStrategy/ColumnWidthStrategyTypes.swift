//
//  ColumnWidthStrategyTypes.swift
//  DemoSwiftDataTables
//
//  Types used by ColumnWidthStrategyDemoViewController.
//

import SwiftDataTables

struct StrategyOption {
    let title: String
    let description: String
    let strategy: DataTableColumnWidthStrategy
}

enum ColumnStrategyChoice: Int, CaseIterable {
    case global
    case estimated
    case maxMeasured
    case sampledMax
    case hybrid
    case percentile95
    case fixed

    var title: String {
        switch self {
        case .global: return "Global"
        case .estimated: return "Estimated"
        case .maxMeasured: return "Max"
        case .sampledMax: return "Sampled"
        case .hybrid: return "Hybrid"
        case .percentile95: return "P95"
        case .fixed: return "Fixed"
        }
    }
}
