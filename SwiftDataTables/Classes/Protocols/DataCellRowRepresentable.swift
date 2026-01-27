//
//  DataCellRowRepresentable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 10/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// A type that can represent itself as a row of data table cell values.
///
/// Conform to this protocol to enable direct use of your model types
/// as data table rows without manual conversion.
///
/// ## Usage
///
/// ```swift
/// struct Person: DataCellRowRepresentable {
///     let name: String
///     let age: Int
///     let email: String
///
///     func dataCellRowRepresentable() -> [DataTableValueType] {
///         return [
///             .string(name),
///             .int(age),
///             .string(email)
///         ]
///     }
/// }
///
/// // Use directly with data table
/// let people: [Person] = [...]
/// let rows = people.map { $0.dataCellRowRepresentable() }
/// ```
///
/// - Note: For most use cases, consider using the typed API with
///   `DataTableColumn` instead, which provides compile-time type safety.
public protocol DataCellRowRepresentable {

    /// Converts this instance to an array of data table cell values.
    ///
    /// The returned array should have one element for each column in the table.
    /// The order should match the column order defined in the table headers.
    ///
    /// - Returns: An array of `DataTableValueType` values representing this row.
    func dataCellRowRepresentable() -> [DataTableValueType]
}
