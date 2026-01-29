//
//  SwiftDataTable+TypedAPI.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
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
        data: [T] = [],
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

        // Refresh header sort types now that typed sortabilities are available
        refreshHeaderSortTypes()

        // Seed identifiers so the first diff doesn't treat all rows as inserts.
        seedRowIdentifiers(data.map { "\($0.id)" })
    }

    // MARK: - Typed Data Updates

    /// Updates the table data using typed models with automatic diffing.
    ///
    /// The table uses each model's `id` property (from `Identifiable` conformance)
    /// to determine which rows were added, removed, or moved.
    ///
    /// If the model conforms to `DataTableDifferentiable`, the table uses
    /// `isContentEqual(to:)` to detect content changes. Otherwise, it compares
    /// extracted column values.
    ///
    /// - Parameters:
    ///   - data: The new complete data set.
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
        animatingDifferences: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Get column extractors from stored context
        guard let columnDefs = getStoredColumns() as? [DataTableColumn<T>] else {
            assertionFailure("No stored columns found. Use init(columns:) to create the table first.")
            completion?(false)
            return
        }

        // Get old data for comparison
        let oldData = getStoredData() as? [T] ?? []

        // Build ID → old model map for O(n) lookup
        var oldIdToModel = [String: T]()
        for model in oldData {
            oldIdToModel["\(model.id)"] = model
        }

        // Convert typed data to DataTableContent
        let content: DataTableContent = data.map { item in
            columnDefs.map { column in
                column.extract?(item) ?? .string("")
            }
        }

        // Extract identifiers from Identifiable conformance
        let identifiers = data.map { "\($0.id)" }

        // Find changed rows using column extractors (if we have old data)
        if !oldData.isEmpty {
            var changedIds = Set<String>()
            for newModel in data {
                let id = "\(newModel.id)"
                if let oldModel = oldIdToModel[id] {
                    // Compare using column extractors - early exit on first difference
                    let hasChanged = columnDefs.contains { column in
                        guard let extract = column.extract else { return false }
                        return extract(oldModel) != extract(newModel)
                    }
                    if hasChanged {
                        changedIds.insert(id)
                    }
                }
            }
            precomputedChangedIdentifiers = changedIds
        }

        // Store updated data
        storeTypedContext(data: data, columns: columnDefs)

        // Use existing setData with identifiers
        setData(content, rowIdentifiers: identifiers, animatingDifferences: animatingDifferences, completion: completion)
    }

    /// Updates the table data using differentiable models with optimized change detection.
    ///
    /// This overload is used when your model conforms to `DataTableDifferentiable`
    /// (which combines `Identifiable` and `ContentEquatable`). It uses
    /// `isContentEqual(to:)` for efficient content comparison instead of
    /// comparing all column values.
    ///
    /// - Parameters:
    ///   - data: The new complete data set.
    ///   - animatingDifferences: Whether to animate the changes.
    ///   - completion: Called when the update completes.
    func setData<T: DataTableDifferentiable>(
        _ data: [T],
        animatingDifferences: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Get column extractors from stored context
        guard let columnDefs = getStoredColumns() as? [DataTableColumn<T>] else {
            assertionFailure("No stored columns found. Use init(columns:) to create the table first.")
            completion?(false)
            return
        }

        // Get old data for comparison
        let oldData = getStoredData() as? [T] ?? []

        // Build ID → old model map for O(n) lookup
        var oldIdToModel = [String: T]()
        for model in oldData {
            oldIdToModel["\(model.id)"] = model
        }

        // Convert typed data to DataTableContent
        let content: DataTableContent = data.map { item in
            columnDefs.map { column in
                column.extract?(item) ?? .string("")
            }
        }

        // Extract identifiers from Identifiable conformance
        let identifiers = data.map { "\($0.id)" }

        // Find changed rows using isContentEqual
        var changedIds = Set<String>()
        for newModel in data {
            let id = "\(newModel.id)"
            if let oldModel = oldIdToModel[id] {
                if !newModel.isContentEqual(to: oldModel) {
                    changedIds.insert(id)
                }
            }
        }

        // Store changed identifiers for applyDiff to use
        precomputedChangedIdentifiers = changedIds

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

    // MARK: - Column Updates

    /// Updates the column definitions and reloads the table.
    ///
    /// Use this when you need to change which columns are displayed or how
    /// values are extracted. The table reloads completely with the new columns.
    ///
    /// - Parameters:
    ///   - columns: New column definitions.
    ///   - data: Optional new data. If nil, uses existing stored data.
    func setColumns<T: Identifiable>(_ columns: [DataTableColumn<T>], data: [T]? = nil) {
        let dataToUse = data ?? (getStoredData() as? [T]) ?? []

        // Extract headers from columns
        let headerTitles = columns.map { $0.header }

        // Convert typed data to DataTableContent
        let content: DataTableContent = dataToUse.map { item in
            columns.map { column in
                column.extract?(item) ?? .string("")
            }
        }

        // Store new context
        storeTypedContext(data: dataToUse, columns: columns)

        // Update data with new headers
        set(data: content, headerTitles: headerTitles)
        reload()
    }
}

