//
//  CollectionViewCellRepresentable.swift
//  Drift
//
//  Created by Pavan Kataria on 26/07/2016.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CollectionViewCellRepresentable {
    static func registerCell(collectionView: UICollectionView)
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    @objc optional func sizeForItem(collectionView: UICollectionView, layout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize
    @objc optional func didSelectItem(collectionView: UICollectionView, indexPath: IndexPath)
    @objc optional func didEndDisplayingItem(collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath)
}
