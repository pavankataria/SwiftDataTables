//
//  DataTableWithDataSourceViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 05/04/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

// MARK: - Model

struct Developer: Identifiable {
    let id: Int
    let name: String
    let beverage: String
    let language: String
    let goals: String
    let height: Double
}

class DataTableWithDataSourceViewController: UIViewController {

    // MARK: - Data

    var sampleData: [Developer] = []

    let columns: [DataTableColumn<Developer>] = [
        .init("Name", \.name),
        .init("Fav Beverage", \.beverage),
        .init("Fav Language", \.language),
        .init("Goals", \.goals),
        .init("Height", \.height)
    ]

    // MARK: - UI

    private let instructions = InstructionsView(
        description: "Dynamic data updates using typed setData(). Modify your data array and call setData() - the table automatically diffs and animates changes."
    )

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Data", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(loadData), for: .touchUpInside)
        return button
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(clearData), for: .touchUpInside)
        return button
    }()

    private lazy var controlsStack: UIStackView = {
        let buttonStack = UIStackView(arrangedSubviews: [loadButton, clearButton])
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [instructions, statusLabel, buttonStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var dataTable: SwiftDataTable = {
        let table = SwiftDataTable(data: sampleData, columns: columns)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dynamic Data Source"
        view.backgroundColor = .systemBackground

        view.addSubview(controlsStack)
        view.addSubview(dataTable)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dataTable.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        updateStatus()
    }

    // MARK: - Actions

    @objc private func loadData() {
        addDataSourceAfter()
    }

    @objc private func clearData() {
        sampleData = []
        dataTable.setData(sampleData, animatingDifferences: true)
        updateStatus()
    }

    func addDataSourceAfter() {
        sampleData = [
            Developer(id: 1, name: "Pavan", beverage: "Juice", language: "Swift and Php", goals: "Be a game publisher", height: 175.25),
            Developer(id: 2, name: "NoelDavies", beverage: "Water", language: "Php and Javascript", goals: "Be a paratrooper", height: 185.80),
            Developer(id: 3, name: "Redsaint", beverage: "Cheerwine", language: "Java", goals: "Create an RPG", height: 185.42),
        ]
        dataTable.setData(sampleData, animatingDifferences: true)
        updateStatus()
    }

    private func updateStatus() {
        statusLabel.text = sampleData.isEmpty ? "No data loaded" : "\(sampleData.count) rows loaded"
        statusLabel.textColor = sampleData.isEmpty ? .systemOrange : .systemGreen
    }
}

// MARK: - SwiftDataTableDelegate

extension DataTableWithDataSourceViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
}
