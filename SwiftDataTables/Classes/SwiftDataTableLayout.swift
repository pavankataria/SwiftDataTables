//
//  SwiftDataTableLayout.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 21/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class SwiftDataTableLayout: UICollectionViewLayout {
    
    //MARK: - Properties
    fileprivate(set) open var dataTable: SwiftDataTable
    var insertedIndexPaths = NSMutableArray()
    var removedIndexPaths = NSMutableArray()
    var insertedSectionIndices = NSMutableArray()
    var removedSectionIndices = NSMutableArray()
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var filteredCache = [UICollectionViewLayoutAttributes]()
//    private var filteredCache = [UICollectionViewLayoutAttributes]()
    
    //MARK: - Lifecycle
    init(dataTable: SwiftDataTable){
        self.dataTable = dataTable
        super.init()
//        self.collectionView?.isPrefetchingEnabled = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func clearLayoutCache(){
        self.cache.removeAll()
    }
    
    public override func prepare(){
        super.prepare()
        
        guard self.cache.isEmpty else {
            return
        }
        let date = Date()
        self.dataTable.calculateColumnWidths()
        var xOffsets = [CGFloat]()
        var yOffsets = [CGFloat]()
        
        //Reduces the computation by working out one column
        for column in 0..<self.dataTable.numberOfColumns() {
            let currentColumnXOffset = Array(0..<column).reduce(self.dataTable.widthForRowHeader()) {
                $0 + self.dataTable.widthForColumn(index: $1)
            }
            xOffsets.append(currentColumnXOffset)
        }
        
        //Reduces the computation by calculating the height offset against one column
        let defaultUpperHeight = /*self.dataTable.heightForSearchView() + */self.dataTable.heightForSectionHeader()
        
        var counter = 0
        for row in Array(0..<self.dataTable.numberOfRows()){
            counter += 1
            let currentRowYOffset = Array(0..<row).reduce(defaultUpperHeight) { $0 + self.dataTable.heightForRow(index: $1) + self.dataTable.heightOfInterRowSpacing() }
            yOffsets.append(currentRowYOffset)
        }
        
        
        //Item equals the current item in the row
        for row in Array(0..<self.dataTable.numberOfRows()){
            for item in Array(0..<self.dataTable.numberOfColumns()) {
                let width = self.dataTable.widthForColumn(index: item)

                let indexPath = IndexPath(item: item, section: row)
                //Should this method call be used or is keeping an array of row heights more efficcient?
                let height = self.dataTable.heightForRow(index: row)
                
                let frame = CGRect(x: xOffsets[item], y: yOffsets[row], width: width, height: height)
//                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame//insetFrame
                cache.append(attributes)
            }
        }
        self.calculateScrollBarIndicators()
        let timeLapsed = Date().timeIntervalSince(date)
        print("\ntime lapsed: \(timeLapsed)\nfor \(self.cache.count) rows\n")
    }
    
    fileprivate func heightOfFooter() -> CGFloat {
        return self.dataTable.shouldShowFooterSection() == false ? 0 : self.dataTable.shouldSectionFootersFloat() ? self.dataTable.heightForSectionFooter() + self.dataTable.heightForPaginationView() : 0
    }
    
    func calculateScrollBarIndicators(){
        let bottomPadding = heightOfFooter()
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(
            top: self.dataTable.shouldSectionHeadersFloat() ? self.dataTable.heightForSectionHeader()/* + self.dataTable.heightForSearchView()*/: 0,
            left: 0,
            bottom: bottomPadding,
            right: 0
        )
        self.collectionView?.showsVerticalScrollIndicator = self.dataTable.showVerticalScrollBars()
        self.collectionView?.showsHorizontalScrollIndicator = self.dataTable.showHorizontalScrollBars()
    }
    
    override var collectionViewContentSize: CGSize {
        let width = self.dataTable.calculateContentWidth()
        let height = Array(0..<self.dataTable.numberOfRows()).reduce(self.dataTable.heightForSectionHeader() + self.heightOfFooter()/* + self.dataTable.heightForSearchView()*/) {
                $0 + self.dataTable.heightForRow(index: $1) + self.dataTable.heightOfInterRowSpacing()
        }
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        //Item Cells
        let minY = rect.minY-rect.height
        var attributes = [UICollectionViewLayoutAttributes]()
//
        let firstMatchIndex = binarySearchAttributes(self.cache, value: minY)
        for att in self.cache[..<firstMatchIndex].reversed() {
            guard att.frame.maxY >= rect.minY else { break }
            attributes.append(att)
        }
        for att in self.cache[firstMatchIndex...] {
            guard att.frame.minY <= rect.maxY else { break }
            attributes.append(att)
        }
//        //MARK: Search Header
//        if self.dataTable.shouldShowSearchSection(){
//            let menuLengthIndexPath = IndexPath(index: 0)
//            if let menuLengthAttributes = self.layoutAttributesForSupplementaryView(ofKind:
//                SwiftDataTable.SupplementaryViewType.searchHeader.rawValue, at: menuLengthIndexPath){
//                attributes.append(menuLengthAttributes)
//            }
//        }

        //MARK: Column Headers
        for i in 0..<self.dataTable.numberOfHeaderColumns() {
            let headerIndexPath = IndexPath(index: i)
            if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind: SwiftDataTable.SupplementaryViewType.columnHeader.rawValue, at: headerIndexPath){
                attributes.append(headerAttributes)
            }
        }
        
        //MARK: Column Footers
        if self.dataTable.shouldShowFooterSection() {
            for i in 0..<self.dataTable.numberOfFooterColumns() {
                let footerIndexPath = IndexPath(index: i)
                if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind: SwiftDataTable.SupplementaryViewType.footerHeader.rawValue, at: footerIndexPath){
                    attributes.append(footerAttributes)
                }
            }
        }
        
        //MARK: Pagination
        if self.dataTable.shouldShowPaginationSection() {
            let paginationIndexPath = IndexPath(index: 0)
            if let paginationAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                SwiftDataTable.SupplementaryViewType.paginationHeader.rawValue, at: paginationIndexPath){
                attributes.append(paginationAttributes)
            }
        }
        return attributes
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

