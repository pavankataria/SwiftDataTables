//
//  MenuLengthHeader.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Reusable view containing the embedded search bar for the data table.
///
/// `MenuLengthHeader` displays a search bar that allows users to filter
/// table content. It's shown at the top of the table when
/// `shouldShowSearchSection` is enabled and `searchBarPosition` is `.embedded`.
///
/// ## Layout
///
/// The search bar fills the entire view with edge-to-edge constraints.
/// The view height is controlled by `DataTableConfiguration.heightForSearchView`.
///
/// ## Search Events
///
/// Text changes are forwarded to `MenuLengthHeaderViewModel` via the
/// `searchTextDidChange` closure, which then triggers table filtering.
class MenuLengthHeader: UICollectionReusableView {

    // MARK: - Properties

    /// The search bar for filtering table content.
    let searchBar = UISearchBar()

    // MARK: - Events

    /// Closure called when search text changes.
    var searchTextDidChange: ((String) -> Void)?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    // MARK: - Configuration

    /// Configures the view with a view model.
    ///
    /// - Parameter viewModel: The view model containing search event handlers.
    func configure(_ viewModel: MenuLengthHeaderViewModel) {
        searchTextDidChange = { searchText in
            viewModel.searchTextFieldDidChangeEvent?(searchText)
        }
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
    }
}

// MARK: - UISearchBarDelegate

extension MenuLengthHeader: UISearchBarDelegate {

    /// Forwards text changes to the search handler.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTextDidChange?(searchText)
    }
}
