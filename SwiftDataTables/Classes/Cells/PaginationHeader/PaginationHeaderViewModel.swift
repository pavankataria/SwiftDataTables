//
//  PaginationHeaderViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// View model for pagination controls (placeholder).
///
/// `PaginationHeaderViewModel` is a placeholder for future pagination
/// functionality. It will eventually manage:
/// - Current page state
/// - Total page count
/// - Page navigation events
///
/// ## Future Enhancement
///
/// Properties to be added:
/// - `currentPage: Int`
/// - `totalPages: Int`
/// - `pageSize: Int`
/// - `didSelectPage: ((Int) -> Void)?`
@MainActor
class PaginationHeaderViewModel {
}

// MARK: - DataTableSupplementaryElementRepresentable

extension PaginationHeaderViewModel: DataTableSupplementaryElementRepresentable {

    /// Registers the pagination header view class with the collection view.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerHeaderFooterViews(collectionView: UICollectionView) {
        let identifier = String(describing: PaginationHeader.self)
        let headerNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(headerNib, forCellWithReuseIdentifier: identifier)
    }

    /// Dequeues and configures a pagination header view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - kind: The supplementary view kind.
    ///   - indexPath: The index path for the view.
    /// - Returns: A configured PaginationHeader view.
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = String(describing: PaginationHeader.self)
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: identifier,
                for: indexPath
            ) as? PaginationHeader
        else {
            return UICollectionReusableView()
        }

        headerView.configure(self)
        return headerView
    }
}
