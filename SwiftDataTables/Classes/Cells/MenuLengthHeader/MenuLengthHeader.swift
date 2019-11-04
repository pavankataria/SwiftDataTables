//
//  MenuLengthHeader.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class MenuLengthHeader: UICollectionReusableView {
    
    //MARK: - Properties
    let searchBar = UISearchBar()

    //MARK: - Events
    var searchTextDidChange: ((String) -> Void)?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
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
    
    func configure(_ viewModel: MenuLengthHeaderViewModel){
//       self.searchTextField.addTarget(viewModel, action: #selector(MenuLengthHeaderViewModel.textFieldDidChange), for: .editingChanged)
        
        searchTextDidChange = { searchText in
            viewModel.searchTextFieldDidChangeEvent?(searchText)
        }
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"// - \(viewModel.count) names"
    }
}

extension MenuLengthHeader: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTextDidChange?(searchText)
    }
}
