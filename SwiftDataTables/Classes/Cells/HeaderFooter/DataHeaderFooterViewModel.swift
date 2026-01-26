//
//  DataHeaderFooterViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit


/// Indicates whether this view model is for a header or footer
public enum HeaderFooterType {
    case header
    case footer
}

@MainActor
public class DataHeaderFooterViewModel: DataTableSortable {

    //MARK: - Properties
    let data: String
    var indexPath: IndexPath! // Questionable
    var dataTable: SwiftDataTable!
    var headerFooterType: HeaderFooterType = .header

    public var sortType: DataTableSortType

    /// Whether the sorting indicator should be visible based on global config and header/footer type
    var shouldShowSortingIndicator: Bool {
        guard let options = dataTable?.options else { return true }
        switch headerFooterType {
        case .header:
            return options.shouldShowHeaderSortingIndicator
        case .footer:
            return options.shouldShowFooterSortingIndicator
        }
    }

    var imageStringForSortingElement: String? {
        guard shouldShowSortingIndicator else { return nil }
        switch self.sortType {
        case .hidden:
            return nil
        case .unspecified:
            return "column-sort-unspecified"
        case .ascending:
            return "column-sort-ascending"
        case .descending:
            return "column-sort-descending"
        }
    }
    var imageForSortingElement: UIImage? {
        guard let imageName = self.imageStringForSortingElement else {
            return nil
        }
        let bundle = Bundle(for: DataHeaderFooter.self)
        guard
            let url = bundle.url(forResource: "SwiftDataTables", withExtension: "bundle"),
            let imageBundle = Bundle(url: url),
            let imagePath = imageBundle.path(forResource: imageName, ofType: "png"),
            let image = UIImage(contentsOfFile: imagePath)?.withRenderingMode(.alwaysTemplate)
            else {
            return nil
        }
        return image
    }
    var tintColorForSortingElement: UIColor? {
        return (dataTable != nil && sortType != .unspecified) ? dataTable.options.sortArrowTintColor : UIColor.gray
    }
    
    //MARK: - Events
    
    //MARK: - Lifecycle
    init(data: String, sortType: DataTableSortType){
        self.data = data
        self.sortType = sortType
    }
    
    public func configure(dataTable: SwiftDataTable, columnIndex: Int, type: HeaderFooterType = .header){
        self.dataTable = dataTable
        self.indexPath = IndexPath(index: columnIndex)
        self.headerFooterType = type
    }
}

//MARK: - Header View Representable
extension DataHeaderFooterViewModel: CollectionViewSupplementaryElementRepresentable {
    static func registerHeaderFooterViews(collectionView: UICollectionView) {
        let identifier = String(describing: DataHeaderFooter.self)
        let headerNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(headerNib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = String(describing: DataHeaderFooter.self)
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? DataHeaderFooter
            else {
                return UICollectionReusableView()
        }
        
        headerView.configure(viewModel: self)
        switch kind {
        case SwiftDataTable.SupplementaryViewType.columnHeader.rawValue:
            headerView.didTapEvent = { [weak self] in
                self?.headerViewDidTap()
            }
        case SwiftDataTable.SupplementaryViewType.footerHeader.rawValue:
            headerView.didTapEvent = { [weak self] in
                self?.footerViewDidTap()
            }
        default:
            break
        }
        return headerView
    }
    
    //MARK: - Events
    func headerViewDidTap(){
        self.dataTable.didTapColumn(index: self.indexPath)
    }

    func footerViewDidTap(){
        guard dataTable.options.shouldFooterTriggerSorting else { return }
        self.dataTable.didTapColumn(index: self.indexPath)
    }
}
