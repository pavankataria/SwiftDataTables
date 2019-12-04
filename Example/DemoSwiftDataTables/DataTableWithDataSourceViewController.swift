//
//  DataTableWithDataSourceViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 05/04/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class DataTableWithDataSourceViewController: UIViewController {
    
    lazy var dataTable = makeDataTable()
    var dataSource: DataTableContent = []
    let headerTitles = ["Name", "Fav Beverage", "Fav language", "Short term goals", "Height"]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    func setupViews() {
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBar.isTranslucent = false
        title = "Streaming fans"
        view.backgroundColor = UIColor.white
        view.addSubview(dataTable)
        dataTable.reload()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    public func addDataSourceAfter(){
        
        self.dataSource = [
            [
                DataTableValueType.string("Pavan"),
                DataTableValueType.string("Juice"),
                DataTableValueType.string("Swift and Php"),
                DataTableValueType.string("Be a game publisher"),
                DataTableValueType.float(175.25)
            ],
            [
                DataTableValueType.string("NoelDavies"),
                DataTableValueType.string("Water"),
                DataTableValueType.string("Php and Javascript"),
                DataTableValueType.string("'Be a fucking paratrooper machine'"),
                DataTableValueType.float(185.80)
            ],
            [
                DataTableValueType.string("Redsaint"),
                DataTableValueType.string("Cheerwine and Dr.Pepper"),
                DataTableValueType.string("Java"),
                DataTableValueType.string("'Creating an awesome RPG Game game'"),
                DataTableValueType.float(185.42)
            ],
        ]
        dataTable.reload()
    }
}
extension DataTableWithDataSourceViewController {
    private func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(dataSource: self)
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.delegate = self
        return dataTable
    }
}
extension DataTableWithDataSourceViewController: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 4
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}

extension DataTableWithDataSourceViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
}
