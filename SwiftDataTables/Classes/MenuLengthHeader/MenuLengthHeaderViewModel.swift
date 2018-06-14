//
//  MenuLengthHeaderViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

class MenuLengthHeaderViewModel: NSObject {
    //MARK: - Events
    var searchTextFieldDidChangeEvent: ((String) -> Void)? = nil
}

extension MenuLengthHeaderViewModel: CollectionViewSupplementaryElementRepresentable {
    static func registerHeaderFooterViews(collectionView: UICollectionView) {
        let identifier = String(describing: MenuLengthHeader.self)
        let headerNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(headerNib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        
        let identifier = String(describing: MenuLengthHeader.self)
//        print("identifier at dequeue: \(identifier)")
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier:
                identifier,
                for: indexPath
                ) as? MenuLengthHeader
            else {
                return UICollectionReusableView()
        }
        
        headerView.setup(self)
        return headerView
    }
}

extension MenuLengthHeaderViewModel {
    @objc func textFieldDidChange(textField: UITextField){
        guard let text = textField.text else {
            return
        }
        self.searchTextFieldDidChangeEvent?(text)
    }
}

extension MenuLengthHeaderViewModel: UISearchBarDelegate {
    
}
