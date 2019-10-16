//
//  DataHeaderFooter.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class DataHeaderFooter: UICollectionReusableView {

    //MARK: - Properties
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var sortingImageView: UIImageView!

    //MARK: - Events
    var didTapEvent: (() -> Void)? = nil

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(DataHeaderFooter.didTapView))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setup(viewModel: DataHeaderFooterViewModel) {
        self.titleLabel.text = viewModel.data
        self.titleLabel.textAlignment = viewModel.headerFooterTextAlignment ?? .natural
        self.sortingImageView.image = viewModel.imageForSortingElement
        self.sortingImageView.tintColor = viewModel.tintColorForSortingElement
        self.backgroundColor = .white
        self.backgroundView.backgroundColor = viewModel.backgroundColorForHeaderFooter ?? UIColor.clear
        guard let showBorders = viewModel.shouldShowHeaderFooterBorders else { return }
        if showBorders {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.black.cgColor
        }
    }
    @objc func didTapView(){
        self.didTapEvent?()
    }
}
