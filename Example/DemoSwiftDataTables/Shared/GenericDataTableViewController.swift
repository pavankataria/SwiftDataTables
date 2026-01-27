//
//  GenericDataTableViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 31/10/2019.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import SwiftDataTables
import UIKit

class GenericDataTableViewController: UIViewController {

    private let configDescription: String

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = configDescription
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var configLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.text = buildConfigSummary()
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
    let configuration: DataTableConfiguration

    public init(with configuration: DataTableConfiguration, description: String = "Visual configuration example. Shows how different configuration options affect the table appearance.") {
        self.configuration = configuration
        self.configDescription = description
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
        title = "Configuration Demo"
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

    private func buildConfigSummary() -> String {
        var items: [String] = []

        if !configuration.shouldShowFooter {
            items.append("footer: hidden")
        }
        if !configuration.shouldShowSearchSection {
            items.append("search: hidden")
        }
        if !configuration.shouldSectionHeadersFloat {
            items.append("floating headers: off")
        }
        if !configuration.shouldSectionFootersFloat {
            items.append("floating footers: off")
        }
        if !configuration.shouldShowVerticalScrollBars {
            items.append("vertical scrollbar: hidden")
        }
        if !configuration.shouldShowHorizontalScrollBars {
            items.append("horizontal scrollbar: hidden")
        }
        if configuration.fixedColumns != nil {
            items.append("fixed columns: enabled")
        }
        if configuration.highlightedAlternatingRowColors.count > 2 {
            items.append("custom alternating colors: \(configuration.highlightedAlternatingRowColors.count) colors")
        }

        return items.isEmpty ? "Default configuration" : items.joined(separator: " · ")
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

    func data() -> [[DataTableValueType]] {
        return exampleDataSet().map {
            $0.compactMap(DataTableValueType.init)
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
