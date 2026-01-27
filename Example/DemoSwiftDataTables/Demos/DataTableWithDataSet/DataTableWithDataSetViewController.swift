//
//  DataTableWithDataSetViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/09/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class DataTableWithDataSetViewController: UIViewController {

    // MARK: - Data

    let sampleData = samplePeople()

    let columns: [DataTableColumn<SamplePerson>] = [
        .init("Id", \.id),
        .init("Name", \.name),
        .init("Email", \.email),
        .init("Number", \.phone),
        .init("City", \.city),
        .init("Balance", \.balance)
    ]

    // MARK: - UI

    private let instructions = InstructionsView(
        description: "Type-safe data initialization using Identifiable models and KeyPath column definitions.",
        config: "Config: defaultOrdering by Name (ascending) · fixed columns (1 left, 1 right)"
    )

    private lazy var dataTable: SwiftDataTable = {
        var options = DataTableConfiguration()
        options.shouldContentWidthScaleToFillFrame = false
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)

        let table = SwiftDataTable(data: sampleData, columns: columns, options: options)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Static Data Set"
        view.backgroundColor = .systemBackground

        view.addSubview(instructions)
        view.addSubview(dataTable)

        NSLayoutConstraint.activate([
            instructions.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            instructions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dataTable.topAnchor.constraint(equalTo: instructions.bottomAnchor, constant: 12),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - SwiftDataTableDelegate

extension DataTableWithDataSetViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }

    func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return .init(leftColumns: 1, rightColumns: 1)
    }
}
