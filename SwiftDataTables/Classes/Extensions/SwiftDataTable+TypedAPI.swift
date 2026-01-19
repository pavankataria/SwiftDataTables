//
//  SwiftDataTable+TypedAPI.swift
//  SwiftDataTables
//
//  Created for SwiftDataTables.
//

import UIKit

// MARK: - Type-Safe Data Table API

/// Extension providing type-safe initialization and data management for SwiftDataTable.
///
/// This API allows you to work directly with your model types instead of
/// manually converting to `[[DataTableValueType]]` arrays.
///
/// ## Basic Usage
///
/// ```swift
/// struct User: Identifiable {
///     let id: Int
///     let name: String
///     let score: Int
/// }
///
/// let users: [User] = [...]
///
/// // Create table with column definitions
/// let table = SwiftDataTable(data: users, columns: [
///     .init("Name", \.name),
///     .init("Score", \.score)
/// ])
///
/// // Update data with animations
/// users.append(User(id: 3, name: "Charlie", score: 85))
/// table.setData(users, animatingDifferences: true)
/// ```
///
/// ## Custom Cells
///
/// For columns that need custom cells, omit the KeyPath:
///
/// ```swift
/// let table = SwiftDataTable(data: users, columns: [
///     .init("Profile"),    // Custom cell - value extraction skipped
///     .init("Name", \.name)
/// ])
/// ```
///
/// Then use `cellSizingMode: .autoLayout(provider:)` in the configuration
/// to provide custom cell rendering. See `DataTableCustomCellProvider`.
public extension SwiftDataTable {

    // MARK: - Typed Initializer

    /// Creates a SwiftDataTable with typed data and column definitions.
    ///
    /// - Parameters:
    ///   - data: Array of model objects conforming to `Identifiable`.
    ///   - columns: Column definitions specifying headers and value extraction.
    ///   - options: Configuration options for the table.
    ///   - frame: Initial frame for the view.
    convenience init<T: Identifiable>(
        data: [T],
        columns: [DataTableColumn<T>],
        options: DataTableConfiguration = DataTableConfiguration(),
        frame: CGRect = .zero
    ) {
        // Extract headers from columns
        let headerTitles = columns.map { $0.header }

        // Convert typed data to DataTableContent
        let content: DataTableContent = data.map { item in
            columns.map { column in
                column.extract?(item) ?? .string("")
            }
        }

        // Use existing initializer
        self.init(data: content, headerTitles: headerTitles, options: options, frame: frame)

        // Store column extractors and data for typed operations
        storeTypedContext(data: data, columns: columns)
    }

    // MARK: - Typed Data Updates

    /// Updates the table data using typed models with automatic diffing.
    ///
    /// The table uses each model's `id` property (from `Identifiable` conformance)
    /// to determine which rows were added, removed, or moved.
    ///
    /// - Parameters:
    ///   - data: The new complete data set.
    ///   - columns: Column definitions (uses stored columns if nil).
    ///   - animatingDifferences: Whether to animate the changes.
    ///   - completion: Called when the update completes.
    ///
    /// Example:
    /// ```swift
    /// // Modify your data
    /// users.append(User(id: 4, name: "Diana", score: 92))
    /// users.removeAll { $0.id == 1 }
    ///
    /// // Update table - it will animate the diff
    /// table.setData(users, animatingDifferences: true)
    /// ```
    func setData<T: Identifiable>(
        _ data: [T],
        columns: [DataTableColumn<T>]? = nil,
        animatingDifferences: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Get column extractors
        let columnDefs: [DataTableColumn<T>]
        if let cols = columns {
            columnDefs = cols
        } else if let stored = getStoredColumns() as? [DataTableColumn<T>] {
            columnDefs = stored
        } else {
            assertionFailure("No columns provided and no stored columns found. Provide columns parameter.")
            completion?(false)
            return
        }

        // Convert typed data to DataTableContent
        let content: DataTableContent = data.map { item in
            columnDefs.map { column in
                column.extract?(item) ?? .string("")
            }
        }

        // Extract identifiers from Identifiable conformance
        let identifiers = data.map { "\($0.id)" }

        // Store updated data
        storeTypedContext(data: data, columns: columnDefs)

        // Use existing setData with identifiers
        setData(content, rowIdentifiers: identifiers, animatingDifferences: animatingDifferences, completion: completion)
    }

    // MARK: - Model Access

    /// Retrieves the typed model for a given row index.
    ///
    /// - Parameter row: The row index.
    /// - Returns: The model object, or nil if not found or type mismatch.
    func model<T>(at row: Int) -> T? {
        guard let models = getStoredData() as? [T],
              row >= 0 && row < models.count else {
            return nil
        }
        return models[row]
    }

    /// Retrieves all typed models currently in the table.
    ///
    /// - Returns: Array of model objects, or nil if type mismatch.
    func allModels<T>() -> [T]? {
        return getStoredData() as? [T]
    }
}

// MARK: - Private Storage

/// Keys for associated object storage
private enum TypedAPIKeys {
    static var storedData = "SwiftDataTable.storedData"
    static var storedColumns = "SwiftDataTable.storedColumns"
}

private extension SwiftDataTable {

    func storeTypedContext<T>(data: [T], columns: [DataTableColumn<T>]) {
        objc_setAssociatedObject(self, &TypedAPIKeys.storedData, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &TypedAPIKeys.storedColumns, columns, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func getStoredData() -> Any? {
        return objc_getAssociatedObject(self, &TypedAPIKeys.storedData)
    }

    func getStoredColumns() -> Any? {
        return objc_getAssociatedObject(self, &TypedAPIKeys.storedColumns)
    }
}
