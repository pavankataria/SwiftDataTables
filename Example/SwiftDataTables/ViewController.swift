//
//  ViewController.swift
//  SwiftDataTables
//
//  Created by pavankataria on 03/09/2017.
//  Copyright (c) 2017 pavankataria. All rights reserved.
//

//
//  ViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 14/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class ViewController: UIViewController {
    
    var dataTable: SwiftDataTable! = nil

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.view.backgroundColor = UIColor.white
        
        let options = DataTableConfiguration()
        options.defaultOrdering = DataTableColumnOrder(1, .ascending)
            
            
        self.dataTable = SwiftDataTable(
            data: self.data(),
            headerTitles: self.columnHeaders(),
            options: options
        )
        
        self.dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        //25/255, green: 33/255, blue: 39/255, alpha: 1)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.frame = self.view.bounds
        self.view.addSubview(self.dataTable);
    }
}
extension ViewController {
    func columnHeaders() -> [String] {
        return [
            "Id",
            "Name",
            "Email",
            "Number"
//            "City",
//            "Balance"
        ]
    }
    
    func data() -> [[String]]{
        let dataSet = exampleDataSet()
        return dataSet //[["lol"]]//array/
    }
}
