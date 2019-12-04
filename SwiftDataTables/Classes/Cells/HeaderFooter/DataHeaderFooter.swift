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
    private enum Properties {
        static let labelHorizontalMargin: CGFloat = 15
        static let labelVerticalMargin: CGFloat = 5
        static let separator: CGFloat = 5
        static let imageViewHorizontalMargin: CGFloat = 5
        static let labelWidthConstant: CGFloat = 20
        static let imageViewWidthConstant: CGFloat = 20
        static let imageViewAspectRatio: CGFloat = 0.75

        
    }
    let titleLabel = UILabel()
    let sortingImageView = UIImageView()


    //MARK: - Events
    var didTapEvent: (() -> Void)? = nil

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
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        addSubview(titleLabel)
        addSubview(sortingImageView)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(DataHeaderFooter.didTapView))
        addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Properties.labelWidthConstant),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Properties.labelVerticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Properties.labelHorizontalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Properties.labelVerticalMargin),
            sortingImageView.widthAnchor.constraint(equalToConstant: Properties.imageViewWidthConstant),
            sortingImageView.widthAnchor.constraint(equalTo: sortingImageView.heightAnchor, multiplier: Properties.imageViewAspectRatio),
            sortingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Properties.imageViewHorizontalMargin),
            sortingImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Properties.separator),
        ])
    }
    
    func configure(viewModel: DataHeaderFooterViewModel) {
        self.titleLabel.text = viewModel.data
        self.sortingImageView.image = viewModel.imageForSortingElement
        self.sortingImageView.tintColor = viewModel.tintColorForSortingElement
        self.backgroundColor = .white
    }
    @objc func didTapView(){
        self.didTapEvent?()
    }
}