//MARK: - Layout Attributes For Elements And Supplmentary Views
extension SwiftDataTableLayout {
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let initialRowYPosition = /*self.dataTable.heightForSearchView() + */self.dataTable.heightForSectionHeader()
        
        let x: CGFloat = Array(0..<indexPath.row).reduce(self.dataTable.widthForRowHeader()) { $0 + self.dataTable.widthForColumn(index: $1)}
        let y = initialRowYPosition + CGFloat(Int(self.dataTable.heightForRow(index: 0)) * indexPath.section)
        let width = self.dataTable.widthForColumn(index: indexPath.row)
        let height = self.dataTable.heightForRow(index: indexPath.section)
        
        attributes.frame = CGRect(
            x: max(0, x),
            y: max(0, y),
            width: width,
            height: height
        )
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let kind = SwiftDataTable.SupplementaryViewType(kind: elementKind)
        switch kind {
        case .searchHeader: return self.layoutAttributesForHeaderView(at: indexPath)
        case .columnHeader: return self.layoutAttributesForColumnHeaderView(at: indexPath)
        case .footerHeader: return self.layoutAttributesForColumnFooterView(at: indexPath)
        case .paginationHeader:  return self.layoutAttributesForPaginationView(at: indexPath)
        }
    }
    
    func layoutAttributesForHeaderView(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SwiftDataTable.SupplementaryViewType.searchHeader.rawValue, with: indexPath)
        let x: CGFloat = self.dataTable.collectionView.contentOffset.x
        let y: CGFloat = 0
        let width = self.dataTable.collectionView.bounds.width
        let height: CGFloat = 0//self.dataTable.heightForSearchView()
        
        attribute.frame = CGRect(
            x: max(0, x),
            y: max(0, y),
            width: width,
            height: height
        )
        attribute.zIndex = 5
        
        if self.dataTable.shouldSearchHeaderFloat(){
            let yOffsetTopView: CGFloat = self.dataTable.collectionView.contentOffset.y
            attribute.frame.origin.y = yOffsetTopView
            attribute.zIndex += 1
        }
        return attribute
    }
    
    func layoutAttributesForColumnHeaderView(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SwiftDataTable.SupplementaryViewType.columnHeader.rawValue, with: indexPath)
        //Because the widths can change between columns we need to get a running total for the x position so far up
        //until the currnt column header.
        let x = Array(0..<indexPath.index).reduce(self.dataTable.widthForRowHeader()){$0 + self.dataTable.widthForColumn(index: $1)}
        let y: CGFloat = self.collectionView!.contentOffset.y//self.dataTable.heightForSearchView() /*self.dataTable.heightForPaginationView()*/
        let width = self.dataTable.widthForColumn(index: indexPath.index)
        let height = self.dataTable.heightForSectionHeader()
        attribute.frame = CGRect(
            x: max(0.0, x),
            y: min(0, y),
            width: width,
            height: height
        )
        
        attribute.zIndex = 2
        
