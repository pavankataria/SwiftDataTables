//
//  SwiftDataTable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 21/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit


public class SwiftDataTable: UIView {
    
    public enum SupplementaryViewType: String {
        /// Single header positioned at the top above the column section
        case paginationHeader = "SwiftDataTablePaginationHeader"

        /// Column header displayed at the top of each column
        case columnHeader = "SwiftDataTableViewColumnHeader"

        /// Footer displayed at the bottom of each column
        case footerHeader = "SwiftDataTableFooterHeader"
        
        /// Single header positioned at the bottom below the footer section.
        case menuLengthHeader = "SwiftDataTableMenuLengthHeader"
        
        init(kind: String){
            guard let elementKind = SupplementaryViewType(rawValue: kind) else {
                fatalError("Unknown supplementary view type passed in: \(kind)")
            }
            self = elementKind
        }
    }
    
    
    let highlightedColours = [
        UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1),
        UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1)
    ]
    let colours = [
        UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
        UIColor.white
    ]
    
    //MARK: - Private Properties
    //Lazy var
    fileprivate(set) open lazy var collectionView: UICollectionView = {
        guard let layout = self.layout else {
            fatalError("The layout needs to be set first")
        }
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        self.registerCell(collectionView: collectionView)
        return collectionView
    }()
    
    fileprivate(set) var layout: SwiftDataTableFlowLayout? = nil {
        didSet {
            if let layout = layout {
                self.collectionView.collectionViewLayout = layout
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate var dataStructure = DataStructureModel() {
        didSet {
            self.createDataCellViewModels(with: dataStructure)
        }
    }

    fileprivate(set) var headerViewModels = [DataHeaderFooterViewModel]()
    fileprivate(set) var footerViewModels = [DataHeaderFooterViewModel]()
    fileprivate var rowViewModels = [[DataCellViewModel]]()
    fileprivate var paginationViewModel: PaginationHeaderViewModel!
    fileprivate var menuLengthViewModel: MenuLengthHeaderViewModel!
    fileprivate var columnWidths = [CGFloat]()

    //MARK: - Lifecycle
    public init(data: [[String]],
         headerTitles: [String],
         frame: CGRect = .zero)
    {
//        self.dataStructure = DataStructureModel(data: data, headerTitles: headerTitles)
        super.init(frame: frame)
        
        self.set(data: data, headerTitles: headerTitles)
        
        self.registerObservers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    }
    func registerObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange), name: Notification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    }
    func deviceOrientationWillChange() {
        self.layout?.clearLayoutCache()
    }
    
    //TODO: Abstract away the registering of classes so that a user can register their own nibs or classes.
    func registerCell(collectionView: UICollectionView){
        let dataCellIdentifier = String(describing: DataCell.self)
        let podBundle = Bundle(for: SwiftDataTable.self)

        
        collectionView.register(UINib(nibName: dataCellIdentifier, bundle: podBundle), forCellWithReuseIdentifier: dataCellIdentifier)
        
        let headerIdentifier = String(describing: DataHeaderFooter.self)
        collectionView.register(UINib(nibName: headerIdentifier, bundle: podBundle), forSupplementaryViewOfKind: SupplementaryViewType.columnHeader.rawValue, withReuseIdentifier: headerIdentifier)
        
        collectionView.register(UINib(nibName:  headerIdentifier, bundle: podBundle), forSupplementaryViewOfKind: SupplementaryViewType.footerHeader.rawValue, withReuseIdentifier: headerIdentifier)
        
        let paginationIdentifier = String(describing: PaginationHeader.self)
        collectionView.register(UINib(nibName: paginationIdentifier, bundle: podBundle), forSupplementaryViewOfKind: SupplementaryViewType.paginationHeader.rawValue, withReuseIdentifier: paginationIdentifier)
        
        let menuLengthIdentifier = String(describing: MenuLengthHeader.self)
        
        collectionView.register(UINib(nibName: menuLengthIdentifier, bundle: podBundle), forSupplementaryViewOfKind: SupplementaryViewType.menuLengthHeader.rawValue, withReuseIdentifier: menuLengthIdentifier)
    }
    
//    public override var frame: CGRect {
//        get {
//            return super.frame
//        }
//        set {
//            super.frame = frame
////            if frame != .zero {
////                self.calculateColumnWidths()
////            }
//        }
//    }
    func set(data: [[String]], headerTitles: [String]){
        self.dataStructure = DataStructureModel(data: data, headerTitles: headerTitles)
        self.createDataCellViewModels(with: self.dataStructure)
        self.layout = SwiftDataTableFlowLayout(dataTable: self)
        self.calculateColumnWidths()
    }
    
    func calculateColumnWidths(){
        //calculate the automatic widths for each column
        self.columnWidths.removeAll()
        for columnIndex in Array(0..<self.numberOfHeaderColumns()) {
            self.columnWidths.append(self.automaticWidthForColumn(index: columnIndex))
        }
        
        if self.shouldContentWidthScaleToFillFrame(){
            self.scaleToFillColumnWidths()
        }
    }
    
    func scaleToFillColumnWidths(){
        //if content width is smaller than ipad width
        let totalColumnWidth = self.columnWidths.reduce(0, +)
        let totalWidth = self.frame.width
        let gap: CGFloat = totalWidth - totalColumnWidth
        guard totalColumnWidth < totalWidth else {
            return
        }
        //calculate the percentage width presence of each column in relation to the frame width of the collection view
        for columnIndex in Array(0..<self.columnWidths.count) {
            let columnWidth = self.columnWidths[columnIndex]
            let columnWidthPercentagePresence = columnWidth / totalColumnWidth
            //add result of gap size divided by percentage column width to each column automatic width.
            let gapPortionToDistributeToCurrentColumn = gap * columnWidthPercentagePresence
            //apply final result of each column width to the column width array.
            self.columnWidths[columnIndex] = columnWidth + gapPortionToDistributeToCurrentColumn
        }
    }
    //MARK: - Events
//    public func tapped(headerView: DataHeaderFooterViewModel){
////        self.headerViewModels.forEach { if $0.data != headerView.data { $0.toggleToDefault() } }
////        self.footerViewModels.forEach { if $0 != headerView.data { $0.toggleToDefault() } }
//        
//        self.dataStructure.data = self.dataStructure.data.reversed()
//        self.reloadEverything()
//    }
    
    public func reloadEverything(){
        self.layout?.clearLayoutCache()
        self.collectionView.reloadData()
    }
}

