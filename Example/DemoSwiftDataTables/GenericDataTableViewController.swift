//
//  GenericDataTableViewController.swift
//  SwiftDataTables_Example
//
//  Created by Pavan Kataria on 31/10/2019.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import SwiftDataTables
import UIKit

class GenericDataTableViewController: UIViewController {
    
    lazy var dataTable = makeDataTable()
    let configuration: DataTableConfiguration
    
    public init(with configuration: DataTableConfiguration){
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    func setupViews() {
        navigationController?.navigationBar.isTranslucent = false
        title = "Employee Balances"
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(dataTable)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
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
        return exampleDataSet().map {
            $0.compactMap (DataTableValueType.init)
        }
    }
}
extension GenericDataTableViewController {
    func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(
            data: self.data(),
            headerTitles: self.columnHeaders(),
            options: self.configuration
        )
        dataTable.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.delegate = self
        return dataTable
    }
}

extension GenericDataTableViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
}
