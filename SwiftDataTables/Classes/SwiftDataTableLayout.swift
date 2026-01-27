//
//  SwiftDataTableLayout.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 21/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Custom collection view layout for the data table.
///
/// `SwiftDataTableLayout` manages the complex layout requirements of the data table,
/// including:
/// - Variable column widths based on content
/// - Fixed (frozen) columns
/// - Floating headers and footers
/// - Lazy row height measurement for automatic heights
/// - Scroll anchoring for stable scrolling
///
/// ## Layout Structure
///
/// The layout organizes content into sections where each section represents a column.
/// Items within a section represent cells in that column across all rows.
///
/// ## Performance
///
/// For large datasets, the layout supports lazy measurement where row heights
/// are calculated as rows become visible, using estimated heights for
/// unmeasured rows.
class SwiftDataTableLayout: UICollectionViewFlowLayout {

    //MARK: - Properties
    fileprivate(set) open var dataTable: SwiftDataTable
    var insertedIndexPaths = NSMutableArray()
    var removedIndexPaths = NSMutableArray()
    var insertedSectionIndices = NSMutableArray()
    var removedSectionIndices = NSMutableArray()

    // Column layout metadata (row metrics now come from metricsStore)
    private var cachedColumnXOffsets = [CGFloat]()
    private var cachedColumnWidths = [CGFloat]()
    private var needsMetadataUpdate = true

    // MARK: - Row Metrics Store (Single Source of Truth)
    /// Non-optional access to row metrics store. Asserts if accessed before dataTable is ready.
    var metricsStore: RowMetricsStore {
        return dataTable.rowMetricsStore
    }

