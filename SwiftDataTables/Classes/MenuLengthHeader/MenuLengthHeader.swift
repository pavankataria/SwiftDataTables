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


    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(_ viewModel: MenuLengthHeaderViewModel){
//       self.searchTextField.addTarget(viewModel, action: #selector(MenuLengthHeaderViewModel.textFieldDidChange), for: .editingChanged)
        self.searchBar.delegate = viewModel
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.placeholder = "Search"// - \(viewModel.count) names"
    }
}
