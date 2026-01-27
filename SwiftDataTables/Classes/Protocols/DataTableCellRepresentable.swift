//
//  DataTableCellRepresentable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 26/07/2016.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// Internal protocol for view models that provide collection view cell configuration.
///
/// This protocol abstracts the registration, dequeuing, and configuration of
/// `UICollectionViewCell` instances. It enables view models to encapsulate
/// all cell-related logic, keeping the data table implementation clean.
///
/// ## Required Methods
///
/// - `registerCell(collectionView:)`: Called once to register the cell class.
/// - `dequeueCell(collectionView:indexPath:)`: Called to get a configured cell.
///
/// ## Optional Methods
///
/// - `sizeForItem(collectionView:layout:indexPath:)`: Custom cell sizing.
/// - `didSelectItem(collectionView:indexPath:)`: Handle cell selection.
/// - `didEndDisplayingItem(collectionView:cell:indexPath:)`: Cleanup on recycle.
@MainActor @objc protocol DataTableCellRepresentable {

    /// Registers the cell class or nib with the collection view.
    ///
    /// Called once during data table setup. Implementation should call
    /// `collectionView.register(_:forCellWithReuseIdentifier:)`.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerCell(collectionView: UICollectionView)

    /// Dequeues and configures a cell for the given index path.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - indexPath: The index path for the cell.
    /// - Returns: A fully configured cell ready for display.
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell

    /// Returns the size for the cell at the given index path.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - layout: The collection view layout.
    ///   - indexPath: The index path for the cell.
    /// - Returns: The size for the cell.
    @objc optional func sizeForItem(collectionView: UICollectionView, layout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize

    /// Called when a cell is selected.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - indexPath: The index path of the selected cell.
    @objc optional func didSelectItem(collectionView: UICollectionView, indexPath: IndexPath)

    /// Called when a cell is about to be recycled.
    ///
    /// Use for cleanup, cancelling async operations, etc.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - cell: The cell being recycled.
    ///   - indexPath: The index path the cell was at.
    @objc optional func didEndDisplayingItem(collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath)
}