    //MARK: - Lifecycle
    init(dataTable: SwiftDataTable){
        self.dataTable = dataTable
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func clearLayoutCache() {
        needsMetadataUpdate = true
    }

    public override func prepare() {
        super.prepare()

        guard needsMetadataUpdate else { return }

        self.dataTable.calculateColumnWidths()
        prepareMetadata()
        self.calculateScrollBarIndicators()
        needsMetadataUpdate = false
    }

    /// Prepares column metadata. Row metrics come from metricsStore (single source of truth).
    private func prepareMetadata() {
        let numberOfColumns = self.dataTable.numberOfColumns()

        // Calculate column X offsets
        cachedColumnXOffsets.removeAll(keepingCapacity: true)
        cachedColumnXOffsets.reserveCapacity(numberOfColumns)
        var runningX = self.dataTable.widthForRowHeader()
        for column in 0..<numberOfColumns {
            cachedColumnXOffsets.append(runningX)
            runningX += self.dataTable.widthForColumn(index: column)
        }

        // Calculate column widths
        cachedColumnWidths.removeAll(keepingCapacity: true)
        cachedColumnWidths.reserveCapacity(numberOfColumns)
        for column in 0..<numberOfColumns {
            cachedColumnWidths.append(self.dataTable.widthForColumn(index: column))
        }

        // Row heights and Y offsets now come from metricsStore (populated by SwiftDataTable.calculateRowHeights())
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
        // Safety check: if metricsStore is stale (row count mismatch), rebuild
        let numberOfRows = self.dataTable.numberOfRows()
        if metricsStore.rowCount != numberOfRows && numberOfRows > 0 {
            self.dataTable.calculateColumnWidths()
            prepareMetadata()
        }

        // Use metricsStore for O(1) content height lookup
        let width = self.dataTable.calculateContentWidth()
        let height = metricsStore.contentHeight
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()

        let numberOfRows = self.dataTable.numberOfRows()
        let numberOfColumns = self.dataTable.numberOfColumns()

        guard numberOfRows > 0, numberOfColumns > 0 else {
            return attributes
        }

        // Safety check: if row count changed, recalculate metadata
        if metricsStore.rowCount != numberOfRows {
            self.dataTable.calculateColumnWidths()
            prepareMetadata()
        }

        // Binary search to find first visible row using metricsStore
        let firstVisibleRow = metricsStore.rowForYOffset(rect.minY)
        let lastVisibleRow = metricsStore.rowForYOffset(rect.maxY)

        // Generate attributes on-demand for visible rows only
        for row in firstVisibleRow...min(lastVisibleRow, numberOfRows - 1) {
            let y = metricsStore.yOffsetForRow(row)
            let height = metricsStore.heightForRow(row)

            // Skip rows that are completely outside the rect
            guard y + height >= rect.minY && y <= rect.maxY else { continue }

            for column in 0..<numberOfColumns {
                guard column < cachedColumnXOffsets.count, column < cachedColumnWidths.count else { continue }

                let indexPath = IndexPath(item: column, section: row)
                let frame = CGRect(
                    x: cachedColumnXOffsets[column],
                    y: y,
                    width: cachedColumnWidths[column],
                    height: height
                )
                let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                cellAttributes.frame = frame

                if let adjusted = adjustAttributesPosition(cellAttributes, at: column, zIndexPosition: 1) {
                    attributes.append(adjusted)
                }
            }
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

    // MARK: - Batch Update Support

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        // Check if there are section-level changes
        for item in updateItems {
            if item.indexPathBeforeUpdate?.item == NSNotFound || item.indexPathAfterUpdate?.item == NSNotFound {
                // Section-level update - recalculate metadata immediately
                // This ensures layout attributes are correct during batch animation
                self.dataTable.calculateColumnWidths()
                prepareMetadata()
                break
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertedIndexPaths.removeAllObjects()
        removedIndexPaths.removeAllObjects()
        insertedSectionIndices.removeAllObjects()
        removedSectionIndices.removeAllObjects()
    }
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return dataTable.shouldSupportRightToLeftInterfaceDirection() ? UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft : false
    }
}

//MARK: - Layout Attributes For Elements And Supplmentary Views
extension SwiftDataTableLayout {
    func adjustAttributesPosition(_ attributes: UICollectionViewLayoutAttributes?, at columnIndex: Int, zIndexPosition: Int) -> UICollectionViewLayoutAttributes? {
        guard let attributes = attributes else { return nil }
        guard let fixedColumns = self.dataTable.fixedColumns() else {
            return attributes
        }
        guard let fixedColumnSide = fixedColumns.hitTest(columnIndex, totalTableColumnCount: dataTable.numberOfColumns()) else {
            return attributes
        }
        var xOffset: CGFloat = self.dataTable.collectionView.contentOffset.x
        switch fixedColumnSide {
        case .left:
            let x = Array(0..<columnIndex).reduce(self.dataTable.widthForRowHeader()){$0 + self.dataTable.widthForColumn(index: $1)}
            xOffset = xOffset + x
        case .right:
            let x = Array(columnIndex..<dataTable.numberOfColumns()).reduce(self.dataTable.widthForRowHeader()){$0 + self.dataTable.widthForColumn(index: $1)}
            xOffset = self.dataTable.frame.width + xOffset - x
        }
        attributes.frame.origin.x = xOffset
        attributes.zIndex = zIndexPosition
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let row = indexPath.section
        let column = indexPath.item

        // Safety check: if row count changed, recalculate metadata
        let numberOfRows = self.dataTable.numberOfRows()
        if metricsStore.rowCount != numberOfRows {
            self.dataTable.calculateColumnWidths()
            prepareMetadata()
        }

        // Use cached values for columns, metricsStore for rows
        let x: CGFloat
        let width: CGFloat
        if column < cachedColumnXOffsets.count && column < cachedColumnWidths.count {
            x = cachedColumnXOffsets[column]
            width = cachedColumnWidths[column]
        } else {
            x = Array(0..<column).reduce(self.dataTable.widthForRowHeader()) { $0 + self.dataTable.widthForColumn(index: $1) }
            width = self.dataTable.widthForColumn(index: column)
        }

        // Row metrics from metricsStore (single source of truth)
        let y = metricsStore.yOffsetForRow(row)
        let height = metricsStore.heightForRow(row)

        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: max(0, x), y: max(0, y), width: width, height: height)

        return adjustAttributesPosition(attributes, at: column, zIndexPosition: 1)
    }
//    func adjustSupplementaryView(attributes: UICollectionViewLayoutAttributes?, at columnPosition: Int) -> UICollectionViewLayoutAttributes? {
//        guard let attributes = attributes else { return nil }
//        if columnPosition == 0 || columnPosition == 1 {
//            let x = Array(0..<columnPosition).reduce(self.dataTable.widthForRowHeader()){$0 + self.dataTable.widthForColumn(index: $1)}
////            let columnWidth = dataTable.widthForColumn(index: columnPosition)
//            let xOffset = dataTable.collectionView.contentOffset.x + x
//            attributes.frame.origin.x = xOffset
//            attributes.zIndex = 100
//        }
//        return attributes
//    }
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let kind = SwiftDataTable.SupplementaryViewType(kind: elementKind)
        switch kind {
        case .searchHeader: return self.layoutAttributesForHeaderView(at: indexPath)
        case .columnHeader:
            let attributes = layoutAttributesForColumnHeaderView(at: indexPath)
            return adjustAttributesPosition(attributes, at: indexPath[0], zIndexPosition: 100+indexPath[0])
        case .footerHeader:
            let attributes = layoutAttributesForColumnFooterView(at: indexPath)
            return adjustAttributesPosition(attributes, at: indexPath[0], zIndexPosition: 100+indexPath[0])
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
    
    // Binary search for visible rows is now handled by metricsStore.rowForYOffset()
}
