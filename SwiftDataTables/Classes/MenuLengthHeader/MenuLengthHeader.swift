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
    @IBOutlet var searchTextField: DataTableSearchTextField!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(_ viewModel: MenuLengthHeaderViewModel){
//        self.searchTextField.addTarget(viewModel, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        self.searchTextField.addTarget(viewModel, action: #selector(MenuLengthHeaderViewModel.textFieldDidChange), for: .editingChanged)
    }
}
