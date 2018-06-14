//
//  SwiftDataTable+Extensions.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

public extension IndexPath {
    /// An index number for single matrix indexPath
    var index: Int {
        return self[0]
    }
}
//public extension Collection where Self.Index == Int {
extension Collection where Indices.Iterator.Element == Index {

    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIScrollView {
    /// Sets content offset to the top.
    func resetScrollPositionToTop() {
        self.contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }
}
