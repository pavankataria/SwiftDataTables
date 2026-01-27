//
//  DataCellViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// View model for a data cell in the table.
///
/// `DataCellViewModel` wraps a `DataTableValueType` value and provides the logic
/// for registering, dequeuing, and configuring `DataCell` instances. It also
/// tracks layout position for the collection view layout engine.
///
/// ## Responsibilities
///
/// - Stores the cell's data value
/// - Tracks virtual position for layout calculations
/// - Handles cell registration and dequeuing
/// - Provides equality comparison for diffing
///
/// ## Layout Tracking
///
/// The `xPositionRunningTotal` and `yPositionRunningTotal` properties are used
/// by `SwiftDataTableLayout` to calculate cell positions without creating
/// actual frames until needed.
@MainActor
open class DataCellViewModel: VirtualPositionTrackable, DataTableCellRepresentable {

    // MARK: - Public Properties

    /// The cumulative horizontal position for layout calculations.
    var xPositionRunningTotal: CGFloat? = nil

    /// The cumulative vertical position for layout calculations.
    var yPositionRunningTotal: CGFloat? = nil

    /// The height this cell occupies in the layout.
    var virtualHeight: CGFloat = 0

    /// The data value this cell displays.
    public let data: DataTableValueType

    /// Whether this cell's column is currently highlighted (sorted).
    var highlighted: Bool = false

    /// The string representation of the cell's data.
    public var stringRepresentation: String {
        return self.data.stringRepresentation
    }

    // MARK: - Lifecycle

    /// Creates a new data cell view model.
    ///
    /// - Parameter data: The value to display in the cell.
    init(data: DataTableValueType) {
        self.data = data
    }

    // MARK: - DataTableCellRepresentable

    /// Registers the DataCell class with the collection view.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerCell(collectionView: UICollectionView) {
        let identifier = String(describing: DataCell.self)
        collectionView.register(DataCell.self, forCellWithReuseIdentifier: identifier)
        let nib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    /// Dequeues and configures a cell for display.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - indexPath: The index path for the cell.
    /// - Returns: A configured DataCell.
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: DataCell.self)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? DataCell else {
            fatalError("error in collection view cell")
        }
        cell.configure(self)
        return cell
    }
}

// MARK: - Equatable

extension DataCellViewModel: Equatable {

    /// Compares two view models for equality.
    ///
    /// Two view models are equal if they have the same data value and
    /// highlight state. Used by the diffing algorithm to detect changes.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side view model.
    ///   - rhs: The right-hand side view model.
    /// - Returns: `true` if the view models are equal.
    nonisolated public static func ==(lhs: DataCellViewModel, rhs: DataCellViewModel) -> Bool {
        MainActor.assumeIsolated {
            lhs.data == rhs.data && lhs.highlighted == rhs.highlighted
        }
    }
}
