//
//  SwiftDataTable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 21/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

public typealias DataTableRow = [DataTableValueType]
public typealias DataTableContent = [DataTableRow]
public typealias DataTableViewModelContent = [[DataCellViewModel]]

public class SwiftDataTable: UIView {
    public enum SupplementaryViewType: String {
        /// Single header positioned at the top above the column section
        case paginationHeader = "SwiftDataTablePaginationHeader"
        
        /// Column header displayed at the top of each column
        case columnHeader = "SwiftDataTableViewColumnHeader"
        
        /// Footer displayed at the bottom of each column
        case footerHeader = "SwiftDataTableFooterHeader"
        
        /// Single header positioned at the bottom below the footer section.
        case searchHeader = "SwiftDataTableSearchHeader"
        
        init(kind: String){
            guard let elementKind = SupplementaryViewType(rawValue: kind) else {
                fatalError("Unknown supplementary view type passed in: \(kind)")
            }
            self = elementKind
        }
    }
    
    public weak var dataSource: SwiftDataTableDataSource?
    public weak var delegate: SwiftDataTableDelegate?
    
    public var rows: DataTableViewModelContent {
        return self.currentRowViewModels
    }
    
    var options: DataTableConfiguration
    
    //MARK: - Private Properties
    var currentRowViewModels: DataTableViewModelContent {
        get {
            return self.searchRowViewModels
        }
        set {
            self.searchRowViewModels = newValue
        }
    }
    
