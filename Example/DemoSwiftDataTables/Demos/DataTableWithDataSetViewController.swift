//
//  DataTableWithDataSetViewController.swift
//  SwiftDataTables
//
//  Created by pavankataria on 03/09/2017.
//  Copyright (c) 2017 pavankataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class DataTableWithDataSetViewController: UIViewController {

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Static data initialisation. Pass your data array and headers directly to SwiftDataTable. Ideal for fixed datasets that don't change."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var configLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.text = "Config: defaultOrdering by Name (ascending) · fixed columns (1 left, 1 right)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, configLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var dataTable = makeDataTable()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        title = "Static Data Set"
        view.backgroundColor = .systemBackground
        view.addSubview(headerStack)
        view.addSubview(dataTable)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dataTable.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
extension DataTableWithDataSetViewController {
    func makeOptions() -> DataTableConfiguration {
        var options = DataTableConfiguration()
        options.shouldContentWidthScaleToFillFrame = false
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        return options
    }
    func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(
            data: data(),
            headerTitles: columnHeaders(),
            options: makeOptions()
        )
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return dataTable
    }
}

extension DataTableWithDataSetViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return .init(leftColumns: 1, rightColumns: 1)
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
