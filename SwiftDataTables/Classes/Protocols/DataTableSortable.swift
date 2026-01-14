//
//  DataTableSortable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
@MainActor
public protocol DataTableSortable {
    var sortType: DataTableSortType { get set }
}