    fileprivate(set) open lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal;
        searchBar.placeholder = "Search";
        searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchBar.backgroundColor = .systemBackground
            searchBar.barTintColor = .label
        } else {
            searchBar.backgroundColor = .white
            searchBar.barTintColor = .white
        }
        
        
        self.addSubview(searchBar)
        return searchBar
    }()
    
    //Lazy var
    fileprivate(set) open lazy var collectionView: UICollectionView = {
        guard let layout = self.layout else {
            fatalError("The layout needs to be set first")
        }
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.systemBackground
        } else {
            collectionView.backgroundColor = UIColor.clear
        }
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10, *) {
            collectionView.isPrefetchingEnabled = false
        }
        self.addSubview(collectionView)
        self.registerCell(collectionView: collectionView)
        return collectionView
    }()
    
    fileprivate(set) var layout: SwiftDataTableLayout? = nil {
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
    
    internal private(set) var headerViewModels = [DataHeaderFooterViewModel]()
    fileprivate(set) var footerViewModels = [DataHeaderFooterViewModel]()
    fileprivate var rowViewModels = DataTableViewModelContent() {
        didSet {
            self.searchRowViewModels = rowViewModels
        }
    }
    fileprivate var searchRowViewModels: DataTableViewModelContent!
    private var currentRowIdentifiers: [String] = []
    internal var precomputedChangedIdentifiers: Set<String>?
    internal var typedData: Any?
    internal var typedColumns: Any?
    
    fileprivate var paginationViewModel: PaginationHeaderViewModel!
    fileprivate var menuLengthViewModel: MenuLengthHeaderViewModel!
    fileprivate var columnWidths = [CGFloat]()
    fileprivate var rowHeights = [CGFloat]()

    /// Tracks whether column widths have been computed at least once (for lockColumnWidthsAfterFirstLayout)
    private var hasComputedColumnWidthsOnce = false
    /// Tracks the columnWidthMode used in the last width computation (for config-change detection)
    private var lastColumnWidthMode: DataTableColumnWidthMode?
    /// Tracks the columnWidthModeProviderVersion used in the last width computation (for provider-change detection)
    private var lastColumnWidthModeProviderVersion: Int?
    private var sizingCellCacheByReuseId: [String: UICollectionViewCell] = [:]

    // MARK: - Row Metrics Store (Single Source of Truth)
    private let metricsStore = RowMetricsStore()

    /// Provides read access to row metrics for the layout.
    var rowMetricsStore: RowMetricsStore { metricsStore }

    // MARK: - Scroll Anchoring (Phase 4)

    /// Captures scroll position state for anchor restoration after updates.
    private struct ScrollAnchor {
        /// The row index that was visible at the top of the viewport before the update.
        let rowIndex: Int
        /// The identifier of the anchor row (used to track the row across index shifts).
        let rowIdentifier: String?
        /// The offset from the top of the anchor row to the viewport top.
        /// Positive means the row starts above the viewport; negative means below.
        let offsetWithinRow: CGFloat
    }

    internal func seedRowIdentifiers(_ identifiers: [String]) {
        currentRowIdentifiers = identifiers
    }
    
    
    //    fileprivate var refreshControl: UIRefreshControl! = {
    //        let refreshControl = UIRefreshControl()
    //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    //        refreshControl.addTarget(self,
    //                                 action: #selector(refreshOptions(sender:)),
    //                                 for: .valueChanged)
    //        return refreshControl
    //    }()
    
    //    //MARK: - Events
    //    var refreshEvent: (() -> Void)? = nil {
    //        didSet {
    //            if refreshEvent != nil {
    //                self.collectionView.refreshControl = self.refreshControl
    //            }
    //            else {
    //                self.refreshControl = nil
    //                self.collectionView.refreshControl = nil
    //            }
    //        }
    //    }
    
    //    var showRefreshControl: Bool {
    //        didSet {
    //            if
    //            self.refreshControl
    //        }
    //    }
    
    //MARK: - Lifecycle
    public init(dataSource: SwiftDataTableDataSource,
                options: DataTableConfiguration? = DataTableConfiguration(),
                frame: CGRect = .zero){
        self.options = options!
        super.init(frame: frame)
        self.dataSource = dataSource
        
        self.set(options: options)
        self.registerObservers()
    }
    
    public init(data: DataTableContent,
                headerTitles: [String],
                options: DataTableConfiguration = DataTableConfiguration(),
                frame: CGRect = .zero)
    {
        self.options = options
        super.init(frame: frame)
        self.set(data: data, headerTitles: headerTitles, options: options, shouldReplaceLayout: true)
        self.registerObservers()
        
        
    }
    public convenience init(data: [[String]],
                            headerTitles: [String],
                            options: DataTableConfiguration = DataTableConfiguration(),
                            frame: CGRect = .zero)
    {
        self.init(
            data: data.map { $0.map { .string($0) }},
            headerTitles: headerTitles,
            options: options,
            frame: frame
        )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let searchBarHeight = self.heightForSearchView()
        self.searchBar.isHidden = !self.shouldShowSearchSection()
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: searchBarHeight)
        self.collectionView.frame = CGRect(x: 0, y: searchBarHeight, width: self.bounds.width, height: self.bounds.height-searchBarHeight)
    }
    
    func registerObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc func deviceOrientationWillChange() {
        self.layout?.clearLayoutCache()
        invalidateRowHeights()
    }
    
    //TODO: Abstract away the registering of classes so that a user can register their own nibs or classes.
    func registerCell(collectionView: UICollectionView){
        let headerIdentifier = String(describing: DataHeaderFooter.self)
        collectionView.register(DataHeaderFooter.self, forSupplementaryViewOfKind: SupplementaryViewType.columnHeader.rawValue, withReuseIdentifier: headerIdentifier)
        collectionView.register(DataHeaderFooter.self, forSupplementaryViewOfKind: SupplementaryViewType.footerHeader.rawValue, withReuseIdentifier: headerIdentifier)
        collectionView.register(PaginationHeader.self, forSupplementaryViewOfKind: SupplementaryViewType.paginationHeader.rawValue, withReuseIdentifier: String(describing: PaginationHeader.self))
        collectionView.register(MenuLengthHeader.self, forSupplementaryViewOfKind: SupplementaryViewType.searchHeader.rawValue, withReuseIdentifier: String(describing: MenuLengthHeader.self))
        collectionView.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
    }
    
    func set(data: DataTableContent, headerTitles: [String], options: DataTableConfiguration? = nil, shouldReplaceLayout: Bool = false){
        let resolvedOptions = options ?? self.options
        self.options = resolvedOptions
        self.dataStructure = DataStructureModel(
            data: data,
            headerTitles: headerTitles,
            useEstimatedColumnWidths: resolvedOptions.columnWidthMode.prefersEstimatedTextWidths
        )
        // Initialize row identifiers for scroll anchoring support
        self.currentRowIdentifiers = data.map { row in
            row.map { $0.stringRepresentation }.joined(separator: "\u{001F}")
        }
        self.createDataCellViewModels(with: self.dataStructure)
        if(shouldReplaceLayout){
            self.layout = SwiftDataTableLayout(dataTable: self)
        }
        self.applyOptions(resolvedOptions)
        invalidateRowHeights()

    }
    
    func applyOptions(_ options: DataTableConfiguration?){
        guard let options = options else {
            return
        }
        if let defaultOrdering = options.defaultOrdering {
            self.applyDefaultColumnOrder(defaultOrdering)
        }
        registerCustomCellIfNeeded()
    }

    private func registerCustomCellIfNeeded() {
        guard case .autoLayout(let provider) = options.cellSizingMode else {
            return
        }
        provider.register(collectionView)
    }
    
    // MARK: - Column Width Calculation (Phase 2: Decoupled Width/Height)

    /// Orchestrator: computes widths, detects changes, applies widths, and rebuilds heights if needed.
    func calculateColumnWidths() {
        let expectedColumnCount = numberOfHeaderColumns()
        let schemaChanged = columnWidths.count != expectedColumnCount
        let modeChanged = lastColumnWidthMode != options.columnWidthMode
        let providerChanged = lastColumnWidthModeProviderVersion != options.columnWidthModeProviderVersion
        let configChanged = modeChanged || providerChanged

        // If locked and already computed, skip recalculation (unless schema or config changed)
        if options.lockColumnWidthsAfterFirstLayout && hasComputedColumnWidthsOnce && !schemaChanged && !configChanged {
            // Still need to rebuild heights in case data changed
            calculateRowHeights()
            return
        }

        let oldWidths = columnWidths
        let newWidths = computeColumnWidths()
        // TODO: Phase 3 - widthsChanged will be used to enable incremental height updates
        // when widths are unchanged (skip full height rebuild)
        let widthsChanged = !widthsAreEqual(oldWidths, newWidths, epsilon: 0.5)

        applyColumnWidths(newWidths)
        hasComputedColumnWidthsOnce = true
        lastColumnWidthMode = options.columnWidthMode
        lastColumnWidthModeProviderVersion = options.columnWidthModeProviderVersion

        // If widths changed, we must rebuild all heights (wrapping depends on width)
        if widthsChanged || metricsStore.rowCount == 0 {
            calculateRowHeights()
        }
        // Phase 3: When widths unchanged, skip height rebuild here.
        // Dirty rows will be processed incrementally after applyNewData() in applyDiff().
        // This ensures measurements use the NEW data, not stale data.
    }

    /// Pure calculation: returns column widths without side effects.
    private func computeColumnWidths() -> [CGFloat] {
        var widths = [CGFloat]()
        for columnIndex in 0..<numberOfHeaderColumns() {
            widths.append(automaticWidthForColumn(index: columnIndex))
        }
        return widths
    }

    /// Applies the computed widths and performs scaling if required.
    private func applyColumnWidths(_ widths: [CGFloat]) {
        columnWidths = widths
        scaleColumnWidthsIfRequired()
    }

    /// Compares two width arrays with epsilon tolerance.
    private func widthsAreEqual(_ lhs: [CGFloat], _ rhs: [CGFloat], epsilon: CGFloat) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for i in 0..<lhs.count {
            if abs(lhs[i] - rhs[i]) > epsilon {
                return false
            }
        }
        return true
    }

    private func scaleColumnWidthsIfRequired() {
        guard shouldContentWidthScaleToFillFrame() else {
            return
        }
        scaleToFillColumnWidths()
    }

    private func scaleToFillColumnWidths() {
        // If content width is smaller than frame width, scale up proportionally
        let totalColumnWidth = columnWidths.reduce(0, +)
        let totalWidth = frame.width
        let gap: CGFloat = totalWidth - totalColumnWidth
        guard totalColumnWidth < totalWidth else {
            return
        }
        // Calculate the percentage width presence of each column in relation to the frame width
        for columnIndex in 0..<columnWidths.count {
            let columnWidth = columnWidths[columnIndex]
            let columnWidthPercentagePresence = columnWidth / totalColumnWidth
            // Add result of gap size divided by percentage column width to each column automatic width
            let gapPortionToDistributeToCurrentColumn = gap * columnWidthPercentagePresence
            // Apply final result of each column width to the column width array
            columnWidths[columnIndex] = columnWidth + gapPortionToDistributeToCurrentColumn
        }
    }

    private func invalidateRowHeights() {
        rowHeights.removeAll()
        sizingCellCacheByReuseId.removeAll()
        metricsStore.clear()
    }

    // MARK: - Incremental Height Updates (Phase 3)

    /// Phase 3: Performs incremental height update after data is applied.
    /// Called from inside performBatchUpdates after applyNewData().
    private func performIncrementalHeightUpdate(deletions: IndexSet, insertions: IndexSet) {
        let newRowCount = numberOfRows()
        let oldRowCount = metricsStore.rowCount

        // Handle row count changes FIRST - applies to ALL height modes including fixed
        if newRowCount != oldRowCount {
            if newRowCount < oldRowCount {
                // Deletions: truncate metricsStore
                metricsStore.truncateToCount(newRowCount)
                // Invalidate from first deleted index onward (tail invalidation)
                if let firstDeletion = deletions.min(), firstDeletion < newRowCount {
                    let tailRows = IndexSet(integersIn: firstDeletion..<newRowCount)
                    metricsStore.invalidateRows(tailRows)
                }
            } else {
                // Insertions: append default-height rows
                let defaultHeight = options.rowHeightMode.estimatedHeight
                for _ in oldRowCount..<newRowCount {
                    metricsStore.appendRow(height: defaultHeight)
                }
                // Invalidate from first insertion onward (shifted rows need re-measure)
                if let firstInsertion = insertions.min(), firstInsertion < newRowCount {
                    let tailRows = IndexSet(integersIn: firstInsertion..<newRowCount)
                    metricsStore.invalidateRows(tailRows)
                }
            }
            // Rebuild offsets after row count change
            metricsStore.rebuildOffsets()
        }

        // For fixed heights without delegate, just sync and return
        guard requiresLayoutMetadataRebuildOnContentChange else {
            metricsStore.clearDirtyFlags()
            rowHeights = (0..<metricsStore.rowCount).map { metricsStore.heightForRow($0) }
            return
        }

        // Lazy measurement mode: skip immediate measurement, let scroll-triggered measurement handle it
        // Dirty rows (changed content) must be unmarked as measured so they get re-measured on scroll
        if usesLazyMeasurement {
            // Unmeasure dirty rows so they will be re-measured when they scroll into view
            let dirtyRows = metricsStore.currentDirtyRows
            if !dirtyRows.isEmpty {
                metricsStore.markRowsUnmeasured(dirtyRows, estimatedHeight: options.rowHeightMode.estimatedHeight)
            }
            metricsStore.clearDirtyFlags()
            // Reset throttle state so visible rows get measured
            lastMeasuredRowRange = nil
            rowHeights = (0..<metricsStore.rowCount).map { metricsStore.heightForRow($0) }
            // Trigger lazy measurement for currently visible rows
            measureVisibleRowsIfNeeded()
            return
        }

        // Skip height recomputation if no dirty rows
        guard metricsStore.hasDirtyRows else {
            rowHeights = (0..<metricsStore.rowCount).map { metricsStore.heightForRow($0) }
            return
        }

        // Now recompute dirty heights with the new data (standard automatic mode)
        if usesDelegateRowHeights() {
            metricsStore.recomputeDirtyHeights { [weak self] row in
                guard let self = self else { return 44 }
                return self.delegate?.dataTable?(self, heightForRowAt: row) ?? 44
            }
        } else if usesAutomaticRowHeights {
            metricsStore.recomputeDirtyHeights { [weak self] row in
                guard let self = self else { return 0 }
                return self.measureHeightForRow(row)
            }
        } else {
            metricsStore.clearDirtyFlags()
        }

        // Sync to legacy rowHeights array for compatibility
        rowHeights = (0..<metricsStore.rowCount).map { metricsStore.heightForRow($0) }
    }

    /// Measures height for a single row (used by incremental updates).
    private func measureHeightForRow(_ row: Int) -> CGFloat {
        switch options.cellSizingMode {
        case .autoLayout(let provider):
            return measureAutoLayoutHeightForRow(row, provider: provider)
        case .defaultCell:
            return measureDefaultHeightForRow(row)
        }
    }

    /// Measures height for a row using AutoLayout sizing.
    private func measureAutoLayoutHeightForRow(_ row: Int, provider: DataTableCustomCellProvider) -> CGFloat {
        guard row < currentRowViewModels.count else { return options.rowHeightMode.estimatedHeight }

        let estimatedHeight = options.rowHeightMode.estimatedHeight
        let targetHeight = max(estimatedHeight, 1)
        var maxHeight: CGFloat = 0
        let rowData = currentRowViewModels[row]
        let columnCount = numberOfColumns()

        for columnIndex in 0..<columnCount {
            guard columnIndex < rowData.count else { continue }
            let value = rowData[columnIndex].data
            let indexPath = IndexPath(item: columnIndex, section: row)
            let reuseId = provider.reuseIdentifierFor(indexPath)
            let sizingCell = self.sizingCell(for: reuseId, provider: provider)
            provider.configure(sizingCell, value, indexPath)
            let columnWidth = columnWidths[safe: columnIndex] ?? 0
            sizingCell.bounds = CGRect(x: 0, y: 0, width: columnWidth, height: targetHeight)
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()
            let targetSize = CGSize(width: columnWidth, height: UIView.layoutFittingCompressedSize.height)
            let size = sizingCell.contentView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            maxHeight = max(maxHeight, ceil(size.height))
        }

        return max(maxHeight, estimatedHeight)
    }

    /// Measures height for a row using default text-based sizing.
    private func measureDefaultHeightForRow(_ row: Int) -> CGFloat {
        guard row < currentRowViewModels.count else { return options.rowHeightMode.estimatedHeight }

        let font = DataCell.Properties.defaultFont
        let verticalPadding = DataCell.Properties.verticalMargin * 2
        let singleLineHeight = ceil(font.lineHeight + verticalPadding)

        if case .singleLine = options.textLayout {
            return singleLineHeight
        }

        // Wrap mode: calculate based on text content
        var maxHeight: CGFloat = singleLineHeight
        let rowData = currentRowViewModels[row]
        let columnCount = numberOfColumns()

        for columnIndex in 0..<columnCount {
            guard columnIndex < rowData.count else { continue }
            let columnWidth = columnWidths[safe: columnIndex] ?? 0
            let textWidth = max(columnWidth - (DataCell.Properties.horizontalMargin * 2), 0)
            let textHeight = measuredTextHeight(
                for: rowData[columnIndex].data,
                font: font,
                width: textWidth
            )
            maxHeight = max(maxHeight, textHeight + verticalPadding)
        }

        return maxHeight
    }

    private var usesAutomaticRowHeights: Bool {
        if options.cellSizingMode.usesAutoLayout {
            return true
        }
        switch options.rowHeightMode {
        case .automatic:
            return true
        case .fixed:
            return false
        }
    }

    /// Returns true if lazy row measurement is enabled (automatic mode).
    private var usesLazyMeasurement: Bool {
        return options.rowHeightMode.usesLazyMeasurement
    }

    private func calculateRowHeights() {
        rowHeights.removeAll()

        // Configure metricsStore with layout parameters
        metricsStore.headerHeight = heightForSectionHeader()
        metricsStore.interRowSpacing = heightOfInterRowSpacing()
        // Footer contributes to content height only when floating (matches heightOfFooter() in layout)
        metricsStore.footerHeight = shouldShowFooterSection() && shouldSectionFootersFloat() ? heightForSectionFooter() + heightForPaginationView() : 0

        let rowCount = numberOfRows()
        let defaultHeight = options.rowHeightMode.estimatedHeight

        // Delegate heights take precedence over all other height modes
        if usesDelegateRowHeights() {
            metricsStore.setRowCount(rowCount, defaultHeight: defaultHeight, allMeasured: true)
            for row in 0..<rowCount {
                if let height = delegate?.dataTable?(self, heightForRowAt: row) {
                    metricsStore.setHeight(height, forRow: row)
                }
            }
            metricsStore.rebuildOffsets()
            rowHeights = (0..<rowCount).map { metricsStore.heightForRow($0) }
            return
        }

        // Fixed heights mode - use the configured fixed value
        guard usesAutomaticRowHeights else {
            metricsStore.setRowCount(rowCount, defaultHeight: defaultHeight, allMeasured: true)
            if case .fixed(let height) = options.rowHeightMode {
                for row in 0..<rowCount {
                    metricsStore.setHeight(height, forRow: row)
                }
            }
            metricsStore.rebuildOffsets()
            rowHeights = (0..<rowCount).map { metricsStore.heightForRow($0) }
            return
        }

        // Automatic mode: use estimated heights, measure lazily on scroll
        // This works efficiently for any dataset size - small or 100k+ rows
        metricsStore.setRowCount(rowCount, defaultHeight: defaultHeight, allMeasured: false)
        metricsStore.rebuildOffsets()
        // Measure initial visible rows if we have a valid bounds
        measureVisibleRowsIfNeeded()
        rowHeights = (0..<rowCount).map { metricsStore.heightForRow($0) }
    }

    private func calculateDefaultRowHeights() -> [CGFloat] {
        let rowCount = numberOfRows()
        guard rowCount > 0 else { return [] }

        let font = DataCell.Properties.defaultFont
        let verticalPadding = DataCell.Properties.verticalMargin * 2
        let singleLineHeight = ceil(font.lineHeight + verticalPadding)

        switch options.textLayout {
        case .singleLine:
            return Array(repeating: singleLineHeight, count: rowCount)
        case .wrap:
            break
        }

        var heights = [CGFloat]()
        heights.reserveCapacity(rowCount)
        let columnCount = numberOfColumns()

        for rowIndex in 0..<rowCount {
            let row = currentRowViewModels[rowIndex]
            var maxHeight = singleLineHeight
            for columnIndex in 0..<columnCount {
                guard columnIndex < row.count else { continue }
                let columnWidth = columnWidths[safe: columnIndex] ?? 0
                let textWidth = max(columnWidth - (DataCell.Properties.horizontalMargin * 2), 0)
                let textHeight = measuredTextHeight(
                    for: row[columnIndex].data,
                    font: font,
                    width: textWidth
                )
                maxHeight = max(maxHeight, textHeight + verticalPadding)
            }
            heights.append(maxHeight)
        }

        return heights
    }

    private func calculateAutoLayoutRowHeights(provider: DataTableCustomCellProvider) -> [CGFloat] {
        let rowCount = numberOfRows()
        guard rowCount > 0 else { return [] }

        let estimatedHeight = options.rowHeightMode.estimatedHeight
        let targetHeight = max(estimatedHeight, 1)
        let columnCount = numberOfColumns()
        var heights = [CGFloat]()
        heights.reserveCapacity(rowCount)

        for rowIndex in 0..<rowCount {
            let row = currentRowViewModels[rowIndex]
            var maxHeight: CGFloat = 0
            for columnIndex in 0..<columnCount {
                guard columnIndex < row.count else { continue }
                let value = row[columnIndex].data
                let indexPath = IndexPath(item: columnIndex, section: rowIndex)
                let reuseId = provider.reuseIdentifierFor(indexPath)
                let sizingCell = self.sizingCell(for: reuseId, provider: provider)
                provider.configure(sizingCell, value, indexPath)
                let columnWidth = columnWidths[safe: columnIndex] ?? 0
                sizingCell.bounds = CGRect(x: 0, y: 0, width: columnWidth, height: targetHeight)
                sizingCell.setNeedsLayout()
                sizingCell.layoutIfNeeded()
                let targetSize = CGSize(width: columnWidth, height: UIView.layoutFittingCompressedSize.height)
                let size = sizingCell.contentView.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )
                maxHeight = max(maxHeight, ceil(size.height))
            }
            heights.append(max(maxHeight, estimatedHeight))
        }

        return heights
    }

    private func sizingCell(for reuseId: String, provider: DataTableCustomCellProvider) -> UICollectionViewCell {
        if let cached = sizingCellCacheByReuseId[reuseId] {
            return cached
        }
        let sizingCell = provider.sizingCellFor(reuseId)
        sizingCellCacheByReuseId[reuseId] = sizingCell
        return sizingCell
    }

    private func measuredTextHeight(for value: DataTableValueType, font: UIFont, width: CGFloat) -> CGFloat {
        guard width > 0 else {
            return ceil(font.lineHeight)
        }
        let rect = (value.stringRepresentation as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(max(rect.height, font.lineHeight))
    }

    private func usesDelegateRowHeights() -> Bool {
        guard let delegate = delegate as AnyObject? else {
            return false
        }
        return delegate.responds(to: #selector(SwiftDataTableDelegate.dataTable(_:heightForRowAt:)))
    }

    /// Returns true if content changes require layout metadata rebuild (auto-height or delegate heights)
    private var requiresLayoutMetadataRebuildOnContentChange: Bool {
        return usesAutomaticRowHeights || usesDelegateRowHeights()
    }

    // MARK: - Scroll Anchoring Methods (Phase 4)

    /// Test seam: allows tests to override the scroll state check for anchoring.
    /// When non-nil, this value is used instead of checking isDragging/isDecelerating.
    /// Set to `true` to simulate active scrolling (skip anchoring), `false` to allow anchoring.
    internal var _testScrollStateOverride: Bool?

    /// Returns true if anchoring should be skipped due to active user scrolling.
    private var isActivelyScrolling: Bool {
        if let override = _testScrollStateOverride {
            return override
        }
        return collectionView.isDragging || collectionView.isDecelerating
    }

    /// Captures the current scroll anchor (first visible row + offset within that row).
    /// Returns nil if anchoring should be skipped (user is scrolling, no rows, etc.)
    private func captureScrollAnchor() -> ScrollAnchor? {
        // Skip anchoring during active user interaction
        guard !isActivelyScrolling else {
            return nil
        }

        // Skip if no rows
        guard metricsStore.rowCount > 0 else {
            return nil
        }

        // Try to get the first visible row from visible items
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            .filter { $0.section >= 0 && $0.section < metricsStore.rowCount }
            .sorted { $0.section < $1.section }

        let anchorRow: Int
        if let firstVisible = visibleIndexPaths.first {
            anchorRow = firstVisible.section
        } else {
            // Fallback: derive anchor row from content offset using binary search
            let viewportTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
            anchorRow = metricsStore.rowForYOffset(viewportTop)
        }

        guard anchorRow < metricsStore.rowCount else {
            return nil
        }

        // Capture the row identifier if available (used to track the row across index shifts)
        let rowIdentifier: String? = anchorRow < currentRowIdentifiers.count
            ? currentRowIdentifiers[anchorRow]
            : nil

        // Calculate offset from viewport top to the anchor row's top
        let rowY = metricsStore.yOffsetForRow(anchorRow)
        let viewportTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
        let offsetWithinRow = viewportTop - rowY

        return ScrollAnchor(rowIndex: anchorRow, rowIdentifier: rowIdentifier, offsetWithinRow: offsetWithinRow)
    }

    /// Restores the scroll position to keep the anchor row visually stationary.
    /// - Parameters:
    ///   - anchor: The captured scroll anchor from before the update
    ///   - newIdentifiers: The new row identifiers (used to find the anchor row's new index)
    private func restoreScrollAnchor(_ anchor: ScrollAnchor?, newIdentifiers: [String]) {
        guard let anchor = anchor else { return }

        // Skip if still in active scroll
        guard !isActivelyScrolling else {
            return
        }

        let newRowCount = metricsStore.rowCount
        guard newRowCount > 0 else { return }

        // Find the anchor row's new index
        let targetRow: Int
        if let identifier = anchor.rowIdentifier,
           let newIndex = newIdentifiers.firstIndex(of: identifier) {
            // Row still exists - use its new index
            targetRow = newIndex
        } else {
            // Row was deleted or no identifier - fall back to nearest surviving row
            targetRow = min(anchor.rowIndex, newRowCount - 1)
        }

        // Calculate the new Y position to maintain visual continuity
        let newRowY = metricsStore.yOffsetForRow(targetRow)
        let newViewportTop = newRowY + anchor.offsetWithinRow

        // Clamp to valid content offset bounds
        let minY = -collectionView.adjustedContentInset.top
        let maxY = max(minY, collectionView.contentSize.height - collectionView.bounds.height + collectionView.adjustedContentInset.bottom)
        let clampedY = max(minY, min(newViewportTop - collectionView.adjustedContentInset.top, maxY))

        // Apply the offset adjustment without animation (immediate)
        collectionView.contentOffset.y = clampedY
    }

    // MARK: - Large-Scale Lazy Measurement (Phase 5)

    /// Tracks the last measured row range for throttling.
    private var lastMeasuredRowRange: Range<Int>?

    /// Measures rows in the visible area plus prefetch window.
    /// Called on scroll in automatic mode to lazily measure rows as they become visible.
    /// Uses scroll anchoring to prevent visual jumps when measurements change layout.
    /// Throttled: only triggers when visible range changes meaningfully or has unmeasured rows.
    private func measureVisibleRowsIfNeeded() {
        // Only active in automatic (lazy measurement) mode
        guard usesLazyMeasurement else { return }
        guard metricsStore.rowCount > 0 else { return }

        // Calculate visible row range
        let visibleRange = calculateVisibleRowRange()
        guard !visibleRange.isEmpty else { return }

        // Expand by prefetch window
        let prefetchWindow = options.rowHeightMode.prefetchWindow
        let expandedStart = max(0, visibleRange.lowerBound - prefetchWindow)
        let expandedEnd = min(metricsStore.rowCount, visibleRange.upperBound + prefetchWindow)
        let measureRange = expandedStart..<expandedEnd

        // Throttle: skip if the expanded range hasn't changed (no new rows to potentially measure)
        if let lastRange = lastMeasuredRowRange,
           measureRange == lastRange {
            return
        }

        // Check if there are unmeasured rows in the range
        let unmeasured = metricsStore.unmeasuredRowsInRange(measureRange)
        guard !unmeasured.isEmpty else {
            // Update last range even if no measurement needed (range is fully measured)
            lastMeasuredRowRange = measureRange
            return
        }

        // Capture anchor before measurement (estimate→measured transitions can shift layout)
        let anchor = captureScrollAnchor()

        // Measure the rows
        metricsStore.measureRowsInRange(measureRange) { [weak self] row in
            guard let self = self else { return self?.options.rowHeightMode.estimatedHeight ?? 44 }
            return self.measureHeightForRow(row)
        }

        // Update throttle state after successful measurement
        lastMeasuredRowRange = measureRange

        // Sync to legacy rowHeights array
        rowHeights = (0..<metricsStore.rowCount).map { metricsStore.heightForRow($0) }

        // Restore anchor to prevent visual jump
        if anchor != nil {
            restoreScrollAnchor(anchor, newIdentifiers: currentRowIdentifiers)
        }

        // Notify layout that metrics changed
        layout?.invalidateLayout()
    }

    /// Calculates the range of rows currently visible in the viewport.
    private func calculateVisibleRowRange() -> Range<Int> {
        let viewportTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
        let viewportBottom = viewportTop + collectionView.bounds.height

        guard viewportBottom > viewportTop else { return 0..<0 }

        // Use binary search to find first and last visible rows
        let firstRow = metricsStore.rowForYOffset(viewportTop)
        let lastRow = metricsStore.rowForYOffset(viewportBottom)

        let clampedFirst = max(0, firstRow)
        let clampedLast = min(metricsStore.rowCount, lastRow + 1)

        return clampedFirst..<clampedLast
    }

    public func reloadEverything(){
        self.layout?.clearLayoutCache()
        self.collectionView.reloadData()
    }
    public func reloadRowsOnly(){
        
    }
    
    public func reload(){
        var data = DataTableContent()
        var headerTitles = [String]()
        
        let numberOfColumns = dataSource?.numberOfColumns(in: self) ?? 0
        let numberOfRows = dataSource?.numberOfRows(in: self) ?? 0
        
        for columnIndex in 0..<numberOfColumns {
            guard let headerTitle = dataSource?.dataTable(self, headerTitleForColumnAt: columnIndex) else {
                return
            }
            headerTitles.append(headerTitle)
        }
        
        for index in 0..<numberOfRows {
            guard let rowData = self.dataSource?.dataTable(self, dataForRowAt: index) else {
                return
            }
            data.append(rowData)
        }
        self.layout?.clearLayoutCache()
        self.collectionView.resetScrollPositionToTop()
        self.set(data: data, headerTitles: headerTitles, options: self.options)
        calculateColumnWidths()  // Rebuild metricsStore before reloadData
        self.collectionView.reloadData()
    }
    
    public func data(for indexPath: IndexPath) -> DataTableValueType {
        return rows[indexPath.section][indexPath.row].data
    }

    // MARK: - Row Remeasurement (Live Editing Support)

    /// Remeasures the height of a specific row without reloading the cell.
    ///
    /// Use this method when a cell's content changes (e.g., during live text editing)
    /// and you need to update the row height without triggering a full reload.
    /// This preserves keyboard focus and cell state.
    ///
    /// - Parameter row: The row index to remeasure.
    /// - Returns: `true` if the height changed and layout was invalidated, `false` otherwise.
    ///
    /// Example:
    /// ```swift
    /// func textViewDidChange(_ textView: UITextView) {
    ///     // Update your model
    ///     notes[rowIndex].content = textView.text
    ///
    ///     // Remeasure the row without cell reload
    ///     dataTable.remeasureRow(rowIndex)
    /// }
    /// ```
    @discardableResult
    public func remeasureRow(_ row: Int) -> Bool {
        guard row >= 0 && row < metricsStore.rowCount else { return false }
        guard usesAutomaticRowHeights else { return false }

        let oldHeight = metricsStore.heightForRow(row)

        // Measure visible cells directly - they have the current content
        // If not all columns visible, use max(visible, old) to allow growing without shrinking
        // (sizing cells have old data, so we can't rely on them for live edits)
        let newHeight: CGFloat
        if let visibleHeight = measureVisibleRowHeight(row, allowPartial: true) {
            let allColumnsVisible = visibleColumnCountForRow(row) >= numberOfColumns()
            if allColumnsVisible {
                // All columns visible - use measured height directly
                newHeight = visibleHeight
            } else {
                // Partial visibility - allow growing but don't shrink
                // (a non-visible column might be taller)
                newHeight = max(visibleHeight, oldHeight)
            }
        } else {
            // Row not visible at all - fall back to sizing cells
            newHeight = measureHeightForRow(row)
        }

        guard abs(newHeight - oldHeight) > 0.5 else { return false }

        // Update metrics store with new height
        metricsStore.setHeight(newHeight, forRow: row)
        metricsStore.rebuildOffsets(fromRow: row)

        // Sync to legacy rowHeights array
        if row < rowHeights.count {
            rowHeights[row] = newHeight
        }

        // Invalidate layout without reloading cells
        layout?.invalidateLayout()

        return true
    }

    /// Returns the number of visible columns for a given row.
    private func visibleColumnCountForRow(_ row: Int) -> Int {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        return visibleIndexPaths.filter { $0.section == row }.count
    }

    /// Measures the height of visible cells directly from the collection view.
    /// - Parameters:
    ///   - row: The row index to measure.
    ///   - allowPartial: If true, returns height even if not all columns visible.
    /// - Returns: The measured height, or nil if the row has no visible cells.
    private func measureVisibleRowHeight(_ row: Int, allowPartial: Bool = false) -> CGFloat? {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let visibleForRow = visibleIndexPaths.filter { $0.section == row }

        // If row not visible at all, return nil
        guard !visibleForRow.isEmpty else { return nil }

        // If not allowing partial and not all columns visible, return nil
        if !allowPartial {
            let columnCount = numberOfColumns()
            guard visibleForRow.count >= columnCount else { return nil }
        }

        // Trigger layout on all visible cells for this row
        for ip in visibleForRow {
            if let cell = collectionView.cellForItem(at: ip) {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
        }

        // Measure all visible cells in this row to find max height
        var maxHeight: CGFloat = 0
        for ip in visibleForRow {
            if let rowCell = collectionView.cellForItem(at: ip) {
                let targetSize = CGSize(
                    width: rowCell.bounds.width,
                    height: UIView.layoutFittingCompressedSize.height
                )
                let size = rowCell.contentView.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )
                maxHeight = max(maxHeight, ceil(size.height))
            }
        }

        return maxHeight > 0 ? max(maxHeight, options.rowHeightMode.estimatedHeight) : nil
    }
}

// MARK: - Snapshot-Based Incremental Updates
public extension SwiftDataTable {

    /// Updates the table data using snapshot diffing with automatic content-based identity.
    ///
    /// This method uses row content to determine identity. Two rows with identical content
    /// are considered the same row. For more control, use `setData(_:rowIdentifiers:...)`.
    ///
    /// - Parameters:
    ///   - data: The new complete data set for the table
    ///   - animatingDifferences: If true, animates insertions/deletions. If false, reloads immediately.
    ///   - completion: Called when the update completes
    ///
    /// Example:
    /// ```swift
    /// // Modify your local data
    /// myData.append(newRow)
    /// myData.remove(at: 0)
    ///
    /// // Tell the table to diff and update
    /// dataTable.setData(myData, animatingDifferences: true)
    /// ```
    func setData(
        _ data: DataTableContent,
        animatingDifferences: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Use content-based identity when no explicit IDs provided
        let identifiers = data.map { row in
            row.map { $0.stringRepresentation }.joined(separator: "\u{001F}")
        }
        setData(data, rowIdentifiers: identifiers, animatingDifferences: animatingDifferences, completion: completion)
    }

    /// Updates the table data using snapshot diffing with explicit row identifiers.
    ///
    /// Use this method when your rows have stable identifiers (e.g., database IDs).
    /// This is more robust than content-based identity for real-world data.
    ///
    /// - Parameters:
    ///   - data: The new complete data set for the table
    ///   - rowIdentifiers: Array of unique identifiers, one per row. Must match data.count.
    ///   - animatingDifferences: If true, animates insertions/deletions. If false, reloads immediately.
    ///   - completion: Called when the update completes
    ///
    /// Example with database records:
    /// ```swift
    /// // Your model has stable IDs
    /// struct User { let id: String; let name: String; let score: Int }
    ///
    /// // Convert to table format
    /// let tableData: DataTableContent = users.map { user in
    ///     [.string(user.id), .string(user.name), .int(user.score)]
    /// }
    /// let identifiers = users.map { $0.id }
    ///
    /// // Update with stable IDs
    /// dataTable.setData(tableData, rowIdentifiers: identifiers, animatingDifferences: true)
    /// ```
    func setData(
        _ data: DataTableContent,
        rowIdentifiers: [String],
        animatingDifferences: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard data.count == rowIdentifiers.count else {
            assertionFailure("rowIdentifiers count (\(rowIdentifiers.count)) must match data count (\(data.count))")
            self.collectionView.reloadData()
            completion?(false)
            return
        }

        let oldIdentifiers = self.currentRowIdentifiers
        let oldViewModels = self.rowViewModels

        // Create new view models
        let newViewModels: DataTableViewModelContent = data.map { row in
            row.map { DataCellViewModel(data: $0) }
        }

        // Apply the diff with animation, or just reload
        if animatingDifferences && !oldViewModels.isEmpty {
            applyDiff(
                oldIdentifiers: oldIdentifiers,
                newIdentifiers: rowIdentifiers,
                newData: data,
                newViewModels: newViewModels,
                completion: completion
            )
        } else {
            // No animation or starting from empty - update data and reload
            self.currentRowIdentifiers = rowIdentifiers
            self.dataStructure = DataStructureModel(
                data: data,
                headerTitles: self.dataStructure.headerTitles,
                useEstimatedColumnWidths: options.columnWidthMode.prefersEstimatedTextWidths
            )
            self.rowViewModels = newViewModels
            invalidateRowHeights()
            layout?.clearLayoutCache()
            calculateColumnWidths()  // Rebuild metricsStore before reloadData
            self.collectionView.reloadData()
            completion?(true)
        }
    }

    private func applyDiff(
        oldIdentifiers: [String],
        newIdentifiers: [String],
        newData: DataTableContent,
        newViewModels: DataTableViewModelContent,
        completion: ((Bool) -> Void)?
    ) {
        let oldViewModels = self.rowViewModels

        // Build identity maps for O(n) lookup
        var oldIdToIndex = [String: Int]()
        for (index, id) in oldIdentifiers.enumerated() {
            oldIdToIndex[id] = index
        }

        var newIdToIndex = [String: Int]()
        for (index, id) in newIdentifiers.enumerated() {
            newIdToIndex[id] = index
        }

        // Calculate deletions (IDs in old but not in new)
        var deletions = IndexSet()
        for (index, id) in oldIdentifiers.enumerated() {
            if newIdToIndex[id] == nil {
                deletions.insert(index)
            }
        }

        // Calculate insertions (IDs in new but not in old)
        var insertions = IndexSet()
        for (index, id) in newIdentifiers.enumerated() {
            if oldIdToIndex[id] == nil {
                insertions.insert(index)
            }
        }

        // Calculate reloads (same ID but content changed)
        // Check if TypedAPI provided pre-computed changed identifiers via isContentEqual
        let precomputedChanges = self.precomputedChangedIdentifiers
        self.precomputedChangedIdentifiers = nil  // Clear after reading (one-time use)

        var reloadIndexPaths = Set<IndexPath>()
        var reloadSections = IndexSet()
        var changedRows = Set<Int>()
        for (newIndex, id) in newIdentifiers.enumerated() {
            guard let oldIndex = oldIdToIndex[id] else { continue }

            let rowChangedById = precomputedChanges?.contains(id) ?? false
            if precomputedChanges != nil && !rowChangedById {
                continue
            }

            let oldRow = oldViewModels[oldIndex]
            let newRow = newViewModels[newIndex]

            guard oldRow.count == newRow.count else {
                reloadSections.insert(newIndex)
                changedRows.insert(newIndex)
                continue
            }

            var changedColumns = [Int]()
            for columnIndex in 0..<newRow.count {
                if oldRow[columnIndex].data != newRow[columnIndex].data {
                    changedColumns.append(columnIndex)
                }
            }

            if rowChangedById || !changedColumns.isEmpty {
                changedRows.insert(newIndex)
                if rowChangedById && changedColumns.isEmpty {
                    for columnIndex in 0..<newRow.count {
                        reloadIndexPaths.insert(IndexPath(item: columnIndex, section: newIndex))
                    }
                } else {
                    for columnIndex in changedColumns {
                        reloadIndexPaths.insert(IndexPath(item: columnIndex, section: newIndex))
                    }
                }
            }
        }

        // Helper to apply the new data
        let applyNewData = { [weak self] in
            guard let self = self else { return }
            self.currentRowIdentifiers = newIdentifiers
            self.dataStructure = DataStructureModel(
                data: newData,
                headerTitles: self.dataStructure.headerTitles,
                useEstimatedColumnWidths: self.options.columnWidthMode.prefersEstimatedTextWidths
            )
            self.rowViewModels = newViewModels
            // Note: Layout metadata is adjusted incrementally via prepare(forCollectionViewUpdates:)
            // No need to clear entire cache or invalidate all row heights
        }

        // Phase 4: Capture scroll anchor before updates to preserve visual position
        let scrollAnchor = captureScrollAnchor()

        // If there are many changes, just reload (performance optimization)
        let totalChanges = deletions.count + insertions.count + changedRows.count
        let totalRows = max(oldIdentifiers.count, newIdentifiers.count)
        if totalRows > 0 && Double(totalChanges) / Double(totalRows) > 0.5 {
            // More than 50% changed - apply data, rebuild metrics, and reload
            applyNewData()
            invalidateRowHeights()
            layout?.clearLayoutCache()
            calculateColumnWidths()  // This also rebuilds metricsStore
            self.collectionView.reloadData()
            // Phase 4: Restore scroll anchor after layout updates
            self.collectionView.layoutIfNeeded()
            self.restoreScrollAnchor(scrollAnchor, newIdentifiers: newIdentifiers)
            completion?(true)
            return
        }

        // For animated batch updates, we need to:
        // 1. Apply deletions first (using old data indices)
        // 2. Then apply the new data
        // 3. Then apply insertions (using new data indices)
        // 4. Reload sections with content changes
        //
        // UICollectionView's performBatchUpdates handles this automatically
        // if we provide the correct indices and update data at the right time.

        // Phase 2 fix: In auto-height or delegate-height modes, cell-level reloads don't trigger
        // layout metadata rebuild. Convert them to section reloads so prepare(forCollectionViewUpdates:)
        // sees section-level changes and triggers calculateColumnWidths() + prepareMetadata().
        if requiresLayoutMetadataRebuildOnContentChange && !reloadIndexPaths.isEmpty {
            for indexPath in reloadIndexPaths {
                reloadSections.insert(indexPath.section)
            }
            reloadIndexPaths.removeAll()
        }

        // Apply batch updates
        let sortedReloadIndexPaths = reloadIndexPaths.sorted {
            if $0.section == $1.section {
                return $0.item < $1.item
            }
            return $0.section < $1.section
        }

        // Phase 3: Mark dirty rows for incremental height updates
        // Changed rows (content changed) + insertions (new rows) need height measurement
        var dirtyRowIndices = IndexSet(changedRows)
        dirtyRowIndices.formUnion(insertions)
        if !dirtyRowIndices.isEmpty {
            metricsStore.invalidateRows(dirtyRowIndices)
        }

        self.collectionView.performBatchUpdates({
            // Delete sections first (indices relative to old data)
            if !deletions.isEmpty {
                self.collectionView.deleteSections(deletions)
            }

            // Now apply the new data - this must happen during the batch update
            // so the collection view sees the correct number of sections for insertions
            applyNewData()

            // Phase 3: Incremental height updates - now that data is applied, we can measure with new data
            self.performIncrementalHeightUpdate(deletions: deletions, insertions: insertions)

            // Insert sections (indices relative to new data)
            if !insertions.isEmpty {
                self.collectionView.insertSections(insertions)
            }

            // Reload rows/cells with content changes (indices relative to new data)
            if !reloadSections.isEmpty {
                self.collectionView.reloadSections(reloadSections)
            }
            if !sortedReloadIndexPaths.isEmpty {
                self.collectionView.reloadItems(at: sortedReloadIndexPaths)
            }
        }, completion: { [weak self] finished in
            // Phase 4: Restore scroll anchor after batch updates complete
            self?.restoreScrollAnchor(scrollAnchor, newIdentifiers: newIdentifiers)
            completion?(finished)
        })
    }

    /// Compares two rows for content equality (used by diffing)
    private func rowContentEqual(_ old: [DataCellViewModel], _ new: [DataCellViewModel]) -> Bool {
        guard old.count == new.count else { return false }
        for i in 0..<old.count {
            if old[i].data != new[i].data {
                return false  // Early exit on first difference
            }
        }
        return true
    }

}

public extension SwiftDataTable {
    func createDataModels(with data: DataStructureModel){
        self.dataStructure = data
    }
    
    func createDataCellViewModels(with dataStructure: DataStructureModel){// -> DataTableViewModelContent {
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
        //let viewModels: DataTableViewModelContent =
        self.rowViewModels = dataStructure.data.map{ currentRowData in
            return currentRowData.map {
                return DataCellViewModel(data: $0)
            }
        }
        self.paginationViewModel = PaginationHeaderViewModel()
        self.menuLengthViewModel = MenuLengthHeaderViewModel()
        //        self.bindViewToModels()
    }
    
    //    //MARK: - Events
    //    private func bindViewToModels(){
    //        self.menuLengthViewModel.searchTextFieldDidChangeEvent = { [weak self] text in
    //            self?.searchTextEntryDidChange(text)
    //        }
    //    }
    //
    //    private func searchTextEntryDidChange(_ text: String){
    //        //call delegate function
    //        self.executeSearch(text)
    //    }
}



extension SwiftDataTable: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.numberOfColumns(in: self)
        }
        return self.dataStructure.columnCount
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        //if let dataSource = self.dataSource {
        //    return dataSource.numberOfRows(in: self)
        //}
        return self.numberOfRows()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = self.rowModel(at: indexPath)
        switch options.cellSizingMode {
        case .autoLayout(let provider):
            let reuseId = provider.reuseIdentifierFor(indexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
            provider.configure(cell, cellViewModel.data, indexPath)
            return cell
        case .defaultCell:
            let cell = cellViewModel.dequeueCell(collectionView: collectionView, indexPath: indexPath)
            if let dataCell = cell as? DataCell {
                dataCell.applyTextLayout(options.textLayout)
            }
            return cell
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsInLine: CGFloat = 6
        
        let inset = UIEdgeInsets.zero
        
        //        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let minimumInteritemSpacing: CGFloat = 0
        let contentwidth: CGFloat = minimumInteritemSpacing * (numberOfItemsInLine - 1)
        let itemWidth = (collectionView.frame.width - inset.left - inset.right - contentwidth) / numberOfItemsInLine
        let itemHeight: CGFloat = 100
        
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let kind = SupplementaryViewType(kind: elementKind)
        switch kind {
        case .paginationHeader:
            view.backgroundColor = UIColor.darkGray
        default:
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = UIColor.white
            }
        }
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellViewModel = self.rowModel(at: indexPath)
        
        if cellViewModel.highlighted {
            cell.contentView.backgroundColor = delegate?.dataTable?(self, highlightedColorForRowIndex: indexPath.item) ?? self.options.highlightedAlternatingRowColors[indexPath.section % self.options.highlightedAlternatingRowColors.count]
        }
        else {
            cell.contentView.backgroundColor = delegate?.dataTable?(self, unhighlightedColorForRowIndex: indexPath.item) ?? self.options.unhighlightedAlternatingRowColors[indexPath.section % self.options.unhighlightedAlternatingRowColors.count]
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let elementKind = SupplementaryViewType(kind: kind)
        let viewModel: CollectionViewSupplementaryElementRepresentable
        switch elementKind {
        case .searchHeader: viewModel = self.menuLengthViewModel
        case .columnHeader: viewModel = self.headerViewModels[indexPath.index]
        case .footerHeader: viewModel = self.footerViewModels[indexPath.index]
        case .paginationHeader: viewModel = self.paginationViewModel
        }
        return viewModel.dequeueView(collectionView: collectionView, viewForSupplementaryElementOfKind: kind, for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem?(self, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didDeselectItem?(self, indexPath: indexPath)
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
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(self.searchBar.isFirstResponder){
            self.searchBar.resignFirstResponder()
        }
    }
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

        // Phase 5: Lazy measurement for large-scale mode
        measureVisibleRowsIfNeeded()
    }
}

//MARK: - Refresh
extension SwiftDataTable {
    //    @objc fileprivate func refreshOptions(sender: UIRefreshControl) {
    //        self.refreshEvent?()
    //    }
    //
    //    func beginRefreshing(){
    //        self.refreshControl.beginRefreshing()
    //    }
    //
    //    func endRefresh(){
    //        self.refreshControl.endRefreshing()
    //    }
}

extension SwiftDataTable {
    
    fileprivate func update(){
        //        print("\nUpdate")
        self.reloadEverything()
    }
    
    fileprivate func applyDefaultColumnOrder(_ columnOrder: DataTableColumnOrder){
        self.highlight(column: columnOrder.index)
        self.applyColumnOrder(columnOrder)
        self.sort(column: columnOrder.index, sort: self.headerViewModels[columnOrder.index].sortType)
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
            self.currentRowViewModels = self.currentRowViewModels.sorted(by: ascendingOrder)
        case .descending:
            self.currentRowViewModels = self.currentRowViewModels.sorted(by: descendingOrder)
        default:
            break
        }
    }
    
    func highlight(column: Int){
        self.currentRowViewModels.forEach {
            $0.forEach { $0.highlighted = false }
            $0[column].highlighted = true
        }
    }
    
    func applyColumnOrder(_ columnOrder: DataTableColumnOrder){
        Array(0..<self.headerViewModels.count).forEach {
            if columnOrder.index == $0 {
                self.headerViewModels[$0].sortType = columnOrder.order
            }
            else {
                self.headerViewModels[$0].sortType.toggleToDefault()
            }
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
        //        self.headerViewModels.forEach { print($0.sortType) }
    }
    
    //This is actually mapped to sections
    func numberOfRows() -> Int {
        return self.currentRowViewModels.count
    }
    func heightForRow(index: Int) -> CGFloat {
        if let height = self.delegate?.dataTable?(self, heightForRowAt: index) {
            return height
        }
        if usesAutomaticRowHeights {
            if rowHeights.indices.contains(index) {
                return rowHeights[index]
            }
            return options.rowHeightMode.estimatedHeight
        }
        switch options.rowHeightMode {
        case .fixed(let height):
            return height
        case .automatic(let estimated, _):
            return estimated
        }
    }
    
    func rowModel(at indexPath: IndexPath) -> DataCellViewModel {
        return self.currentRowViewModels[indexPath.section][indexPath.row]
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
        return self.delegate?.shouldContentWidthScaleToFillFrame?(in: self) ?? self.options.shouldContentWidthScaleToFillFrame
    }
    
    func shouldSectionHeadersFloat() -> Bool {
        return self.delegate?.shouldSectionHeadersFloat?(in: self) ?? self.options.shouldSectionHeadersFloat
    }
    
    func shouldSectionFootersFloat() -> Bool {
        return self.delegate?.shouldSectionFootersFloat?(in: self) ?? self.options.shouldSectionFootersFloat
    }
    
    func shouldSearchHeaderFloat() -> Bool {
        return self.delegate?.shouldSearchHeaderFloat?(in: self) ?? self.options.shouldSearchHeaderFloat
    }
    
    func shouldShowSearchSection() -> Bool {
        return self.delegate?.shouldShowSearchSection?(in: self) ?? self.options.shouldShowSearchSection
    }
    func shouldShowFooterSection() -> Bool {
        return self.delegate?.shouldShowSearchSection?(in: self) ?? self.options.shouldShowFooter
    }
    func shouldShowPaginationSection() -> Bool {
        return false
    }
    
    func heightForSectionFooter() -> CGFloat {
        return self.delegate?.heightForSectionFooter?(in: self) ?? self.options.heightForSectionFooter
    }
    
    func heightForSectionHeader() -> CGFloat {
        return self.delegate?.heightForSectionHeader?(in: self) ?? self.options.heightForSectionHeader
    }
    
    
    func widthForColumn(index: Int) -> CGFloat {
        //May need to call calculateColumnWidths.. I want to deprecate it..
        guard let width = self.delegate?.dataTable?(self, widthForColumnAt: index) else {
            return self.columnWidths[index]
        }
        //TODO: Implement it so that the preferred column widths are calculated first, and then the scaling happens after to fill the frame.
//        if width != SwiftDataTableAutomaticColumnWidth {
//            self.columnWidths[index] = width
//        }
        return width
    }
    
    func heightForSearchView() -> CGFloat {
        guard self.shouldShowSearchSection() else {
            return 0
        }
        return self.delegate?.heightForSearchView?(in: self) ?? self.options.heightForSearchView
    }
    
    func showVerticalScrollBars() -> Bool {
        return self.delegate?.shouldShowVerticalScrollBars?(in: self) ?? self.options.shouldShowVerticalScrollBars
    }
    
    func showHorizontalScrollBars() -> Bool {
        return self.delegate?.shouldShowHorizontalScrollBars?(in: self) ?? self.options.shouldShowHorizontalScrollBars
    }
    
    func heightOfInterRowSpacing() -> CGFloat {
        return self.delegate?.heightOfInterRowSpacing?(in: self) ?? self.options.heightOfInterRowSpacing
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
        let mode = options.columnWidthModeProvider?(index) ?? options.columnWidthMode
        let headerMinimum = minimumHeaderColumnWidth(index: index)
        switch mode {
        case .fixed(let width):
            return clampColumnWidth(width, headerMinimum: headerMinimum)
        case .fitContentText(let strategy):
            return dataStructure.columnWidth(
                index: index,
                strategy: strategy,
                configuration: options
            )
        case .fitContentAutoLayout(let sample):
            let contentWidth = autoLayoutWidthForColumn(index: index, sample: sample)
            return clampColumnWidth(contentWidth, headerMinimum: headerMinimum)
        }
    }
    
    func calculateContentWidth() -> CGFloat {
        return Array(0..<self.numberOfColumns()).reduce(self.widthForRowHeader()) { $0 + self.widthForColumn(index: $1)}
    }
    
    
    func minimumColumnWidth() -> CGFloat {
        return self.options.minColumnWidth
    }
    
    func minimumHeaderColumnWidth(index: Int) -> CGFloat {
        let textWidth = CGFloat(self.dataStructure.headerTitles[index].widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)))
        return textWidth + DataHeaderFooter.Properties.sortIndicatorWidth + DataHeaderFooter.Properties.labelHorizontalMargin
    }

    private func clampColumnWidth(_ width: CGFloat, headerMinimum: CGFloat) -> CGFloat {
        let minClamped = max(width, options.minColumnWidth)
        let maxClamped = options.maxColumnWidth.map { min(minClamped, $0) } ?? minClamped
        return max(maxClamped, headerMinimum)
    }

    private func autoLayoutWidthForColumn(index: Int, sample: DataTableAutoLayoutWidthSample) -> CGFloat {
        guard case .autoLayout(let provider) = options.cellSizingMode else {
            assertionFailure("fitContentAutoLayout requires cellSizingMode.autoLayout(provider:).")
            return options.minColumnWidth
        }

        let rowCount = numberOfRows()
        guard rowCount > 0 else {
            return 0
        }

        let indices = sampledRowIndices(rowCount: rowCount, sample: sample)
        var measuredWidths = [CGFloat]()
        measuredWidths.reserveCapacity(indices.count)

        for rowIndex in indices {
            let row = currentRowViewModels[rowIndex]
            guard index < row.count else { continue }
            let value = row[index].data
            let indexPath = IndexPath(item: index, section: rowIndex)
            let reuseId = provider.reuseIdentifierFor(indexPath)
            let sizingCell = self.sizingCell(for: reuseId, provider: provider)
            provider.configure(sizingCell, value, indexPath)

            sizingCell.bounds = CGRect(x: 0, y: 0, width: 1, height: options.rowHeightMode.estimatedHeight)
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()

            let size = sizingCell.contentView.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .fittingSizeLevel
            )
            measuredWidths.append(ceil(size.width))
        }

        switch sample {
        case .all, .sampledMax:
            return measuredWidths.max() ?? 0
        case .percentile(let percentile, _):
            return percentileWidth(in: measuredWidths, percentile: percentile)
        }
    }

    private func sampledRowIndices(rowCount: Int, sample: DataTableAutoLayoutWidthSample) -> [Int] {
        switch sample {
        case .all:
            return Array(0..<rowCount)
        case .sampledMax(let sampleSize), .percentile(_, let sampleSize):
            guard sampleSize > 0, rowCount > sampleSize else {
                return Array(0..<rowCount)
            }
            let strideValue = max(1, Int(ceil(Double(rowCount) / Double(sampleSize))))
            var result = [Int]()
            var index = 0
            while index < rowCount && result.count < sampleSize {
                result.append(index)
                index += strideValue
            }
            return result
        }
    }

    private func percentileWidth(in widths: [CGFloat], percentile: Double) -> CGFloat {
        guard !widths.isEmpty else {
            return 0
        }
        let clampedPercentile = min(max(percentile, 0), 1)
        let sorted = widths.sorted()
        let percentileIndex = Int(round(clampedPercentile * CGFloat(sorted.count - 1)))
        return sorted[percentileIndex]
    }
    
    func heightForPaginationView() -> CGFloat {
        guard self.shouldShowPaginationSection() else {
            return 0
        }
        return 35
    }
    
    func fixedColumns() -> DataTableFixedColumnType? {
        return delegate?.fixedColumns?(for: self) ?? self.options.fixedColumns
    }
    
    func shouldSupportRightToLeftInterfaceDirection() -> Bool {
        return delegate?.shouldSupportRightToLeftInterfaceDirection?(in: self) ?? self.options.shouldSupportRightToLeftInterfaceDirection
    }
}

