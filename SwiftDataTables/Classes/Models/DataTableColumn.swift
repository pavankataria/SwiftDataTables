//
//  DataTableColumn.swift
//  SwiftDataTables
//
//  Created for SwiftDataTables.
//

import Foundation

/// Defines a column in a SwiftDataTable with its header and value extraction logic.
///
/// Use `DataTableColumn` to map your model properties to table columns:
///
/// ```swift
/// struct User: Identifiable {
///     let id: Int
///     let name: String
///     let age: Int
/// }
///
/// let table = SwiftDataTable(data: users, columns: [
///     .init("Name", \.name),     // KeyPath to String property
///     .init("Age", \.age),       // KeyPath to Int property
///     .init("Profile")           // Custom cell column (no extraction)
/// ])
/// ```
public struct DataTableColumn<T> {

    /// The header title displayed at the top of the column.
    public let header: String

    /// Closure that extracts the value from a model instance.
    /// Returns `nil` for custom cell columns where no automatic extraction is needed.
    public let extract: ((T) -> DataTableValueType)?

    // MARK: - Initializers

    /// Creates a column with a KeyPath for automatic value extraction.
    ///
    /// - Parameters:
    ///   - header: The column header title.
    ///   - keyPath: KeyPath to the property to display.
    ///
    /// Example:
    /// ```swift
    /// DataTableColumn("Name", \.name)
    /// DataTableColumn("Score", \.score)
    /// ```
    public init<V: DataTableValueConvertible>(_ header: String, _ keyPath: KeyPath<T, V>) {
        self.header = header
        self.extract = { item in
            item[keyPath: keyPath].asDataTableValue()
        }
    }

    /// Creates a column with a custom extraction closure.
    ///
    /// Use this for computed or transformed values:
    /// ```swift
    /// DataTableColumn("Full Name") { user in
    ///     .string("\(user.firstName) \(user.lastName)")
    /// }
    /// ```
    public init(_ header: String, extract: @escaping (T) -> DataTableValueType) {
        self.header = header
        self.extract = extract
    }

    /// Creates a header-only column for use with custom cells.
    ///
    /// When using `customCellProvider`, you can define columns that only
    /// specify the header. The custom cell handles all rendering.
    ///
    /// ```swift
    /// DataTableColumn<User>("Profile")  // Custom cell renders this column
    /// ```
    public init(_ header: String) {
        self.header = header
        self.extract = nil
    }
}
