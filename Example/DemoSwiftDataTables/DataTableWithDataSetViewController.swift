//
//  DataTableWithDataSetViewController.swift
//  SwiftDataTables
//
//  Created by pavankataria on 03/09/2017.
//  Copyright (c) 2017 pavankataria. All rights reserved.
//

import UIKit

class DataTableWithDataSetViewController: UIViewController {
    
    var dataTable: SwiftDataTable! = nil

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Employee Balances"

        self.view.backgroundColor = UIColor.white
        
        var options = DataTableConfiguration()
        options.shouldContentWidthScaleToFillFrame = false
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        
        self.dataTable = SwiftDataTable(
            data: self.data(),
            headerTitles: self.columnHeaders(),
            options: options
        )
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.frame = self.view.frame
        self.view.addSubview(self.dataTable);
        self.dataTable.delegate = self
    }
}
extension DataTableWithDataSetViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        print("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
}
extension DataTableWithDataSetViewController {
    func columnHeaders() -> [String] {
        return [
            "Id",
            "Name",
            "Email",
            "Number",
            "City",
            "Balance"
        ]
    }
    
    func data() -> [[DataTableValueType]]{
        //This would be your json object
        var dataSet: [[Any]] = exampleDataSet()
        for _ in 0..<0 {
            dataSet += exampleDataSet()
        }
        
        return dataSet.map {
            $0.compactMap (DataTableValueType.init)
        }
    }
}