public extension SwiftDataTable {
    func createDataModels(with data: DataStructureModel){
        self.dataStructure = data
    }
    func createDataCellViewModels(with dataStructure: DataStructureModel){// -> [[DataCellViewModel]] {
        //1. Create the headers
        
        self.headerViewModels = Array(0..<(dataStructure.headerTitles.count)).map {
            let headerViewModel = DataHeaderFooterViewModel(
                data: dataStructure.headerTitles[$0],
                sortType: dataStructure.columnHeaderSortType(for: $0)
            )
            headerViewModel.configure(dataTable: self, columnIndex: $0)
            return headerViewModel
        }
        
        self.footerViewModels = Array(0..<(dataStructure.footerTitles.count)).map {
             let sortTypeForFooter = dataStructure.columnFooterSortType(for: $0)
            let headerViewModel = DataHeaderFooterViewModel(
                data: dataStructure.footerTitles[$0],
                sortType: sortTypeForFooter
            )
            return headerViewModel
        }
        
        //2. Create the view models
        //let viewModels: [[DataCellViewModel]] =
        self.rowViewModels = dataStructure.data.map{ currentRowData in
            return currentRowData.map {
                return DataCellViewModel(data: $0)
            }
        }
        self.paginationViewModel = PaginationHeaderViewModel()
        self.menuLengthViewModel = MenuLengthHeaderViewModel()
    }
}

extension SwiftDataTable: UICollectionViewDelegateFlowLayout {
}