//MARK: - Search Bar Delegate
extension SwiftDataTable: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.executeSearch(searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    //TODO: Use Regular expression isntead
    private func filteredResults(with needle: String, on originalArray: DataTableViewModelContent) -> DataTableViewModelContent {
        var filteredSet = DataTableViewModelContent()
        let needle = needle.lowercased()
        Array(0..<originalArray.count).forEach{
            let row = originalArray[$0]
            //Add some sort of index array so we use that to iterate through the columns
            //The idnex array will be defined by the column definition inside the configuration object provided by the user
            //Index array might look like this [1, 3, 4]. Which means only those columns should be searched into
            for item in row {
                let stringData: String = item.data.stringRepresentation.lowercased()
                if stringData.lowercased().range(of: needle) != nil{
                    filteredSet.append(row)
                    //Stop searching through the rest of the columns in the same row and break
                    break;
                }
            }
        }
        
        return filteredSet
    }
    
    
    fileprivate func executeSearch(_ needle: String){
        let oldFilteredRowViewModels = self.searchRowViewModels!
        
        if needle.isEmpty {
            //DONT DELETE ORIGINAL CACHE FOR LAYOUTATTRIBUTES
            //MAYBE KEEP TWO COPIES.. ONE FOR SEARCH AND ONE FOR DEFAULT
            self.searchRowViewModels = self.rowViewModels
        }
        else {
            self.searchRowViewModels = self.filteredResults(with: needle, on: self.rowViewModels)
            //            print("needle: \(needle), rows found: \(self.searchRowViewModels!.count)")
        }
        invalidateRowHeights()
        self.layout?.clearLayoutCache()
        //        self.collectionView.scrollToItem(at: IndexPath(0), at: UICollectionViewScrollPosition.top, animated: false)
        //So the header view doesn't flash when user is at the bottom of the collectionview and a search result is returned that doesn't feel the screen.
        self.collectionView.resetScrollPositionToTop()
        self.differenceSorter(oldRows: oldFilteredRowViewModels, filteredRows: self.searchRowViewModels)
        
    }
    
    private func differenceSorter(
        oldRows: DataTableViewModelContent,
        filteredRows: DataTableViewModelContent,
        animations: Bool = false,
        completion: ((Bool) -> Void)? = nil){
        if animations == false {
            UIView.setAnimationsEnabled(false)
        }
        self.collectionView.performBatchUpdates({
            //finding the differences
            
            //The currently displayed rows - in this case named old rows - is scanned over.. deleting any entries that are not existing in the newly created filtered list.
            for (oldIndex, oldRowViewModel) in oldRows.enumerated() {
                let index = self.searchRowViewModels.firstIndex { rowViewModel in
                    return oldRowViewModel == rowViewModel
                }
                if index == nil {
                    self.collectionView.deleteSections([oldIndex])
                }
            }
            
            //Iterates over the new search results and compares them with the current result set displayed - in this case name old - inserting any entries that are not existant in the currently displayed result set
            for (currentIndex, currentRolwViewModel) in filteredRows.enumerated() {
                let oldIndex = oldRows.firstIndex { oldRowViewModel in
                    return currentRolwViewModel == oldRowViewModel
                }
                if oldIndex == nil {
                    self.collectionView.insertSections([currentIndex])
                }
            }
        }, completion: { finished in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            if animations == false {
                UIView.setAnimationsEnabled(true)
            }
            completion?(finished)
        })
    }
}


