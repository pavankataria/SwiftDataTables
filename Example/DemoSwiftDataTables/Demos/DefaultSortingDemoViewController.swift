//
//  DefaultSortingDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for default column sorting.
//

import UIKit
import SwiftDataTables

final class DefaultSortingDemoViewController: UIViewController {

    // MARK: - Properties

    private var selectedColumnIndex: Int = 1
    private var sortOrder: DataTableSortType = .ascending

    private let headers = ["ID", "Name", "Email", "Number", "City", "Balance"]

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Set the default sort column and order. The table will be sorted by this column when it loads."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var columnPicker: UISegmentedControl = {
        let control = UISegmentedControl(items: headers)
        control.selectedSegmentIndex = selectedColumnIndex
        control.addTarget(self, action: #selector(columnChanged), for: .valueChanged)
        return control
    }()

    private lazy var orderPicker: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Ascending", "Descending"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(orderChanged), for: .valueChanged)
        return control
    }()

    private lazy var configSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Default Sorting"
        view.backgroundColor = .systemBackground
        setupViews()
        updateSummary()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let columnLabel = UILabel()
        columnLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        columnLabel.text = "Sort by column:"

        let orderLabel = UILabel()
        orderLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        orderLabel.text = "Sort order:"

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            columnLabel,
            columnPicker,
            orderLabel,
            orderPicker,
            configSummaryLabel
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 10
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Actions

    @objc private func columnChanged() {
        selectedColumnIndex = columnPicker.selectedSegmentIndex
        updateSummary()
        rebuildTable()
    }

    @objc private func orderChanged() {
        sortOrder = orderPicker.selectedSegmentIndex == 0 ? .ascending : .descending
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        let columnName = headers[selectedColumnIndex]
        let orderName = sortOrder == .ascending ? "ascending" : "descending"
        configSummaryLabel.text = "Default sort: \(columnName) (\(orderName))"
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.defaultOrdering = DataTableColumnOrder(index: selectedColumnIndex, order: sortOrder)

        let table = SwiftDataTable(
            data: makeData(),
            headerTitles: headers,
            options: config
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
    }

    // MARK: - Data

    private func makeData() -> DataTableContent {
        return exampleDataSet().map { row in
            row.compactMap { DataTableValueType($0) }
        }
    }
}
