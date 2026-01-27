//
//  DataTableCellSizingMode.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

/// Defines how cell sizes are determined in the data table.
///
/// `DataTableCellSizingMode` controls whether cells use the default text-based
/// sizing or custom Auto Layout-based sizing with custom cell types.
///
/// ## Usage
///
/// Configure via `DataTableConfiguration`:
/// ```swift
/// var config = DataTableConfiguration()
///
/// // Default text cells (default)
/// config.cellSizingMode = .defaultCell
///
/// // Custom cells with Auto Layout
/// config.cellSizingMode = .autoLayout(provider: myProvider)
/// ```
///
/// ## Choosing a Mode
///
/// - `.defaultCell`: Use when displaying simple text data. Best performance.
/// - `.autoLayout`: Use when you need custom cell types with images, buttons,
///   or complex layouts. Requires a `DataTableCustomCellProvider`.
public enum DataTableCellSizingMode: Equatable {

    /// Uses the default text-based cell with standard sizing.
    ///
    /// Cells display text content with configurable truncation and wrapping.
    /// This is the most performant option for text-only data.
    ///
    /// Configure text appearance via `DataTableConfiguration.textLayout`.
    case defaultCell

    /// Uses custom cells with Auto Layout-based sizing.
    ///
    /// Enables custom `UICollectionViewCell` subclasses for rich content
    /// like images, badges, buttons, or complex layouts.
    ///
    /// - Parameter provider: The custom cell provider that handles cell
    ///   registration, configuration, and sizing.
    ///
    /// Example:
    /// ```swift
    /// let provider = DataTableCustomCellProvider(
    ///     register: { cv in cv.register(MyCell.self, forCellWithReuseIdentifier: "My") },
    ///     reuseIdentifierFor: { _ in "My" },
    ///     configure: { cell, value, _ in (cell as? MyCell)?.configure(value) },
    ///     sizingCellFor: { _ in MyCell() }
    /// )
    /// config.cellSizingMode = .autoLayout(provider: provider)
    /// ```
    ///
    /// - Note: Auto Layout sizing may have performance implications with
    ///   very large datasets. Consider using estimated row heights and
    ///   lazy measurement for best scrolling performance.
    case autoLayout(provider: DataTableCustomCellProvider)

    /// Compares two cell sizing modes for equality.
    ///
    /// Two modes are equal if they are the same case. For `.autoLayout`,
    /// equality is based on the case only, not the provider contents
    /// (since closures cannot be compared).
    public static func == (lhs: DataTableCellSizingMode, rhs: DataTableCellSizingMode) -> Bool {
        switch (lhs, rhs) {
        case (.defaultCell, .defaultCell):
            return true
        case (.autoLayout, .autoLayout):
            return true
        default:
            return false
        }
    }
}

// MARK: - Convenience Properties

extension DataTableCellSizingMode {

    /// Whether this mode uses Auto Layout for cell sizing.
    ///
    /// Returns `true` for `.autoLayout`, `false` for `.defaultCell`.
    var usesAutoLayout: Bool {
        switch self {
        case .autoLayout:
            return true
        case .defaultCell:
            return false
        }
    }
}
