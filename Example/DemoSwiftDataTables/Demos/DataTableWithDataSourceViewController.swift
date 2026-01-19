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

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Dynamic data via SwiftDataTableDataSource protocol. The table queries your data source for row count and content, then call reload() when data changes."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Data", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(addDataTapped), for: .touchUpInside)
        return button
    }()

    private lazy var clearDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(clearDataTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [addDataButton, clearDataButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, statusLabel, buttonStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var dataTable = makeDataTable()
    var dataSource: DataTableContent = []
    let headerTitles = ["Name", "Fav Beverage", "Fav Language", "Goals", "Height"]

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
        updateStatus()
    }

    func setupViews() {
        title = "Dynamic Data Source"
        view.backgroundColor = .systemBackground
        view.addSubview(headerStack)
        view.addSubview(dataTable)
        dataTable.reload()
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

    private func updateStatus() {
        statusLabel.text = dataSource.isEmpty ? "No data loaded" : "\(dataSource.count) rows loaded"
        statusLabel.textColor = dataSource.isEmpty ? .systemOrange : .systemGreen
    }

    @objc private func addDataTapped() {
        addDataSourceAfter()
    }

    @objc private func clearDataTapped() {
        dataSource = []
        dataTable.reload()
        updateStatus()
    }

    public func addDataSourceAfter() {
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
                DataTableValueType.string("Be a paratrooper"),
                DataTableValueType.float(185.80)
            ],
            [
                DataTableValueType.string("Redsaint"),
                DataTableValueType.string("Cheerwine"),
                DataTableValueType.string("Java"),
                DataTableValueType.string("Create an RPG"),
                DataTableValueType.float(185.42)
            ],
        ]
        dataTable.reload()
        updateStatus()
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