//        //This should call the delegate method whether or not the headers should float.
//        if self.dataTable.shouldSectionHeadersFloat() {
//            var yScrollOffsetPosition = /*self.dataTable.heightForSearchView() + */self.collectionView!.contentOffset.y
//            if false == self.dataTable.shouldSearchHeaderFloat(){
//                yScrollOffsetPosition = max(0/*self.dataTable.heightForSearchView()*/, self.collectionView!.contentOffset.y)
//            }
//            attribute.frame.origin.y = yScrollOffsetPosition//max(yScrollOffsetPosition, attribute.frame.origin.y)
//            attribute.zIndex += 1
//        }
        
        //This should call the delegate method whether or not the headers should float.
        if self.dataTable.shouldSectionHeadersFloat() {
            let yScrollOffsetPosition = self.collectionView!.contentOffset.y
            attribute.frame.origin.y = yScrollOffsetPosition
            attribute.zIndex += 1
        }
        return attribute
    }
    
    func layoutAttributesForColumnFooterView(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SwiftDataTable.SupplementaryViewType.footerHeader.rawValue, with: indexPath)

        let width = self.dataTable.widthForColumn(index: indexPath.index)
        let height = self.dataTable.heightForSectionFooter()

        let x = Array(0..<indexPath.index).reduce(self.dataTable.widthForRowHeader()){$0 + self.dataTable.widthForColumn(index: $1)}
        let y: CGFloat = self.collectionView!.contentSize.height - height

        attribute.frame = CGRect(
            x: max(0, x),
            y: y,
            width: width,
            height: height
        )
        
        attribute.zIndex = 2
        //This should call the delegate method whether or not the headers should float.
        if self.dataTable.shouldSectionFootersFloat(){
            let yOffsetBottomView: CGFloat = self.collectionView!.contentOffset.y + self.collectionView!.bounds.height - height - self.dataTable.heightForPaginationView() // - height
            attribute.frame.origin.y = yOffsetBottomView
            attribute.zIndex += 1
        }
        return attribute
    }
    
    func layoutAttributesForPaginationView(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SwiftDataTable.SupplementaryViewType.paginationHeader.rawValue, with: indexPath)
        
        let x: CGFloat = self.dataTable.collectionView.contentOffset.x
        let y: CGFloat = 0
        
        let width = self.dataTable.collectionView.bounds.width
        let height = self.dataTable.heightForPaginationView()
        
        attribute.frame = CGRect(
            x: max(0, x),
            y: max(0, y),
            width: width,
            height: height
        )
        attribute.zIndex = 5
        
        if self.dataTable.shouldSectionHeadersFloat(){
            let yOffsetBottomView: CGFloat = self.dataTable.collectionView.contentOffset.y + self.dataTable.collectionView.bounds.height - height // - height
            attribute.frame.origin.y = yOffsetBottomView
            attribute.zIndex += 1
        }
        return attribute
    }
    
    private func binarySearchAttributes(_ attributes: [UICollectionViewLayoutAttributes], value: CGFloat) -> Int {
        var imin = 0, imax = attributes.count
        while imin < imax {
            let imid = imin + (imax - imin)/2
            
            if attributes[imid].frame.minY < value {
                imin = imid+1
            }
            else {
                imax = imid
            }
        }
        return imin
    }
}