// MARK: - Internal Storage (visible to tests via @testable import)

extension SwiftDataTable {

    /// Stores typed data and column definitions for later retrieval.
    /// - Note: Internal access for testing. Not part of public API.
    func storeTypedContext<T>(data: [T], columns: [DataTableColumn<T>]) {
        typedData = data
        typedColumns = columns

        // Store type-erased comparators for sorting
        storeTypedComparators(data: data, columns: columns)
    }

    func getStoredData() -> Any? {
        return typedData
    }

    func getStoredColumns() -> Any? {
        return typedColumns
    }

    /// Stores type-erased comparators for each column that has a compare closure.
    private func storeTypedComparators<T>(data: [T], columns: [DataTableColumn<T>]) {
        var comparators = [Int: (Int, Int) -> ComparisonResult]()
        var sortabilities = [Int: Bool]()

        // Initialize index mapping (identity mapping initially)
        currentToOriginalDataIndex = Array(0..<data.count)

        for (columnIndex, column) in columns.enumerated() {
            // Store sortability for each column
            sortabilities[columnIndex] = column.isSortable

            if let compare = column.compare {
                // Create a closure that captures the data array and compare function.
                // Uses currentToOriginalDataIndex to map current row positions to original data indices,
                // since typedData stays in original order while rows get reordered by sorting.
                comparators[columnIndex] = { [weak self] currentRowIndex1, currentRowIndex2 in
                    guard let self = self,
                          let currentData = self.typedData as? [T],
                          let indexMap = self.currentToOriginalDataIndex,
                          currentRowIndex1 < indexMap.count,
                          currentRowIndex2 < indexMap.count else {
                        return .orderedSame
                    }
                    let originalIndex1 = indexMap[currentRowIndex1]
                    let originalIndex2 = indexMap[currentRowIndex2]
                    guard originalIndex1 < currentData.count,
                          originalIndex2 < currentData.count else {
                        return .orderedSame
                    }
                    return compare(currentData[originalIndex1], currentData[originalIndex2])
                }
            }
        }

        typedComparators = comparators
        typedColumnSortabilities = sortabilities
    }

    /// Returns a type-erased comparator for the specified column.
    /// The comparator takes two row indices and returns a ComparisonResult.
    func getTypedColumnComparator(for columnIndex: Int) -> ((Int, Int) -> ComparisonResult)? {
        return typedComparators?[columnIndex]
    }

    /// Returns whether a typed column is sortable (has extract or compare).
    /// Returns nil for non-typed columns.
    func getTypedColumnSortability(for columnIndex: Int) -> Bool? {
        return typedColumnSortabilities?[columnIndex]
    }
}
