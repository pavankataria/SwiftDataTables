//
//  DataTableColumn.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
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

    /// Type-erased comparator for sorting.
    ///
    /// When present, sorting uses this instead of `DataTableValueType` comparison.
    /// This enables proper typed sorting for formatted display values.
    let compare: ((T, T) -> ComparisonResult)?

    /// Whether this column can be sorted.
    ///
    /// Returns `true` if the column has extraction OR comparison logic.
    /// Columns with neither (header-only columns) cannot be sorted.
    public var isSortable: Bool {
        extract != nil || compare != nil
    }

    // MARK: - Existing Initializers

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
        self.compare = nil
    }

    /// Creates a column with a custom extraction closure.
    ///
    /// Use this for computed or transformed values. The closure can return
    /// any type conforming to `DataTableValueConvertible`:
    ///
    /// ```swift
    /// // Return String directly - no wrapping needed
    /// DataTableColumn("Full Name") { "\($0.firstName) \($0.lastName)" }
    ///
    /// // Return formatted values
    /// DataTableColumn("Salary") { "£\($0.salary)" }
    ///
    /// // Computed numeric values work too
    /// DataTableColumn("Total") { $0.price * $0.quantity }
    /// ```
    public init<V: DataTableValueConvertible>(_ header: String, extract: @escaping (T) -> V) {
        self.header = header
        self.extract = { extract($0).asDataTableValue() }
        self.compare = nil
    }

    /// Creates a column with explicit `DataTableValueType` extraction.
    ///
    /// Use this when you need explicit control over the value type for sorting:
    /// ```swift
    /// // Numeric sorting on computed value
    /// DataTableColumn("Score") { .int($0.points + $0.bonus) }
    /// ```
    public init(_ header: String, extract: @escaping (T) -> DataTableValueType) {
        self.header = header
        self.extract = extract
        self.compare = nil
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
        self.compare = nil
    }

    // MARK: - Typed Sorting Initializers

    /// Creates a column that displays a formatted value but sorts by the typed value.
    ///
    /// Use this when you want to format a single property for display while
    /// preserving proper typed sorting:
    ///
    /// ```swift
    /// // Money: displays "$1,234.56", sorts numerically by 1234.56
    /// DataTableColumn("Salary", \.salary) { "$\(String(format: "%.2f", $0))" }
    ///
    /// // Date: displays "Jan 15, 2024", sorts chronologically
    /// DataTableColumn("Created", \.createdAt) { $0.formatted(date: .abbreviated, time: .omitted) }
    ///
    /// // Percentage: displays "75%", sorts by 0.75
    /// DataTableColumn("Progress", \.progress) { "\(Int($0 * 100))%" }
    /// ```
    ///
    /// - Parameters:
    ///   - header: The column header title.
    ///   - keyPath: KeyPath to the property to sort by.
    ///   - format: Closure that formats the value for display.
    public init<V: Comparable>(_ header: String, _ keyPath: KeyPath<T, V>, format: @escaping (V) -> String) {
        self.header = header
        self.extract = { .string(format($0[keyPath: keyPath])) }
        self.compare = { lhs, rhs in
            let a = lhs[keyPath: keyPath]
            let b = rhs[keyPath: keyPath]
            if a < b { return .orderedAscending }
            if a > b { return .orderedDescending }
            return .orderedSame
        }
    }

    /// Creates a column that sorts by a specific property while displaying custom content.
    ///
    /// Use this when the display combines multiple properties but you want to
    /// sort by ONE specific property:
    ///
    /// ```swift
    /// // Show "Alice Smith", sort by last name
    /// DataTableColumn("Full Name", sortedBy: \.lastName) { "\($0.firstName) \($0.lastName)" }
    ///
    /// // Show "Widget ($49.99)", sort by price
    /// DataTableColumn("Product", sortedBy: \.price) { "\($0.name) ($\(String(format: "%.2f", $0.price)))" }
    /// ```
    ///
    /// - Parameters:
    ///   - header: The column header title.
    ///   - keyPath: KeyPath to the property to sort by.
    ///   - display: Closure that generates the display string from the row.
    public init<S: Comparable>(_ header: String, sortedBy keyPath: KeyPath<T, S>, display: @escaping (T) -> String) {
        self.header = header
        self.extract = { .string(display($0)) }
        self.compare = { lhs, rhs in
            let a = lhs[keyPath: keyPath]
            let b = rhs[keyPath: keyPath]
            if a < b { return .orderedAscending }
            if a > b { return .orderedDescending }
            return .orderedSame
        }
    }

    /// Creates a column that sorts by a computed value while displaying custom content.
    ///
    /// Use this when the sort value doesn't exist as a property - it's computed:
    ///
    /// ```swift
    /// // Show title, sort by length (shortest first)
    /// DataTableColumn("Title", sortedBy: { $0.title.count }) { $0.title }
    ///
    /// // Show priority label, sort by custom order
    /// DataTableColumn("Priority", sortedBy: { $0.priority.sortOrder }) { $0.priority.displayName }
    ///
    /// // Show total, sort by computed value
    /// DataTableColumn("Total", sortedBy: { $0.price * Double($0.quantity) }) {
    ///     "$\(String(format: "%.2f", $0.price * Double($0.quantity)))"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - header: The column header title.
    ///   - extractor: Closure that extracts the sortable value from a row.
    ///   - display: Closure that generates the display string from the row.
    public init<S: Comparable>(_ header: String, sortedBy extractor: @escaping (T) -> S, display: @escaping (T) -> String) {
        self.header = header
        self.extract = { .string(display($0)) }
        self.compare = { lhs, rhs in
            let a = extractor(lhs)
            let b = extractor(rhs)
            if a < b { return .orderedAscending }
            if a > b { return .orderedDescending }
            return .orderedSame
        }
    }

    /// Creates a column with full custom comparison logic.
    ///
    /// Use this when standard comparison isn't enough:
    ///
    /// ```swift
    /// // Case-insensitive sorting
    /// DataTableColumn("Name", sortedBy: { $0.name.localizedCaseInsensitiveCompare($1.name) }) { $0.name }
    ///
    /// // Nulls last (optional dates)
    /// DataTableColumn("Due Date", sortedBy: { lhs, rhs in
    ///     switch (lhs.dueDate, rhs.dueDate) {
    ///     case (nil, nil): return .orderedSame
    ///     case (nil, _): return .orderedDescending
    ///     case (_, nil): return .orderedAscending
    ///     case (let a?, let b?): return a.compare(b)
    ///     }
    /// }) { $0.dueDate?.formatted() ?? "No date" }
    ///
    /// // Version numbers (semantic versioning)
    /// DataTableColumn("Version", sortedBy: { lhs, rhs in
    ///     lhs.version.compare(rhs.version, options: .numeric)
    /// }) { $0.version }
    /// ```
    ///
    /// - Parameters:
    ///   - header: The column header title.
    ///   - comparator: Closure that compares two rows and returns a `ComparisonResult`.
    ///   - display: Closure that generates the display string from the row.
    public init(_ header: String, sortedBy comparator: @escaping (T, T) -> ComparisonResult, display: @escaping (T) -> String) {
        self.header = header
        self.extract = { .string(display($0)) }
        self.compare = comparator
    }
}
