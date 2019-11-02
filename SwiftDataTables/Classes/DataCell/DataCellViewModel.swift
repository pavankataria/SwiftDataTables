//
//  DataCellViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

open class DataCellViewModel: VirtualPositionTrackable, CollectionViewCellRepresentable {
    //MARK: - Private Properties
    private var dataTableConfiguration: DataTableConfiguration?

    //MARK: - Public Properties
    var xPositionRunningTotal: CGFloat?  = nil
    var yPositionRunningTotal: CGFloat?  = nil
    var virtualHeight: CGFloat = 0
    public let data: DataTableValueType
    var highlighted: Bool = false
    //
    public var stringRepresentation: String {
        return self.data.stringRepresentation
    }

    public var shouldShowDataBorders: Bool? {
        return dataTableConfiguration?.shouldShowDataBorders ?? false
    }

    public var dataTextAlignement: NSTextAlignment? {
        return dataTableConfiguration?.dataTextAlignment ?? .natural
    }

    //MARK: - Lifecycle
    init(data: DataTableValueType, dataTableConfiguration: DataTableConfiguration?){
        self.data = data
        self.dataTableConfiguration = dataTableConfiguration
    }
    
    static func registerCell(collectionView: UICollectionView) {
        let identifier = String(describing: DataCell.self)
        let nib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: DataCell.self)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? DataCell else {
            fatalError("error in collection view cell")
        }
        cell.setup(self)
        return cell
    }
}
extension DataCellViewModel: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: DataCellViewModel, rhs: DataCellViewModel) -> Bool {
        return lhs.data == rhs.data
        && lhs.highlighted == rhs.highlighted
    }

}
