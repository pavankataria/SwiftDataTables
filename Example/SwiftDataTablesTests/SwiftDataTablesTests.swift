//
//  SwiftDataTablesTests.swift
//  SwiftDataTablesTests
//
//  Created by Pavan Kataria on 18/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftDataTables_Example

class SwiftDataTablesTests: XCTestCase {
    
    func test_swiftDataTable_withConfigurationOptions_initialises() {
        var configuration : DataTableConfiguration = DataTableConfiguration()
        configuration.highlightedAlternatingRowColors = [
            .init(1, 0.7, 0.7), .init(1, 0.7, 0.5), .init(1, 1, 0.5), .init(0.5, 1, 0.5), .init(0.5, 0.7, 1), .init(0.5, 0.5, 1), .init(1, 0.5, 0.5)
        ]
        configuration.unhighlightedAlternatingRowColors = [
            .init(1, 0.90, 0.90), .init(1, 0.90, 0.7), .init(1, 1, 0.7), .init(0.7, 1, 0.7), .init(0.7, 0.9, 1), .init(0.7, 0.7, 1), .init(1, 0.7, 0.7)
        ]
        
        let dataTable = SwiftDataTable(data: [[String]](), headerTitles: [], options: configuration, frame: .zero)
        
        XCTAssertEqual(dataTable.options, configuration)
    }
}