extension SwiftDataTable {
    func set(options: DataTableConfiguration? = nil){
        self.layout = SwiftDataTableLayout(dataTable: self)
        self.rowViewModels = DataTableViewModelContent()
        self.paginationViewModel = PaginationHeaderViewModel()
        self.menuLengthViewModel = MenuLengthHeaderViewModel()
        invalidateRowHeights()
        registerCustomCellIfNeeded()
        //self.reload();
    }
}

// MARK: - Navigation Bar Search Controller Support
extension SwiftDataTable {

    /// Creates and configures a UISearchController for use with the navigation bar.
    ///
    /// This method simplifies integrating SwiftDataTable with iOS's native navigation bar search.
    /// The returned UISearchController is pre-configured for optimal behavior with the data table.
    ///
    /// **Usage:**
    /// ```swift
    /// let searchController = dataTable.makeSearchController()
    /// navigationItem.searchController = searchController
    /// navigationItem.hidesSearchBarWhenScrolling = true
    /// ```
    ///
    /// - Note: Remember to set `config.shouldShowSearchSection = false` to hide the embedded search bar.
    /// - Returns: A configured UISearchController that filters the data table.
    public func makeSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search"
        return controller
    }

    /// Installs a UISearchController in the navigation bar of the given view controller.
    ///
    /// This is the simplest way to add native iOS search bar behavior to your data table.
    /// It automatically:
    /// - Creates and configures the UISearchController
    /// - Attaches it to the view controller's navigation item
    /// - Enables the auto-hide on scroll behavior (iOS 16+)
    /// - Hides the embedded search bar
    ///
    /// **Usage:**
    /// ```swift
    /// override func viewDidLoad() {
    ///     super.viewDidLoad()
    ///     view.addSubview(dataTable)
    ///     dataTable.installSearchController(on: self)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - viewController: The view controller whose navigation item will receive the search controller.
    ///   - hidesWhenScrolling: Whether the search bar hides when scrolling. Default is `true`.
    /// - Returns: The installed UISearchController for further customization if needed.
    @discardableResult
    public func installSearchController(
        on viewController: UIViewController,
        hidesWhenScrolling: Bool = true
    ) -> UISearchController {
        let searchController = makeSearchController()

        // Hide embedded search bar
        self.searchBar.isHidden = true

        // Install on navigation item
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = hidesWhenScrolling
        viewController.definesPresentationContext = true

        // Tell navigation controller which scroll view to track (iOS 16+)
        if #available(iOS 16.0, *) {
            viewController.setContentScrollView(self.collectionView, for: .top)
        }

        return searchController
    }
}

// MARK: - UISearchResultsUpdating
extension SwiftDataTable: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        executeSearch(searchController.searchBar.text ?? "")
    }
}