extension SwiftDataTable: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataStructure.columnCount
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.rowViewModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = self.rowViewModels[indexPath.section][indexPath.row].dequeueCell(collectionView: collectionView, indexPath: indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let kind = SupplementaryViewType(kind: elementKind)
        switch kind {
        case .paginationHeader, .menuLengthHeader:
            view.backgroundColor = UIColor.darkGray
        default:
            view.backgroundColor = UIColor.white
        }
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellViewModel = self.rowViewModels[safe: indexPath.section]?[safe: indexPath.row] else {
            return
        }
        if cellViewModel.highlighted {
            cell.backgroundColor = self.highlightedColours[indexPath.section % 2]
        }
        else {
            cell.backgroundColor = self.colours[indexPath.section % 2]
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let elementKind = SupplementaryViewType(kind: kind)
        let viewModel: CollectionViewSupplementaryElementRepresentable
        switch elementKind {
        case .menuLengthHeader: viewModel = self.menuLengthViewModel
        case .columnHeader: viewModel = self.headerViewModels[indexPath.index]
        case .footerHeader: viewModel = self.footerViewModels[indexPath.index]
        case .paginationHeader: viewModel = self.paginationViewModel
        }
        return viewModel.dequeueView(collectionView: collectionView, viewForSupplementaryElementOfKind: kind, for: indexPath)
    }
}

//MARK: - Swift Data Table Delegate
extension SwiftDataTable {
    func disableScrollViewLeftBounce() -> Bool {
        return true
    }
    func disableScrollViewTopBounce() -> Bool {
        return false
    }
    func disableScrollViewRightBounce() -> Bool {
        return true
    }
    func disableScrollViewBottomBounce() -> Bool {
        return false
    }
}

//MARK: - UICollection View Delegate
extension SwiftDataTable: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.disableScrollViewLeftBounce() {
            if (self.collectionView.contentOffset.x <= 0) {
                self.collectionView.contentOffset.x = 0
            }
        }
        if self.disableScrollViewTopBounce() {
            if (self.collectionView.contentOffset.y <= 0) {
                self.collectionView.contentOffset.y = 0
            }
        }
        if self.disableScrollViewRightBounce(){
            let maxX = self.collectionView.contentSize.width-self.collectionView.frame.width
            if (self.collectionView.contentOffset.x >= maxX){
                self.collectionView.contentOffset.x = max(maxX-1, 0)
            }
        }
        if self.disableScrollViewBottomBounce(){
            let maxY = self.collectionView.contentSize.height-self.collectionView.frame.height
            if (self.collectionView.contentOffset.y >= maxY){
                self.collectionView.contentOffset.y = maxY-1
            }
        }
    }
}

extension SwiftDataTable {
    func update(){
        print("\nUpdate")
        self.reloadEverything()
    }
    
    func didTapColumn(index: IndexPath) {
        defer {
            self.update()
        }
        let index = index.index
        self.toggleSortArrows(column: index)
        self.highlight(column: index)
        let sortType = self.headerViewModels[index].sortType
        self.sort(column: index, sort: sortType)
    }
    
    func sort(column index: Int, sort by: DataTableSortType){
        func ascendingOrder(rowOne: [DataCellViewModel], rowTwo: [DataCellViewModel]) -> Bool {
            return rowOne[index].data < rowTwo[index].data
        }
        func descendingOrder(rowOne: [DataCellViewModel], rowTwo: [DataCellViewModel]) -> Bool {
            return rowOne[index].data > rowTwo[index].data
        }
        
        switch by {
        case .ascending:
            self.rowViewModels = self.rowViewModels.sorted(by: ascendingOrder)
            break;
        case .descending:
            self.rowViewModels = self.rowViewModels.sorted(by: descendingOrder)
            break;
        default:
            break;
        }
    }
    
    func highlight(column: Int){
        self.rowViewModels.forEach {
            $0.forEach { $0.highlighted = false }
            $0[column].highlighted = true
        }
    }
    
