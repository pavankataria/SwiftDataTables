//
//  CollectionViewSupplementaryElementRepresentable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CollectionViewSupplementaryElementRepresentable {
    static func registerHeaderFooterViews(collectionView: UICollectionView)
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView
}
