//
//  DataTableDifferentiable.swift
//  SwiftDataTables
//
//  Created for SwiftDataTables.
//

import Foundation

/// A protocol for types that can determine content equality for diffing purposes.
///
/// Conform to this protocol to control when a row is considered "changed" during
/// incremental updates. This is separate from `Equatable` - you might want two
/// objects to be equal for business logic but still trigger a UI refresh.
///
/// If you don't conform to this protocol, the table compares all column values
/// using the `DataTableColumn` extractors to detect changes.
public protocol ContentEquatable {
    /// Returns whether this instance has the same content as another instance.
    ///
    /// Return `true` if the row should NOT be refreshed (content is the same).
    /// Return `false` if the row SHOULD be refreshed (content changed).
    ///
    /// - Parameter source: Another instance of the same type to compare against.
    /// - Returns: `true` if content is equal, `false` if content changed.
    func isContentEqual(to source: Self) -> Bool
}

/// A type that can be diffed in a SwiftDataTable.
///
/// Combines `Identifiable` (for tracking row identity) with `ContentEquatable`
/// (for detecting content changes).
///
/// ## Example
///
/// ```swift
/// struct Stock: DataTableDifferentiable {
///     let id: String
///     var symbol: String
///     var price: Double
///     var lastUpdated: Date
///
///     func isContentEqual(to source: Stock) -> Bool {
///         // Only refresh UI when price changes, ignore timestamp
///         symbol == source.symbol && price == source.price
///     }
/// }
/// ```
public typealias DataTableDifferentiable = Identifiable & ContentEquatable
