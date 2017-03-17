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
//    @IBOutlet var searchTextField: DataTableSearchTextField!
    @IBOutlet var searchBar: UISearchBar!

    //MARK: - Events
    var searchTextDidChange: ((String) -> Void)?
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(_ viewModel: MenuLengthHeaderViewModel){
//       self.searchTextField.addTarget(viewModel, action: #selector(MenuLengthHeaderViewModel.textFieldDidChange), for: .editingChanged)
        
        self.searchTextDidChange = { searchText in
            viewModel.searchTextFieldDidChangeEvent?(searchText)
        }
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.placeholder = "Search"// - \(viewModel.count) names"
    }
}

extension MenuLengthHeader: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTextDidChange?(searchText)
    }
}