    func toggleSortArrows(column: Int){
        Array(0..<self.headerViewModels.count).forEach {
            if column == $0 {
                self.headerViewModels[$0].sortType.toggle()
            }
            else {
                self.headerViewModels[$0].sortType.toggleToDefault()
            }
        }
        self.headerViewModels.forEach { print($0.sortType) }
    }
    
    //This is actually mapped to sections
    func numberOfRows() -> Int {
        return self.rowViewModels.count
    }
    
    func numberOfColumns() -> Int {
        return self.dataStructure.columnCount
    }
    
    func numberOfHeaderColumns() -> Int {
        return self.dataStructure.headerTitles.count
    }
    
    func numberOfFooterColumns() -> Int {
        return self.dataStructure.footerTitles.count
    }
    
    
    func shouldContentWidthScaleToFillFrame() -> Bool{
        return true
    }
    func shouldSectionHeadersFloat() -> Bool {
        return true
    }
    
    func shouldSectionFootersFloat() -> Bool {
        return true
    }
    
    func shouldShowSearchSection() -> Bool {
        return false
    }
    
    func shouldShowPaginationSection() -> Bool {
        return false
    }
    
    func heightForSectionFooter() -> CGFloat {
        return 50
    }
    
    func heightForSectionHeader() -> CGFloat {
        return 50
    }
    
    func widthForRowHeader() -> CGFloat {
        return 0
    }
    
    
    /// Automatically calcualtes the width the column should be based on the content
    /// in the rows under the column.
    ///
    /// - Parameter index: The column index
    /// - Returns: The automatic width of the column irrespective of the Data Grid frame width
    func automaticWidthForColumn(index: Int) -> CGFloat {
        print(self.frame.width)
        let columnAverage: CGFloat = CGFloat(dataStructure.averageDataLengthForColumn(index: index))
        let sortingArrowVisualElementWidth: CGFloat = 20 // This is ugly
        let averageDataColumnWidth: CGFloat = columnAverage * self.pixelsPerCharacter() + sortingArrowVisualElementWidth
        return max(averageDataColumnWidth, max(self.minimumColumnWidth(), self.minimumHeaderColumnWidth(index: index)))
    }
//    func automaticWidthForAllColumns(){
//        let automaticCalculatedWidth: CGFloat = Array(0..<self.numberOfHeaderColumns())
//            .reduce(0.0){
//            return $0 + self.automaticWidthForColumn(index: $1)
//        }
//        
//        if automaticCalculatedWidth < self.collectionView.frame.width {
//            let emptyGap = self.collectionView.frame.width - automaticCalculatedWidth
//            
//        }
////        return automaticCalculatedWidth
//    }
    
    func widthForColumn(index: Int) -> CGFloat {
        return self.columnWidths[index]
    }
    
    func calculateContentWidth() -> CGFloat {
        return Array(0..<self.numberOfColumns()).reduce(self.widthForRowHeader()) { $0 + self.widthForColumn(index: $1)}
    }
    
    func heightForRow(index: Int) -> CGFloat {
        return 44
    }
    
    func heightOfInterRowSpacing() -> CGFloat {
        return 1
    }
    
    func minimumColumnWidth() -> CGFloat {
        return 70
    }
    
    func minimumHeaderColumnWidth(index: Int) -> CGFloat {
        return CGFloat(self.pixelsPerCharacter() * CGFloat(self.dataStructure.headerTitles[index].characters.count))
    }
    
    //There should be an automated way to retrieve the font size of the cell
    func pixelsPerCharacter() -> CGFloat {
        return 14
    }
    
    func heightForMenuLengthView() -> CGFloat {
        guard self.shouldShowSearchSection() else {
            return 0
        }
        return 35
    }
    
    func heightForPaginationView() -> CGFloat {
        guard self.shouldShowPaginationSection() else {
            return 0
        }
        return 35
            
    }
    
    func showVerticalScrollBars() -> Bool {
        return true
    }
    
    func showHorizontalScrollBars() -> Bool {
        return false
    }
}
