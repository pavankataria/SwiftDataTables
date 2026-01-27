//
//  DataTableSortable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// A type that can be sorted within a data table column.
///
/// Types conforming to `DataTableSortable` can track and update their sort state,
/// which determines how data is ordered and what indicator is shown in the UI.
///
/// ## Implementation
///
/// The `sortType` property should be read-write to allow the data table
/// to update the sort state when users interact with column headers.
///
/// ## Usage
///
/// This protocol is primarily used internally by header view models.
/// Custom implementations are rarely needed.
@MainActor
public protocol DataTableSortable {

    /// The current sort state of this element.
    ///
    /// The data table updates this property when:
    /// - The user taps a column header
    /// - Default ordering is applied on initialization
    /// - Sort state is programmatically changed
    var sortType: DataTableSortType { get set }
}
