//
//  DataTableSupplementaryElementRepresentable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// Internal protocol for view models that provide supplementary view configuration.
///
/// This protocol abstracts the registration and dequeuing of supplementary views
/// (headers and footers) in the collection view. It enables view models to
/// encapsulate all supplementary view logic.
///
/// ## Implementation
///
/// Conforming types typically represent header or footer view models that know
/// how to configure their corresponding `UICollectionReusableView` subclass.
@MainActor @objc protocol DataTableSupplementaryElementRepresentable {

    /// Registers header and footer view classes with the collection view.
    ///
    /// Called once during data table setup. Implementation should call
    /// `collectionView.register(_:forSupplementaryViewOfKind:withReuseIdentifier:)`.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerHeaderFooterViews(collectionView: UICollectionView)

    /// Dequeues and configures a supplementary view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - kind: The kind of supplementary view (header or footer).
    ///   - indexPath: The index path for the view.
    /// - Returns: A fully configured supplementary view ready for display.
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView
}
