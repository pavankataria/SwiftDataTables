//
//  MenuLengthHeaderViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// View model for the embedded search bar header.
///
/// `MenuLengthHeaderViewModel` manages the search bar's state and forwards
/// search text changes to the data table for filtering.
///
/// ## Event Handling
///
/// The `searchTextFieldDidChangeEvent` closure is set by the data table
/// to receive search text updates. The closure is called whenever the
/// user types in the search bar.
@MainActor
class MenuLengthHeaderViewModel: NSObject {

    // MARK: - Events

    /// Closure called when search text changes.
    ///
    /// Set by the data table to receive filtering requests.
    var searchTextFieldDidChangeEvent: ((String) -> Void)? = nil
}

// MARK: - DataTableSupplementaryElementRepresentable

extension MenuLengthHeaderViewModel: DataTableSupplementaryElementRepresentable {

    /// Registers the search header view class with the collection view.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerHeaderFooterViews(collectionView: UICollectionView) {
        let identifier = String(describing: MenuLengthHeader.self)
        let headerNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(headerNib, forCellWithReuseIdentifier: identifier)
    }

    /// Dequeues and configures a search header view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - kind: The supplementary view kind.
    ///   - indexPath: The index path for the view.
    /// - Returns: A configured MenuLengthHeader view.
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = String(describing: MenuLengthHeader.self)
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: identifier,
                for: indexPath
            ) as? MenuLengthHeader
        else {
            return UICollectionReusableView()
        }

        headerView.configure(self)
        return headerView
    }
}

// MARK: - Text Field Handler

extension MenuLengthHeaderViewModel {

    /// Handles text field changes (legacy support).
    ///
    /// - Parameter textField: The text field that changed.
    @objc func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        self.searchTextFieldDidChangeEvent?(text)
    }
}

// MARK: - UISearchBarDelegate

extension MenuLengthHeaderViewModel: UISearchBarDelegate {
}
