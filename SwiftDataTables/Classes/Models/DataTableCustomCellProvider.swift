//
//  DataTableCustomCellProvider.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

/// Provides custom cell rendering for data table columns.
///
/// `DataTableCustomCellProvider` allows you to use custom `UICollectionViewCell`
/// subclasses instead of the default text-based cells. This enables rich content
/// like images, buttons, badges, and complex layouts.
///
/// ## Usage
///
/// 1. Define your custom cell class:
/// ```swift
/// class UserAvatarCell: UICollectionViewCell {
///     static let reuseIdentifier = "UserAvatarCell"
///     let imageView = UIImageView()
///     // ... setup code
/// }
/// ```
///
/// 2. Create the provider:
/// ```swift
/// let provider = DataTableCustomCellProvider(
///     register: { collectionView in
///         collectionView.register(UserAvatarCell.self,
///             forCellWithReuseIdentifier: UserAvatarCell.reuseIdentifier)
///     },
///     reuseIdentifierFor: { indexPath in
///         return indexPath.section == 0 ? UserAvatarCell.reuseIdentifier : "DataCell"
///     },
///     configure: { cell, value, indexPath in
///         if let avatarCell = cell as? UserAvatarCell {
///             avatarCell.configure(with: value)
///         }
///     },
///     sizingCellFor: { identifier in
///         return UserAvatarCell()
///     }
/// )
/// ```
///
/// 3. Apply to configuration:
/// ```swift
/// var config = DataTableConfiguration()
/// config.cellSizingMode = .autoLayout(provider: provider)
/// ```
///
/// ## Sizing
///
/// The `sizingCellFor` closure provides cells for Auto Layout measurement.
/// These cells should be configured identically to displayed cells but are
/// never added to the view hierarchy. Cache these for performance:
///
/// ```swift
/// private var sizingCells: [String: UICollectionViewCell] = [:]
///
/// sizingCellFor: { [weak self] identifier in
///     if let cached = self?.sizingCells[identifier] {
///         return cached
///     }
///     let cell = UserAvatarCell()
///     self?.sizingCells[identifier] = cell
///     return cell
/// }
/// ```
public struct DataTableCustomCellProvider {

    /// Registers custom cell classes with the collection view.
    ///
    /// Called once when the data table is initialized. Register all
    /// custom cell classes you plan to use:
    /// ```swift
    /// register: { collectionView in
    ///     collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: "Avatar")
    ///     collectionView.register(BadgeCell.self, forCellWithReuseIdentifier: "Badge")
    /// }
    /// ```
    public let register: @MainActor (UICollectionView) -> Void

    /// Returns the reuse identifier for the cell at a given index path.
    ///
    /// Use the index path to determine which cell type to use:
    /// ```swift
    /// reuseIdentifierFor: { indexPath in
    ///     switch indexPath.section {
    ///     case 0: return "AvatarCell"
    ///     case 5: return "ActionCell"
    ///     default: return "DataCell"
    ///     }
    /// }
    /// ```
    ///
    /// - Note: `indexPath.section` corresponds to the column index,
    ///   `indexPath.row` to the data row index.
    public let reuseIdentifierFor: @MainActor (IndexPath) -> String

    /// Configures a cell with its data value.
    ///
    /// Called each time a cell is dequeued and needs configuration:
    /// ```swift
    /// configure: { cell, value, indexPath in
    ///     if let avatarCell = cell as? AvatarCell {
    ///         avatarCell.setImage(from: value.stringRepresentation)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cell: The dequeued cell to configure.
    ///   - value: The data value for this cell.
    ///   - indexPath: The cell's position (section = column, row = data row).
    public let configure: @MainActor (UICollectionViewCell, DataTableValueType, IndexPath) -> Void

    /// Returns a sizing cell for Auto Layout measurement.
    ///
    /// Provides a cell instance for calculating dimensions. The returned
    /// cell should be set up identically to displayed cells but is never
    /// added to the view hierarchy.
    ///
    /// - Parameter identifier: The reuse identifier for the cell type.
    /// - Returns: A cell instance for measurement.
    ///
    /// - Important: For performance, cache and reuse sizing cells rather
    ///   than creating new instances each time.
    public let sizingCellFor: @MainActor (String) -> UICollectionViewCell

    /// Creates a new custom cell provider.
    ///
    /// - Parameters:
    ///   - register: Closure to register cell classes with the collection view.
    ///   - reuseIdentifierFor: Closure returning the cell identifier for an index path.
    ///   - configure: Closure to configure a cell with its data.
    ///   - sizingCellFor: Closure returning a sizing cell for measurement.
    public init(
        register: @escaping @MainActor (UICollectionView) -> Void,
        reuseIdentifierFor: @escaping @MainActor (IndexPath) -> String,
        configure: @escaping @MainActor (UICollectionViewCell, DataTableValueType, IndexPath) -> Void,
        sizingCellFor: @escaping @MainActor (String) -> UICollectionViewCell
    ) {
        self.register = register
        self.reuseIdentifierFor = reuseIdentifierFor
        self.configure = configure
        self.sizingCellFor = sizingCellFor
    }
}
