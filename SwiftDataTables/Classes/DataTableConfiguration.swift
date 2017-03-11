//
//  DataTableConfiguration.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation


public struct DataTableColumnOrder {
    let index: Int
    let order: DataTableSortType
}
public struct DataTableConfiguration {
    
//    let shouldShowFooters: Bool
    var defaultOrdering: DataTableColumnOrder? = nil
}
